local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")


local Craftbag = require(ServerScriptService.Modules.Crafting.Craftbag)
local Items = require(ReplicatedStorage.Common.Items)
local Store = require(ReplicatedStorage.Common.Store)
local StoreUtility = require(ReplicatedStorage.Common.StoreUtility)

local module = {}

function module.isPlayerCharacterAlive(player: Player)
	if not player.Character then return end
	local Humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
	return Humanoid and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead
end

function module.isWithinBuildsRange(Player: Player, BuildName: string, Range: number)
	local Builds: {Model} = CollectionService:GetTagged(BuildName)
	if not Builds or #Builds <= 0 then
		return
	end

	for _,build in Builds do
		if Player:DistanceFromCharacter(build.WorldPivot.Position) < Range then
			return build
		end
	end
end

function module.canCraft(player: Player, ItemInfo: Items.ItemInfo, Quantity: number)
	local materials = StoreUtility.waitForValue("inventory", player.UserId, "materials")

	if ItemInfo.BuildRequired then
		local build = module.isWithinBuildsRange(player, ItemInfo.BuildRequired, 10)
		if not build then
			return false, `You must be near a {ItemInfo.BuildRequired} to craft {ItemInfo.Name}`
		end
	end

	for ingredient, amount in ItemInfo.Ingredients do
		local materialQuantity = materials[ingredient] or Craftbag.GetQuantityFromInventory(player, ingredient) or 0
		if materialQuantity < (amount * Quantity) then
			return false, "You don't have " .. amount * Quantity .. " units of " .. ingredient
		end
	end

	return true
end

function module.craftItem(player: Player, ItemInfo: Items.ItemInfo, Quantity: number)
	local materials = StoreUtility.waitForValue("inventory", player.UserId, "materials")
	for ingredient,amount in ItemInfo.Ingredients do
		local materialQuantity = materials[ingredient]
		if materialQuantity then
			materials[ingredient] = math.clamp(materialQuantity - (amount * Quantity), 0, 99)
		end

		materialQuantity = Craftbag.GetQuantityFromInventory(player, ingredient)
		if materialQuantity then
			Craftbag.removeFromInventory(player, ingredient, amount * Quantity)
		end
	end

	if table.find(ItemInfo.Tags, "NoTool") then
		local currentQuantity = materials[ItemInfo.Name] or 0
		if ItemInfo.MaxQuantity and currentQuantity + Quantity > ItemInfo.MaxQuantity then
			return false, "Reach max quantity of " .. ItemInfo.Name
		end

		materials[ItemInfo.Name] = currentQuantity + Quantity
	else
		local BackpackQuantity = Craftbag.GetQuantityFromInventory(player, ItemInfo.Name)
		if BackpackQuantity + Quantity > ItemInfo.MaxQuantity then
			return false, "Reach max quantity of " .. ItemInfo.Name
		end

		for _ = 1, Quantity, 1 do
			local item = ServerStorage.Tools:FindFirstChild(ItemInfo.Name):Clone()
			item.Parent = player.Backpack
		end
	end

	Store:dispatch({
		type = "setMaterials",
		userId = player.UserId,
		materials = materials,
	})

	return true
end

return module