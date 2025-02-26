local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local BuildState = require(ReplicatedStorage.Common.States.Game.BuildState)
local Network = require(ReplicatedStorage.Common.Network)
local Builderman = require(ServerScriptService.Modules.Build.Builderman)
local CharacterLibrary = require(ReplicatedStorage.Common.Libraries.CharacterLibrary)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)

local builderman = Builderman.new()
local buildState = BuildState.state

local DEBOUNCE_SECONDS = 0.5
local REPAIR_DISTANCE = 7
local BUILD_DISTANCE = 10
local DESTROY_DISTANCE = 10

local MAX_QUANTITIES = {
	["SATCOM Radio"] = 1,
	["Radio"] = 1,
	["Local Marker"] = 8,
	["Global Marker"] = 8,
	["Motion Sensor"] = 6,
	["Spring Trap"] = 12,
	["Barbed Wire"] = 12,
	["Landmine"] = 12,
	["Rain Barrel"] = 2,
	["Flood Light"] = 16,
	["Storage"] = 4,
	["Generator"] = 3,
	["Battery"] = 6,
	["Sentry"] = 2,
}

local module = {}

local function typecheck(object: any, type: string, instanceType: string?)
	if object == nil then
		return false
	end
	if type == "Instance" and instanceType then
		return object:IsA(instanceType)
	end
	return typeof(object) == type
end

local function getBuildLimit(player: Player): number
	local buildLimit = 50
	if player:IsInGroup(10705478) then
		buildLimit += 50
	end
	if MarketplaceService:UserOwnsGamePassAsync(player.UserId, 255878424) then
		buildLimit += 500
	end
	return buildLimit
end

local function getBuildQuantity(playerName: string, modelName: string): number
	local playerBuilds = buildState.players[playerName].builds
	local quantity = 0
	for _, buildObject in playerBuilds do
		if buildObject.model.Name == modelName then
			quantity += 1
		end
	end
	return quantity
end

local function createPlayerBuildStore(player: Player)
	buildState.players[player.Name] = {
		builds = {},
		buildLimit = getBuildLimit(player),
	}
end

local function isOverlapping(model: Model, position: Vector3): boolean
	if RunService:IsStudio() then
		return false
	end

	local buildOverlapParams = OverlapParams.new()
	buildOverlapParams.FilterType = Enum.RaycastFilterType.Include
	buildOverlapParams.FilterDescendantsInstances = {
		workspace.Forcefields,
		workspace.TreeTrunks,
		workspace.Map_NoBuild,
	}

	local buildOverlapPart = Instance.new("Part")
	buildOverlapPart.CanCollide = false
	buildOverlapPart.Size = model:GetExtentsSize()
	buildOverlapPart.Position = position
	buildOverlapPart.Transparency = 1
	buildOverlapPart.Parent = workspace

	local parts = workspace:GetPartsInPart(buildOverlapPart, buildOverlapParams)
	buildOverlapPart:Destroy()

	return #parts > 0
end

local function handleBuildEvent(player: Player, model: Model, cframe: CFrame)
	if player:DistanceFromCharacter(cframe.Position) > BUILD_DISTANCE then
		return Notifier.NotificationEvent(player, "You're too far")
	end

	if isOverlapping(model, cframe.Position) then
		return
	end

	local maxQuantity = MAX_QUANTITIES[model.Name]
	if maxQuantity then
		local buildQuantity = getBuildQuantity(player.Name, model.Name)
		if buildQuantity >= maxQuantity then
			return Notifier.NotificationEvent(player, `You can only build {maxQuantity} units of {model.Name}`)
		end
	end

	builderman:build(player, model, cframe)
end

local function handleDestroyEvent(player: Player, model: Model)
	if player:DistanceFromCharacter(model.WorldPivot.Position) > DESTROY_DISTANCE then
		return Notifier.NotificationEvent(player, "You're too far")
	end
	builderman:destroy(player, model)
end

local function handleRepairEvent(player: Player, model: Model, hitPos: Vector3)
	if player:DistanceFromCharacter(hitPos) > REPAIR_DISTANCE then
		return Notifier.NotificationEvent(player, "You're too far")
	end
	builderman:repair(player, model)
end

function module.init()
	Network.connectEvent(Network.RemoteEvents.BuildEvent, function(player: Player, eventParams: any)
		if buildState.debounces[player.Name] and (tick() - buildState.debounces[player.Name]) < DEBOUNCE_SECONDS then
			return
		end
		buildState.debounces[player.Name] = tick()

		if CharacterLibrary.IsDead(player) then
			return
		end

		local eventType: string = eventParams.eventType
		if not typecheck(eventType, "string") then
			return
		end

		local model: Model = eventParams.model
		if not typecheck(model, "Instance", "Model") then
			return
		end

		if not buildState.players[player.Name] then
			createPlayerBuildStore(player)
		else
			buildState.players[player.Name].buildLimit = getBuildLimit(player)
		end

		if eventType == "Build" then
			local cframe: CFrame = eventParams.cframe
			if not typecheck(cframe, "CFrame") then
				return
			end
			handleBuildEvent(player, model, cframe)
		elseif eventType == "Destroy" then
			handleDestroyEvent(player, model)
		elseif eventType == "Repair" then
			local hitPos: Vector3 = eventParams.hitPos
			if not typecheck(hitPos, "Vector3") then
				return
			end
			handleRepairEvent(player, model, hitPos)
		end
	end, Network.t.instanceOf("Player"), Network.t.any)

	Players.PlayerAdded:Connect(function(player: Player)
		if not buildState.players[player.Name] then
			createPlayerBuildStore(player)
		else
			buildState.players[player.Name].buildLimit = getBuildLimit(player)
		end
	end)

	workspace.Buildables.Player.ChildRemoved:Connect(function(child)
		local ownerName = child:GetAttribute("Owner")
		if not ownerName then
			return
		end

		local playerBuilds = buildState.players[ownerName].builds
		for i, buildObject in playerBuilds do
			if buildObject.model == child then
				table.remove(playerBuilds, i)
				buildObject:Destroy()
				break
			end
		end
	end)
end

return module
