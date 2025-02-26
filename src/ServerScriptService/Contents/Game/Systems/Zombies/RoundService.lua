local Debris = game:GetService("Debris")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")

local Network = require(ReplicatedStorage.Common.Network)
local RoundBoard = require(ServerScriptService.Modules.RoundBoard)
local RoundState = require(ReplicatedStorage.Common.States.Game.RoundState)
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)
local ZombieService = require(ServerScriptService.Contents.Game.Systems.Zombies.ZombieService)

local roundEvent = ReplicatedStorage.RemotesLegacy.RoundEvent

local zombieTypeRoundSpawn = {
	["Swarmer"] = 1,
	["Crawler"] = 2,
	["Hopper"] = 3,
	["Stalker"] = 5,
	["Spitter"] = 10,
	["Predator"] = 15,
	["Abomination"] = 20,
}

local roundState = RoundState.state

local serverBuilds = {}
local RoundService = {}

local MAX_ACTIVE_ZOMBIES = 50

local function getZombieTypes()
	local zombieTypes = {}
	for zombieType, round in zombieTypeRoundSpawn do
		if roundState.round >= round then
			table.insert(zombieTypes, zombieType)
		end
	end
	return zombieTypes
end

local function respawnDeadPlayers()
	for _, player in Teams.Dead:GetPlayers() do
		player:LoadCharacter()
	end
end

local function resetServerBuilds()
	workspace.Buildables.Server:ClearAllChildren()
	for _, build in serverBuilds do
		local clone = build:Clone()
		clone.Parent = workspace.Buildables.Server
	end
end

local function checkLoneSurvivor()
	if roundState.loneSurvivorAchieved then
		return
	end
	if not roundState.loneSurvivor then
		return
	end
	if #Players:GetPlayers() > 1 then
		roundState.loneSurvivor = false
		return
	end
	if roundState.round < 30 then
		return
	end
	local survivor = Teams.Survivor:GetPlayers()[1]
	BadgeService:AwardBadge(survivor.UserId, 2132575109)
	roundState.loneSurvivorAchieved = true
end

local function spawnZombies()
	if roundState.zombiesSpawned >= roundState.zombieCount then
		return
	end

	if not roundState.started or roundState.intermission then
		return
	end

	local currentZombies = #workspace.Zombies:GetChildren()
	if currentZombies >= roundState.zombieCount or currentZombies >= MAX_ACTIVE_ZOMBIES then
		return
	end

	local hotSpots = ZombieService.getHotSpots()
	if next(hotSpots) == nil then
		local zombieType = roundState.zombieTypes[math.random(1, #roundState.zombieTypes)]
		ZombieService.spawnZombie(zombieType)
		roundState.zombiesSpawned += 1
		return
	end

	if next(hotSpots) ~= nil then
		local randomArea = ZombieService.getHotSpot()
		local zombieType = roundState.zombieTypes[math.random(1, #roundState.zombieTypes)]
		ZombieService.spawnZombie(zombieType, randomArea.Position)
		roundState.zombiesSpawned += 1
		return
	end
end

--[[
        Starts the intermission between rounds
    ]]
function RoundService.intermission()
	roundState.round += 1
	checkLoneSurvivor()
	roundState.zombieTypes = getZombieTypes()
	roundState.intermission = true
	roundState.intermissionStartTick = tick()
	roundState.roundStartTick = nil
	roundState.isFastRound = false
	RoundBoard.updateHighestRoundBoard()
	respawnDeadPlayers()
	roundEvent:FireAllClients("newRound", { round = roundState.round })
end

function RoundService.startRound()
	roundState.intermission = false
	roundState.intermissionStartTick = nil
	roundState.roundStartTick = tick()
	roundState.zombieCount =
		math.clamp(roundState.baseZombieCount + roundState.round * roundState.zombiesPerRound, 0, 200)
	roundState.zombiesSpawned = 0
end

function RoundService.updateClient()
	local roundSeconds = ReplicatedStorage.ServerInfo.RoundSeconds
	roundSeconds.Value = roundState.roundSeconds - math.round(tick() - roundState.roundStartTick)
end

function RoundService.gameLoop()
	if not roundState.started and #Teams.Survivor:GetPlayers() > 0 then
		roundState.started = true
		RoundService.intermission()
	end

	if not roundState.started then
		return
	end

	if roundState.intermission then
		if tick() - roundState.intermissionStartTick >= roundState.intermissionSeconds then
			RoundService.startRound()
		end
	else
		if
			#workspace.Zombies:GetChildren() <= 5
			and tick() - roundState.roundStartTick > 10
			and not roundState.isFastRound
		then
			roundState.isFastRound = true
			if tick() - roundState.roundStartTick < roundState.roundSeconds - roundState.fastRoundSeconds then
				roundState.roundStartTick = tick() - (roundState.roundSeconds - roundState.fastRoundSeconds)
			end
		end
		RoundService.updateClient()
		if tick() - roundState.roundStartTick >= roundState.roundSeconds or #workspace.Zombies:GetChildren() <= 0 then
			RoundService.intermission()
			ZombieService.clearZombies()
		end
	end

	if roundState.started and #Teams.Survivor:GetPlayers() <= 0 then
		roundEvent:FireAllClients("endGame")
		roundState.started = false
		roundState.round = 0
		roundState.roundStartTick = nil
		roundState.intermission = true
		roundState.intermissionStartTick = nil
		task.delay(3, function()
			ZombieService.clearZombies()
			resetServerBuilds()
		end)
		task.delay(5, function()
			respawnDeadPlayers()
		end)
	end
end

function RoundService.cacheServerBuilds()
	for _, build in workspace.Buildables.Server:GetChildren() do
		local clone = build:Clone()
		table.insert(serverBuilds, clone)
	end
end

function RoundService.init()
	workspace.DeadZombies.ChildAdded:Connect(function()
		local deadZombies = workspace.DeadZombies:GetChildren()
		if #deadZombies > 40 then
			local randomDeadZombie = deadZombies[math.random(1, #deadZombies)]
			Debris:AddItem(randomDeadZombie)
		end
	end)

	Network.connectEvent(Network.RemoteEvents.PlayerJoinedEvent, function(player: Player, eventType: string)
		if eventType == "getCurrentRound" then
			if roundState.started then
				roundEvent:FireClient(player, "newRound", { round = roundState.round })
			end
		end
	end, Network.t.instanceOf("Player"), Network.t.string)

	Scheduler.AddToScheduler("Interval_1s", "RoundService", RoundService.gameLoop)
	Scheduler.AddToScheduler("Interval_0.2", "SpawnZombies", spawnZombies)

	RoundService.cacheServerBuilds()
end

return RoundService
