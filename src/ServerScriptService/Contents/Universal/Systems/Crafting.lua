local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local CraftingLogic = require(ServerScriptService.Modules.Crafting.CraftingLogic)
local Craftbag = require(ServerScriptService.Modules.Crafting.Craftbag)
local StoreUtility = require(ReplicatedStorage.Common.StoreUtility)
local Items = require(ReplicatedStorage.Common.Items)
local Resources = require(ReplicatedStorage.Common.Resources)
local DataStore2 = require(ServerScriptService.Modules.DataStore2)
local Network = require(ReplicatedStorage.Common.Network)
local Migration = require(ServerScriptService.Modules.Migration)
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)
local Serializer = require(ServerScriptService.Modules.Serializer)
local Store = require(ReplicatedStorage.Common.Store)

local CraftingSounds = SoundService.Crafting
local Entities = ReplicatedStorage.Entities
local RemotesLegacy = ReplicatedStorage.RemotesLegacy
local Notify = RemotesLegacy.Notifier

local Debounce = {}
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { workspace.Landscape }

local canSpawnResource = {}
local module = {}

local function onCraft(player: Player, Item: string, Quantity: number)
	local ItemInfo: Items.ItemInfo = Items.GetItemInfo(Item)
	if not ItemInfo then
		warn(script.Name .. " - The item called  " .. Item .. " does not exist in the Items module.")
		return false, "Internal error: Item not found"
	end

	local ItemQuantity: number = Craftbag.GetQuantity(player, Item)
	local BackpackItemQuantity: number = Craftbag.GetQuantityFromInventory(player, Item)
	if BackpackItemQuantity >= ItemInfo.MaxQuantity or ItemQuantity >= ItemInfo.MaxQuantity then
		Notify:FireClient(player, "Reach max quantity of " .. Item)
		return false, "Reached max quantity of " .. Item
	end

	local result, message = CraftingLogic.canCraft(player, ItemInfo, Quantity)
	if not result then
		return false, message
	end

	result, message = CraftingLogic.craftItem(player, ItemInfo, Quantity)
	if not result then
		return false, message
	end

	local craftSound = CraftingSounds.Crafted:Clone()
	craftSound.PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
	craftSound.PlayOnRemove = true
	craftSound.Parent = player.Character.PrimaryPart
	Debris:AddItem(craftSound, 0)

	return true
end

local function rollDoubleQuantityChance(successChance: number)
	local chance = Random.new():NextNumber(0, 1)
	return chance <= (successChance / 100)
end

local function onPickup(player: Player, mouseTarget: Instance?)
	if not mouseTarget or not mouseTarget:IsA("BasePart") then
		return false, "Internal error: Target invalid"
	end

	local Resource: BasePart = mouseTarget
	local Folder = Resource:FindFirstAncestorWhichIsA("Folder")
	if not Folder or Folder ~= workspace.Resources then
		return false, "You're too far from this."
	end

	if player:DistanceFromCharacter(Resource.Position) >= 10 then
		return false, "You're too far from this."
	end

	local Model = Resource:FindFirstAncestorWhichIsA("Model")
	if Model and Model.Parent == workspace.Resources then
		Resource = Model
	end

	local ResourceInfo: Resources.ResourceInfo = Resources.GetResourceInfo(Resource.Name)
	if not ResourceInfo then
		warn(script.Name .. " - The resource called  " .. Resource.Name .. " does not exist in the Resources module.")
		return false, "Internal error: Resource not found"
	end

	local resourcesPickedUp = {}

	-- Double quantity chance for the Scavenger perk
	local hasScavenger = player.Character:GetAttribute("Scavenger")
	local double = hasScavenger and rollDoubleQuantityChance(hasScavenger) or false
	local resourceQuantity = double and ResourceInfo.DropQuantity * 2 or ResourceInfo.DropQuantity

	-- Checking if their bag is full
	local quantityInBag = Craftbag.GetQuantity(player, Resource.Name)
	if quantityInBag >= 99 then
		return false, "Reached max quantity of " .. Resource.Name
	else
		Craftbag.IncrementQuantity(player, Resource.Name, resourceQuantity)
		resourcesPickedUp[Resource.Name] = resourceQuantity
	end

	-- Some resources have additional resources, such as deer dropping meat and leather
	if ResourceInfo.AdditionalDrops then
		for _, additionalResourceName in ResourceInfo.AdditionalDrops do
			local AdditionalResourceInfo = Resources.GetResourceInfo(additionalResourceName)
			resourceQuantity = double and AdditionalResourceInfo.DropQuantity * 2 or AdditionalResourceInfo.DropQuantity
			quantityInBag = Craftbag.GetQuantity(player, additionalResourceName)
			if quantityInBag >= 99 then
				return false, "Reached max quantity of " .. additionalResourceName
			else
				Craftbag.IncrementQuantity(player, additionalResourceName, resourceQuantity)
				resourcesPickedUp[additionalResourceName] = resourceQuantity
			end
		end
	end

	if next(resourcesPickedUp) ~= nil then
		local sound: Sound = CraftingSounds.Resources[Resource.Name]:Clone()
		sound.PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
		sound.Parent = player.Character.PrimaryPart
		Debris:AddItem(sound, sound.TimeLength)
		Debris:AddItem(Resource, 0)
		return true, resourcesPickedUp
	end
end

local function updateResourceQuantity(child: Instance)
	if not Resources[child.Name] then
		return
	end

	local sameTypeQuantity = {}

	for i, v in workspace.Resources:GetChildren() do
		if v.Name == child.Name then
			table.insert(sameTypeQuantity, v)
		end
	end

	if #sameTypeQuantity > Resources[child.Name].MaxQuantity then
		canSpawnResource[child.Name] = false
	else
		canSpawnResource[child.Name] = true
	end
end

function module.init()
	workspace.Resources.ChildAdded:Connect(updateResourceQuantity)
	workspace.Resources.ChildRemoved:Connect(updateResourceQuantity)

	Network.bindFunction(Network.RemoteFunctions.Craft, function(player: Player, itemName: string, quantity: number)
		return onCraft(player, itemName, quantity)
	end, Network.t.instanceOf("Player"), Network.t.string, Network.t.number)

	Network.bindFunction(Network.RemoteFunctions.Pickup, function(player: Player, mouseTarget: Instance?)
		return onPickup(player, mouseTarget)
	end, Network.t.instanceOf("Player"), Network.t.any)

	for _, player in Players:GetPlayers() do
		Migration.updateInventoryToLatest(player)
	end

	Players.PlayerAdded:Connect(function(player)
		Migration.updateInventoryToLatest(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		local materials = StoreUtility.waitForValue("inventory", player.UserId, "materials")
		if not materials then
			warn(`Unable to save materials for player {player.Name}: materials is nil.`)
			return
		end

		local serialized_array = {}
		for item, quantity in materials do
			if quantity <= 0 then
				continue
			end

			local serialized_item = Serializer.SerializeItem(item, quantity)
			table.insert(serialized_array, serialized_item)
		end

		serialized_array = HttpService:JSONEncode(serialized_array)

		local CraftbagStore = DataStore2("Craftbag", player)
		CraftbagStore:Set(serialized_array)
	end)

	Scheduler.AddToScheduler("Interval_0.2", "Crafting", function()
		for resource, _ in Resources do
			if not Entities.Resources:FindFirstChild(resource) then
				continue
			end
			if Resources[resource].TerrainMaterial == nil then
				continue
			end
			if canSpawnResource[resource] == false then
				continue
			end

			local rayResult

			repeat
				task.wait()
				rayResult = workspace:Raycast(
					Vector3.new(math.random(-1000, 1000), 120, math.random(-1000, 1000)),
					Vector3.new(0, -150, 0),
					rayParams
				)
			until rayResult
				and rayResult.Instance.Name == "Terrain"
				and table.find(Resources[resource].TerrainMaterial, rayResult.Material.Name)

			local newResource: Instance = Entities.Resources[Resources[resource].Name]:Clone()
			local yOffsetFactor = 2

			if Resources[resource].yOffset ~= nil then
				yOffsetFactor = Resources[resource].yOffset
			end

			if newResource:IsA("BasePart") then
				newResource.Position = rayResult.Position - Vector3.new(0, -(newResource.Size.Y / yOffsetFactor), 0)
				newResource.Rotation = Vector3.new(rayResult.Normal.X, math.random(0, 360), rayResult.Normal.Z)
			else
				newResource:PivotTo(
					CFrame.new(
						rayResult.Position - Vector3.new(0, -(newResource.PrimaryPart.Size.Y / yOffsetFactor), 0)
					) * CFrame.Angles(rayResult.Normal.X, math.random(0, 360), rayResult.Normal.Z)
				)
			end

			newResource.Parent = workspace.Resources
		end
	end)
end

return module
