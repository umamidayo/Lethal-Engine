local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Teams = game:GetService("Teams")

local CharacterLib = require(ReplicatedStorage.Common.Libraries.CharacterLibrary)
local Promise = require(ReplicatedStorage.Dependencies.Promise)
local RoundState = require(ReplicatedStorage.Common.States.Game.RoundState)
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)
local Weather = require(ServerScriptService.Contents.Universal.Systems.Weather)

local roundState = RoundState.state
local damageModifier = math.clamp(roundState.round * 0.1, 0, 30)
local walkspeedModifier = math.clamp(roundState.round * 0.5, 0, 7)
local ZOMBIE_ERROR_LIMIT = 10
local ZOMBIE_ERROR_INCREMENT = 1
local ZOMBIE_ERROR_START = 0
local zombieModel = ReplicatedStorage.Entities.Zombies.Enemy_Zombie
local zombieClassesFolder = ServerScriptService.Modules.AI.Zombies
local zombieClasses = {}
local zombies = {}

local module = {}

local function requireZombieClasses()
	for _, zombieClass in zombieClassesFolder:GetChildren() do
		zombieClasses[zombieClass.Name] = require(zombieClass)
	end
end

local function addModifiers(zombie)
	damageModifier = math.clamp(roundState.round * 0.1, 0, 30)
	walkspeedModifier = math.clamp(roundState.round * 0.5, 0, 7)
	zombie.Damage += damageModifier
	zombie.Humanoid.WalkSpeed += walkspeedModifier
	zombie.Humanoid.MaxHealth += 5 * roundState.round
	zombie.Humanoid.Health = zombie.Humanoid.MaxHealth
	if Weather.currentWeather == "BloodMoon" then
		zombie.Damage *= 1.2
		zombie.Humanoid.WalkSpeed *= 1.2
		zombie.Humanoid.MaxHealth *= 1.5
		zombie.Humanoid.Health = zombie.Humanoid.MaxHealth
	end
end

function module.getHotSpots()
	local zombieSpawnAreas: { BasePart } = CollectionService:GetTagged("ZombieSpawnArea")
	local survivors: { Player } = Teams.Survivor:GetPlayers()
	local hotSpots: { [BasePart]: number } = {}
	for _, area in zombieSpawnAreas do
		hotSpots[area] = 0
		for _, player in survivors do
			local distance = player:DistanceFromCharacter(area.Position)
			if distance < 1000 then
				hotSpots[area] += 1
			end
		end
		if hotSpots[area] == 0 then
			hotSpots[area] = nil
		end
	end

	return hotSpots, survivors
end

-- Gets the most populated hotspot.
function module.getHotSpot()
	local hotSpots = module.getHotSpots()
	local mostPopulatedHotspot = nil
	local mostPopulatedPlayerCount = 0
	for area, playerCount in hotSpots do
		if playerCount > mostPopulatedPlayerCount then
			mostPopulatedHotspot = area
			mostPopulatedPlayerCount = playerCount
		end
	end
	return mostPopulatedHotspot
end

--[[
        Creates a new zombie object, returns the zombie object.

        zombieName: The name of the zombie class to spawn. Defaults to a random zombie class.

        location: The location to spawn the zombie at. Defaults to a random spawn area object's position.
    ]]
function module.spawnZombie(zombieName: string, location: Vector3?)
	if not zombieName then
		local zombieNames = {}
		for name, _ in zombieClasses do
			table.insert(zombieNames, name)
		end
		zombieName = zombieNames[math.random(1, #zombieNames)]
	end

	local zombieClass = zombieClasses[zombieName]
	local zombie = zombieClass.new(zombieModel)
	zombie.Character.Name = zombieName
	zombie.Character.Parent = workspace.Zombies
	CharacterLib.SetSize(zombie.Character, zombie.SizeScale or 1)
	addModifiers(zombie)

	if location then
		zombie.Character:PivotTo(CFrame.new(location + Vector3.new(math.random(-25, 25), 4, math.random(-25, 25))))
	else
		local spawnAreas: { BasePart } = CollectionService:GetTagged("ZombieSpawnArea")
		local spawnArea = spawnAreas[math.random(1, #spawnAreas)]
		local spawnPosition = spawnArea.Position + Vector3.new(math.random(-25, 25), 4, math.random(-25, 25))
		zombie.Character:PivotTo(CFrame.new(spawnPosition))
	end

	zombie.Character:AddTag("Zombie")
	table.insert(zombies, zombie)
	return zombie
end

--[[
        Removes all zombies from the world.

        Cleans up zombie objects events with Maid service.
    ]]
function module.clearZombies()
	for _, zombie in zombies do
		if zombie.Destroy then
			zombie:Destroy()
		end
	end
	zombies = {}
	workspace.Zombies:ClearAllChildren()
end

--[[
        Removes a zombie from the world.

        Cleans up zombie object events with Maid service.
    ]]
local function CleanUpZombie(zombie)
	if zombie.Character then
		zombie.Character:Destroy()
	end

	if zombie.Destroy then
		zombie:Destroy()
	end

	local index = table.find(zombies, zombie)

	if index then
		table.remove(zombies, index)
	end
end

local function zombiesLoop()
	if #zombies <= 0 then
		return
	end

	for i, zombie in zombies do
		Promise.new(function()
			-- Check for invalid zombie state
			if not zombie.Character or not zombie.Humanoid then
				if not zombie.Character then
					warn("Zombie character not found")
				elseif not zombie.Humanoid then
					warn("Zombie humanoid not found")
				end

				zombie.Errors = (zombie.Errors or ZOMBIE_ERROR_START) + ZOMBIE_ERROR_INCREMENT

				if zombie.Errors >= ZOMBIE_ERROR_LIMIT then
					warn("Zombie error limit reached, destroying zombie")
					CleanUpZombie(zombie)
					return
				end
			end

			-- Check if zombie is dead
			if zombie.Humanoid.Health <= 0 then
				table.remove(zombies, i)
				if zombie.Destroy then
					zombie:Destroy()
				end
				return
			end

			-- Find target if needed
			local targetValid = zombie.Target
				and zombie.Target.Parent
				and Players:GetPlayerFromCharacter(zombie.Target.Parent)

			if not targetValid then
				zombie.Target = zombie:findTarget()
			end

			if not zombie.Target or not zombie.Target.Parent then
				return
			end

			local targetCharacter = zombie.Target.Parent
			local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")

			if not targetHumanoid or targetHumanoid.Health <= 0 then
				zombie.Target = nil
				return
			end

			-- Use ability if in range
			if zombie.useAbility and zombie:withinRange(zombie.AbilityRange) then
				zombie:useAbility()
			end

			-- Attack if possible
			local canAttack = tick() - zombie.LastAttacked > 2
				and not zombie.Humanoid.PlatformStand
				and zombie:withinRange(zombie.MeleeRange)
				and not zombie:blockedLineOfSight(targetCharacter.Head.Position)

			if canAttack then
				zombie.LastAttacked = tick()
				zombie:damageCharacter(targetCharacter)
			end

			-- Update pathfinding
			if not zombie.Pathfinding then
				zombie:Pathfind(zombie.Target.Position)
			end
		end):catch(function()
			-- Makes sure it's not a zombie character issue
			if zombie.Character and zombie.Humanoid then
				if zombie.Humanoid.Health <= 0 then
					-- Dead zombie
					table.remove(zombies, i)
					return
				else
					-- Pathfinding issue
					zombie.Pathfinding = false
					zombie.Target = nil
					return
				end
			end

			-- Zombie character issue
			warn("Zombie had a character issue, destroying zombie")
			CleanUpZombie(zombie)
		end)
	end
end

function module.init()
	requireZombieClasses()

	ReplicatedStorage.RemotesLegacy.SpawnAI.OnServerEvent:Connect(
		function(player, position: Vector3, zombieName: string)
			local zombie = module.spawnZombie(zombieName, position + Vector3.new(0, 4, 0))
			print(`{player.Name} spawned {zombie.Character.Name}`)
		end
	)

	Scheduler.AddToScheduler("Interval_0.2", "ZombieService", zombiesLoop)
end

return module
