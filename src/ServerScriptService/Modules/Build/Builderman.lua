local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local DataStore2 = require(ServerScriptService.Modules.DataStore2)
local BuildState = require(ReplicatedStorage.Common.States.Game.BuildState)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)

local buildState = BuildState.state

local Randomizer = Random.new()
local Buildables = ReplicatedStorage.Entities.Buildables
local module = {}
module.__index = module

-- Loads the build constructors for creating buildable objects and their respected functions.
local function getBuildClasses()
	local classes = {}

	for _, class in ServerScriptService.Modules.Build.Classes:GetChildren() do
		if not class:IsA("ModuleScript") then
			continue
		end
		classes[class.Name] = require(class)
	end

	return classes
end

-- Increments the players materials by the amount specified.
local function incrementMaterials(player: Player, amount: number)
	local materialsStore = DataStore2("Materials", player)
	materialsStore:Increment(amount)
end

-- Checks if the player can afford the materials cost.
local function hasMaterials(player: Player, amount: number)
	local materialsStore = DataStore2("Materials", player)
	return materialsStore:Get() >= amount
end

-- Returns the build object and index from the player's builds table.
local function getBuildObject(player: Player, model: Model)
	local playerStore = buildState.players[player.Name]
	local playerBuilds = playerStore.builds

	for i: number, build: {} in playerBuilds do
		if build.model == model then
			return build, i
		end
	end
end

-- Creates a new builderman instance.
function module.new()
	local self = setmetatable({}, module)
	self.buildClasses = getBuildClasses()
	return self
end

-- Creates a build object and instantiates the model at the cframe.
function module:build(player: Player, model: Model, cframe: CFrame)
	local buildCost = model:GetAttribute("Cost")
	if not buildCost then
		return
	end
	if not hasMaterials(player, buildCost) then
		return Notifier.NotificationEvent(player, "Insufficient materials")
	end

	local buildClass = self.buildClasses[model.Name]
	local playerStore = buildState.players[player.Name]
	local playerBuilds = playerStore.builds
	local buildLimit = playerStore.buildLimit

	if #playerBuilds >= buildLimit then
		Notifier.NotificationEvent(player, `You have reached your build limit of {buildLimit}`)
		if not player:IsInGroup(10705478) then
			Notifier.NotificationEvent(player, "Join the group to increase your build limit to 100")
		end
		return
	end

	local buildObject
	local newModel = model:Clone()

	if model.Parent == Buildables.Structure then
		newModel:AddTag("Structure")
	else
		newModel:AddTag("NonStructure")
	end

	if not buildClass then
		buildObject = self.buildClasses.BuildClass.new(newModel, player)
	else
		buildObject = buildClass.new(newModel, player)
	end

	buildObject.model:PivotTo(cframe)
	buildObject.model.Parent = workspace.Buildables.Player
	table.insert(playerBuilds, buildObject)
	incrementMaterials(player, -buildCost)
	return buildObject
end

-- Destroys the build object and model.
function module:destroy(player: Player, model: Model)
	-- Checks if it's actually a buildable
	local folder = model:FindFirstAncestorWhichIsA("Folder")
	if not folder or folder ~= workspace.Buildables.Player then
		return Notifier.NotificationEvent(player, "You can't destroy this.")
	end
	-- Removes the build when the owner isn't present
	local buildObject, index = getBuildObject(player, model)
	if not buildObject then
		if model then
			model:Destroy()
		end
		return
	end
	if not buildObject.owner then
		table.remove(buildState.players[buildObject.ownerName].builds, index)
		buildObject:Destroy()
		return
	end
	if player ~= buildObject.owner then
		if buildObject.permissions.destroy.ownerOnly then
			return Notifier.NotificationEvent(
				player,
				`No permissions to destroy {buildObject.ownerName}'s {model.Name}`
			)
		end
	end
	if buildObject.model:GetAttribute("InUse") then
		return Notifier.NotificationEvent(player, "This is in use")
	end
	local buildCost = model:GetAttribute("Cost")
	if player ~= buildObject.owner then
		if not hasMaterials(player, buildCost) then
			return Notifier.NotificationEvent(player, "Insufficient materials")
		end
		incrementMaterials(player, -buildCost)
		table.remove(buildState.players[buildObject.owner.Name].builds, index)
		buildObject:Destroy()
	else
		incrementMaterials(player, buildCost)
		table.remove(buildState.players[buildObject.owner.Name].builds, index)
		buildObject:Destroy()
	end
end

-- Plays the repair sound
local function playRepairSound(model: Model)
	local soundSource = model:FindFirstChildWhichIsA("BasePart")
	if not soundSource then
		return
	end
	local repairSound: Sound = SoundService.Building.HammerHit:Clone()
	repairSound.PlaybackSpeed = Randomizer:NextNumber(0.9, 1.1)
	repairSound.Parent = soundSource
	repairSound.PlayOnRemove = true
	repairSound:Destroy()
end

-- Repairs the build model.
function module:repair(player: Player, model: Model)
	local maxHealth = model:GetAttribute("MaxHealth")
	if not maxHealth then
		return
	end

	local currentHealth = model:GetAttribute("Health")
	if not currentHealth then
		return
	end

	if currentHealth == maxHealth then
		return Notifier.NotificationEvent(player, "This build is already at full health")
	end

	local REPAIR_RATE = 10
	local REPAIR_MINIMUM = 1
	local repairAmountPerHit = math.clamp(maxHealth / REPAIR_RATE, REPAIR_MINIMUM, maxHealth)
	repairAmountPerHit = math.floor(repairAmountPerHit)
	local newHealth = math.clamp(currentHealth + repairAmountPerHit, 0, maxHealth)
	model:SetAttribute("Health", newHealth)
	playRepairSound(model)
	return model:GetAttribute("Health")
end

function module:Destroy()
	setmetatable(self, nil)
end

return module
