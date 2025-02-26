local module = {}

local BadgeService = game:GetService("BadgeService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")

local ZombieFunctions = require(ServerScriptService.Modules.Zombies.ZombieFunctions)
local AIFunctions = require(ServerScriptService.Modules.Zombies.AIFunctions)
local spawnAI_event: RemoteEvent = ReplicatedStorage.RemotesLegacy.SpawnAI
local newRoundEvent: BindableEvent = ReplicatedStorage.RemotesLegacy.NewRound
local Highlights = ReplicatedStorage.Entities.Highlights
local debounce = {}

local AI_Tools = {
	ServerStorage.Tools["Zombie Spawner"]
}

local zombieModel = ReplicatedStorage.Entities.Zombies.Enemy_Zombie
local zombieClassesDirectory = ServerScriptService.Modules.AI.Zombies
local zombieClasses = {
	Swarmer = require(zombieClassesDirectory.Swarmer),
	Crawler = require(zombieClassesDirectory.Crawler),
	Stalker = require(zombieClassesDirectory.Stalker),
	Hopper = require(zombieClassesDirectory.Hopper),
	Spitter = require(zombieClassesDirectory.Spitter),
	Predator = require(zombieClassesDirectory.Predator),
	Abomination = require(zombieClassesDirectory.Abomination),
}

local randomClass = {
	"Swarmer",
	"Crawler",
	"Stalker",
	"Hopper",
	"Spitter",
	"Predator",
	"Abomination",
}

local ServerBuildables = {}

-- Days

local dayEvent = ReplicatedStorage.RemotesLegacy.Day
local maxtime = 180
local timeLeft = maxtime
local roundSeconds = ReplicatedStorage.ServerInfo.RoundSeconds

local zombieWaveSpawnRaycast
local waveSpawned = false

local maximumSpawnDistance = 1000
local minimumSpawnDistance = 100
local spawnRange = 600
local raycastHeight = 100

local waitingNextRound = false
local gameStarted = false
local highestRound = 0
local highestRoundBoard = workspace.HighestRound
local highestRoundPlayersBoard = workspace.HighestRoundPlayers

local canGetBadge = true

local function updateHighestRoundBoard()
	if ZombieFunctions.day <= highestRound then return end

	highestRound = ZombieFunctions.day

	highestRoundBoard.Part.SurfaceGui.Frame.Count.Text = ZombieFunctions.day

	for i,v in highestRoundPlayersBoard.Part.SurfaceGui.Frame:GetChildren() do
		if v:IsA("TextLabel") and v.Name ~= "Title" then
			v:Destroy()
		end
	end

	for i,player in Players:GetPlayers() do
		local nameSample = highestRoundPlayersBoard.SampleFolder.PlayerName:Clone()
		nameSample.Text  = player.Name
		nameSample.Parent = highestRoundPlayersBoard.Part.SurfaceGui.Frame
	end
end

local function nextDay()
	if canGetBadge then
		if #Players:GetPlayers() == 1 then
			if ZombieFunctions.day >= 30 then
				for _,v in Players:GetPlayers() do
					BadgeService:AwardBadge(v.UserId, 2132575109)
					break
				end

				canGetBadge = false
			end
		else
			canGetBadge = false
		end
	end

	gameStarted = true
	waveSpawned = false

	ZombieFunctions.day += 1
	updateHighestRoundBoard()

	ZombieFunctions.moneyModifier += 1

	ZombieFunctions.zombiesPerDay = math.clamp(ZombieFunctions.zombiesPerDay + 2, 20, 75)

	ZombieFunctions.walkspeedModifier = math.clamp(ZombieFunctions.walkspeedModifier + 0.5, 0, 7)

	ZombieFunctions.damageModifier = math.clamp(ZombieFunctions.damageModifier + 0.1, 0, 30)

	ZombieFunctions.healthModifier += 5

	timeLeft = maxtime
	dayEvent:FireAllClients(ZombieFunctions.day)
	newRoundEvent:Fire()
	waitingNextRound = false
end

local function spawnWave()
	local zombiesToSpawn = ZombieFunctions.zombiesPerDay

	local rayparams = RaycastParams.new()
	rayparams.FilterType = Enum.RaycastFilterType.Exclude
	rayparams.FilterDescendantsInstances = {workspace.Landscape}

	local attempts = 0

	local safeToSpawn, magnitude

	minimumSpawnDistance = 100

	repeat
		task.wait()

		safeToSpawn = true

		zombieWaveSpawnRaycast = workspace:Raycast(Vector3.new(math.random(-spawnRange, spawnRange), raycastHeight, math.random(-spawnRange, spawnRange)), Vector3.new(0, -raycastHeight - 5, 0), rayparams)

		if not zombieWaveSpawnRaycast then attempts += 1 continue end
		if zombieWaveSpawnRaycast.Instance.Name ~= "Terrain" or zombieWaveSpawnRaycast.Material == Enum.Material.Water then continue end

		for _,player in Teams.Survivor:GetPlayers() do
			magnitude = player:DistanceFromCharacter(zombieWaveSpawnRaycast.Position)
			if magnitude < minimumSpawnDistance or magnitude > maximumSpawnDistance then
				safeToSpawn = false
				break
			end
		end

		if not safeToSpawn then
			minimumSpawnDistance = math.clamp(minimumSpawnDistance - 5, 10, 100)
			attempts += 1
			continue
		end

		task.spawn(function()
			AIFunctions.SpawnAI(ReplicatedStorage.Entities.Zombies.Enemy_Zombie, zombieWaveSpawnRaycast.Position + Vector3.new(0, 5, 0))
		end)

		zombiesToSpawn -= 1
		attempts = 0

	until zombiesToSpawn <= 0 or attempts >= 15

	if attempts >= 15 then
		repeat
			task.wait()

			zombieWaveSpawnRaycast = workspace:Raycast(Vector3.new(math.random(-spawnRange, spawnRange), raycastHeight, math.random(-spawnRange, spawnRange)), Vector3.new(0, -raycastHeight - 5, 0), rayparams)

			if not zombieWaveSpawnRaycast then attempts += 1 continue end
			if zombieWaveSpawnRaycast.Instance.Name ~= "Terrain" then continue end
			if zombieWaveSpawnRaycast.Material ~= Enum.Material.Grass then continue end

			AIFunctions.SpawnAI(ReplicatedStorage.Entities.Zombies.Enemy_Zombie, zombieWaveSpawnRaycast.Position + Vector3.new(0, 5, 0))
			zombiesToSpawn -= 1
		until zombiesToSpawn <= 0
	end

	repeat
		task.wait(1)
		timeLeft -= 1
		roundSeconds.Value = timeLeft

		if #workspace.Zombies:GetChildren() <= 5 then
			if timeLeft > 60 then
				timeLeft = 60
			end

			if Highlights.ZedHighlight.Enabled == false then
				print("Highlighted all zombies.")
				Highlights.ZedHighlight.Adornee = workspace.Zombies
				Highlights.ZedHighlight.Enabled = true
			end
		end
	until timeLeft <= 0 or #workspace.Zombies:GetChildren() <= 0

	workspace.Zombies:ClearAllChildren()
	Highlights.ZedHighlight.Adornee = nil
	Highlights.ZedHighlight.Enabled = false

	if #Teams.Survivor:GetPlayers() == 0 then return end

	nextDay()
end

local function reset()
	if ZombieFunctions.day > 0 then
		for i,v in workspace.Buildables.Server:GetChildren() do
			v:Destroy()
		end

		for i,v: Model in ServerBuildables do
			local newbuild = v:Clone()
			newbuild.Parent = workspace.Buildables.Server
		end
	end

	ZombieFunctions.day = 0
	ZombieFunctions.zombiesPerDay = 19
	ZombieFunctions.damageModifier = 0
	ZombieFunctions.moneyModifier = 0
	ZombieFunctions.healthModifier = 0
	ZombieFunctions.walkspeedModifier = 0

	task.delay(3, function()
		workspace.Zombies:ClearAllChildren()
	end)

	if gameStarted == true then
		task.spawn(function()
			dayEvent:FireAllClients("End")
			task.wait(5)
			newRoundEvent:Fire()
		end)
	end

	gameStarted = false
	waveSpawned = false
end

function module.init()
    for i,build in workspace.Buildables.Server:GetChildren() do
        local copy = build:Clone()
        table.insert(ServerBuildables, copy)
    end
    
    spawnAI_event.OnServerEvent:Connect(function(player, AIName, mousePosition)
        if debounce[player] ~= nil and (tick() - debounce[player]) < 0.1 then return end
        debounce[player] = tick()
    
        local tool = player.Character:FindFirstChildOfClass("Tool")
        local hasTool = false
    
        if tool then
            for _,v in pairs(AI_Tools) do
                if tool.Name == v.Name then
                    hasTool = true
                    break
                end
            end
        end
    
        if hasTool == true then
			local random = randomClass[math.random(1, #randomClass)]
			local zombieClass = zombieClasses[random]
			local newZombie = zombieClass.new(zombieModel)
			newZombie.Character.Name = random
			newZombie.Character.Parent = workspace.Zombies
			newZombie.Character:PivotTo(CFrame.new(mousePosition + Vector3.new(0, 4, 0)))
			print(`{player.Name} spawned {random}`)
        end
    end)
    
    Players.PlayerAdded:Connect(function(player)
        if ZombieFunctions.day == 0 then return end
        task.wait(5)
        dayEvent:FireClient(player, ZombieFunctions.day)
    end)
    
    Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
        if #Teams.Survivor:GetPlayers() == 0 then
            if gameStarted == true then
                waitingNextRound = true
                reset()
            end
        else
            if gameStarted == false then
                nextDay()
            end
        end
    
        if gameStarted == false then return end
        if waitingNextRound == true then return end
        if waveSpawned == true then return end
        waveSpawned = true
    
        task.wait(40)
    
        spawnWave()
    end)
end

return module
