local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local Teams = game:GetService("Teams")

local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)
PhysicsService:RegisterCollisionGroup("Zombies")
PhysicsService:CollisionGroupSetCollidable("Zombies", "Zombies", true)

local ZombieClass = require(ServerScriptService.Modules.Zombies.ZombieClass)
local ZombieFunctions = require(ServerScriptService.Modules.Zombies.ZombieFunctions)

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local zombies = {}
local zombieInfo = {}
local targets = {}

local module = {}

-- Checks the zombie's pathing and cooldowns before doing anything.
local function meetsPathfindingConditions(zombie: Model)
	if #Teams.Survivor:GetPlayers() <= 0 then
		return
	end
	if ZombieFunctions.onPath[zombie] == true then
		return
	end
	if ZombieFunctions.waitTimes[zombie] == nil then
		ZombieFunctions.waitTimes[zombie] = 1
	end
	if
		ZombieFunctions.lastCommanded[zombie] ~= nil
		and (tick() - ZombieFunctions.lastCommanded[zombie]) < ZombieFunctions.waitTimes[zombie]
	then
		return
	end
	return true
end

local function targetIsAlive(targetRootPart: BasePart)
	if not targetRootPart or not targetRootPart.Parent then
		return
	end
	if not targetRootPart.Parent:FindFirstChildWhichIsA("Humanoid") then
		return
	end
	return targetRootPart.Parent.Humanoid.Health > 0
end

local function onHeartbeat()
	for _, zombie: Model in zombies do
		if not meetsPathfindingConditions(zombie) then
			continue
		end
		ZombieFunctions.lastCommanded[zombie] = tick()

		-- Setup zombie variables in a table for pathfinding, reducing FindFirstChild calls.
		if zombieInfo[zombie] == nil then
			zombieInfo[zombie] = {
				humanoid = zombie:FindFirstChild("Humanoid") :: Humanoid,
				rootpart = zombie:FindFirstChild("HumanoidRootPart") :: BasePart,
				head = zombie:FindFirstChild("Head") :: BasePart,
			}
		end

		-- Race condition check: Sometimes network latency causes issues with zombieInfo.
		if
			zombieInfo[zombie].humanoid == nil
			or zombieInfo[zombie].rootpart == nil
			or zombieInfo[zombie].head == nil
		then
			continue
		end
		if zombieInfo[zombie].humanoid.Health <= 0 then
			continue
		end

		if targets[zombie] ~= nil then
			if not targetIsAlive(targets[zombie]) then
				targets[zombie] = nil
			end
		end

		-- When damaged, switches to attacker as the target.
		local killtag: ObjectValue = zombieInfo[zombie].humanoid:FindFirstChild("creator")

		if killtag then
			local player: Player = killtag.Value
			if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				if player.Character.Humanoid.Health > 0 then
					targets[zombie] = player.Character.HumanoidRootPart
				end
			end
		end

		-- Checking for valid targets.
		if targets[zombie] == nil and #Teams.Survivor:GetPlayers() > 0 then
			targets[zombie] = ZombieFunctions.FindTarget(zombieInfo[zombie].rootpart, 2100)
		end

		if targets[zombie] == nil then
			zombieInfo[zombie].humanoid:MoveTo(zombieInfo[zombie].rootpart.Position)
			ZombieFunctions.waitTimes[zombie] = 1
			warn(script.Name .. " - Unable to acquire a valid target.")
			continue
		end

		local targetHead: BasePart

		if targets[zombie] ~= nil and targets[zombie].Parent ~= nil then
			targetHead = targets[zombie].Parent:FindFirstChild("Head")
		end

		if not targetHead then
			zombieInfo[zombie].humanoid:MoveTo(zombieInfo[zombie].rootpart.Position)
			ZombieFunctions.waitTimes[zombie] = 1
			warn(script.Name .. " - Target's character not found.")
			continue
		end

		local additionalWaitTime = 0
		local magnitude = (zombieInfo[zombie].rootpart.Position - targets[zombie].Position).Magnitude
		local heightDiff = targets[zombie].Position.Y - zombieInfo[zombie].rootpart.Position.Y

		-- TODO: Move to client side and redo.
		if magnitude < ZombieClass.Classes[zombie.Name].MeleeRange and math.abs(heightDiff) < 3 then
			if not zombieInfo[zombie].humanoid.PlatformStand then
				if zombie:GetAttribute("Attacking") ~= true then
					zombie:SetAttribute("Attacking", true)
					additionalWaitTime += 0.5
					task.delay(1, function()
						zombie:SetAttribute("Attacking", false)
					end)
				end
			end
		end

		if
			ZombieClass.Classes[zombie.Name].AbilityRange ~= nil
			and magnitude < ZombieClass.Classes[zombie.Name].AbilityRange
		then
			if ZombieClass.Classes[zombie.Name].AttackFunction then
				ZombieClass.Classes[zombie.Name].AttackFunction(zombie, targets[zombie])
				additionalWaitTime += 0.5
			end
		end

		if zombieInfo[zombie] ~= nil and zombieInfo[zombie].humanoid ~= nil then
			zombieInfo[zombie].humanoid:MoveTo(targets[zombie].Position)
		else
			warn(script.Name .. " - Unable to move zombie humanoid: ZombieInfo and/or humanoid does not exist.")
			continue
		end

		-- Below is raycasting line of sight: Determines pathfinding or basic Humanoid:MoveTo().

		if ZombieFunctions.lastRaycast[zombie] ~= nil and tick() - ZombieFunctions.lastRaycast[zombie] < 1 then
			if zombieInfo[zombie] ~= nil and zombieInfo[zombie].humanoid ~= nil then
				ZombieFunctions.waitTimes[zombie] =
					math.clamp(((magnitude / zombieInfo[zombie].humanoid.WalkSpeed) * 0.2) + additionalWaitTime, 0.2, 5)
			else
				warn(script.Name .. " - Unable to adjust zombie wait time: ZombieInfo and/or humanoid does not exist.")
			end
			continue
		end

		ZombieFunctions.lastRaycast[zombie] = tick()

		-- With the target in raycasting range, it will cause the zombie to move back (Stuck preventative). Adding the character to the filter solves this.
		local player = Players:GetPlayerFromCharacter(targets[zombie])

		if player and player.Character then
			rayParams.FilterDescendantsInstances =
				{ zombies, player.Character, workspace.Landscape, workspace.Forcefields.NoBuild }
		else
			rayParams.FilterDescendantsInstances = { zombies, workspace.Landscape, workspace.Forcefields.NoBuild }
		end

		local rayResult = workspace:Raycast(
			zombieInfo[zombie].head.Position,
			(targetHead.Position - zombieInfo[zombie].head.Position).Unit * 20,
			rayParams
		)

		if not rayResult then
			ZombieFunctions.waitTimes[zombie] =
				math.clamp(((magnitude / zombieInfo[zombie].humanoid.WalkSpeed) * 0.2) + additionalWaitTime, 0.2, 5)
			continue
		end

		if (targets[zombie].Position - zombieInfo[zombie].rootpart.Position).Magnitude < 600 then
			ZombieFunctions.paths[zombie]:ComputeAsync(zombieInfo[zombie].rootpart.Position, targets[zombie].Position)
		else
			additionalWaitTime += 0.5
			ZombieFunctions.waitTimes[zombie] =
				math.clamp(((magnitude / zombieInfo[zombie].humanoid.WalkSpeed) * 0.2) + additionalWaitTime, 0.2, 5)
			continue
		end

		if ZombieFunctions.paths[zombie] == nil or ZombieFunctions.paths[zombie].Status ~= Enum.PathStatus.Success then
			if zombieInfo[zombie] ~= nil and zombieInfo[zombie].humanoid ~= nil then
				additionalWaitTime += 0.5
				zombieInfo[zombie].humanoid:MoveTo(
					zombieInfo[zombie].rootpart.Position
						+ (zombieInfo[zombie].rootpart.CFrame.LookVector * -10)
						+ (zombieInfo[zombie].rootpart.CFrame.RightVector * 10 * math.random(-1, 1))
				)
			else
				warn(script.Name .. " - Unable to adjust path: Zombie Info and/or humanoid does not exist.")
				continue
			end
			ZombieFunctions.waitTimes[zombie] =
				math.clamp(((magnitude / zombieInfo[zombie].humanoid.WalkSpeed) * 0.2) + additionalWaitTime, 0.2, 5)
		end

		if ZombieFunctions.paths[zombie] and ZombieFunctions.paths[zombie].Status == Enum.PathStatus.Success then
			ZombieFunctions.onPath[zombie] = true

			local waypoints = ZombieFunctions.paths[zombie]:GetWaypoints()
			local unstuckAttempts = 0

			for i, waypoint: PathWaypoint in waypoints do
				zombieInfo[zombie].humanoid:MoveTo(waypoint.Position)

				if waypoint.Action == Enum.PathWaypointAction.Jump then
					zombieInfo[zombie].humanoid.Jump = true
				end

				local timeout = tick()

				repeat
					task.wait(0.1)
				until not zombieInfo[zombie]
					or (waypoint.Position - zombieInfo[zombie].rootpart.Position).Magnitude < 4
					or (tick() - timeout) > 1

				if not zombieInfo[zombie] then
					break
				end

				if tick() - timeout > 1 then
					unstuckAttempts += 1

					if unstuckAttempts >= 5 then
						break
					end
				end

				if not targets[zombie] then
					break
				end

				if i % 2 == 1 then
					continue
				end

				local differentTarget = ZombieFunctions.FindTarget(zombieInfo[zombie].rootpart, 500)

				if differentTarget and differentTarget ~= targets[zombie] then
					break
				end

				rayParams.FilterDescendantsInstances =
					{ zombie, targets[zombie].Parent, workspace.Landscape, workspace.Forcefields.NoBuild }

				rayResult = workspace:Raycast(
					zombieInfo[zombie].head.Position,
					(targetHead.Position - zombieInfo[zombie].head.Position).Unit * 20,
					rayParams
				)

				if not rayResult then
					break
				end

				if
					i > #waypoints / 2
					and (targets[zombie].Position - waypoints[#waypoints].Position).Magnitude > 20
				then
					break
				end
			end

			ZombieFunctions.onPath[zombie] = false
		end
	end
end

function module.init()
	workspace.Zombies.ChildAdded:Connect(function(zombie)
		local class = zombie.Name
		local attacked, player

		ZombieFunctions.SetupZombie(zombie, class)

		local humanoid: Humanoid = zombie:WaitForChild("Humanoid")
		local rootpart: BasePart = zombie:WaitForChild("HumanoidRootPart")

		for i, v: BasePart in zombie:GetDescendants() do
			if not v:IsA("BasePart") then
				continue
			end
			v.CollisionGroup = "Zombies"
		end

		local connection = rootpart.Touched:Connect(function(hit)
			if humanoid.PlatformStand then
				return
			end
			if attacked ~= nil and (tick() - attacked) < 1 then
				return
			end

			if hit.Parent:GetAttribute("Health") then
				attacked = tick()
				hit.Parent:SetAttribute(
					"Health",
					hit.Parent:GetAttribute("Health")
						- ((ZombieClass.Classes[class]["Damage"] + ZombieFunctions.damageModifier) * 0.2)
				)

				local damageSound

				if SoundService.BuildDamage[tostring(hit.Material)] ~= nil then
					damageSound = SoundService.BuildDamage[tostring(hit.Material)]:Clone()
				else
					damageSound = SoundService.BuildDamage["Enum.Material.Plastic"]:Clone()
				end

				damageSound.PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
				damageSound.Parent = hit
				damageSound:Destroy()

				if hit.Parent and hit.Parent:GetAttribute("Health") <= 0 then
					hit.Parent:Destroy()
				end
			elseif hit.Parent:FindFirstChild("Humanoid") then
				player = Players:GetPlayerFromCharacter(hit.Parent)
				if not player then
					return
				end
				attacked = tick()

				local damage = ZombieClass.Classes[class]["Damage"] + ZombieFunctions.damageModifier

				if player:GetAttribute("Protection") then
					damage = math.clamp(damage - (player:GetAttribute("Protection") * 0.35), damage * 0.4, 999)
				end

				player.Character.Humanoid:TakeDamage(damage)
			end
		end)

		humanoid.Died:Once(function()
			if ZombieClass.Classes[zombie.Name]["DeathFunction"] then
				ZombieClass.Classes[zombie.Name]["DeathFunction"](zombie)
			end

			if connection then
				connection:Disconnect()
			end

			ZombieFunctions.lastCommanded[zombie] = nil
			ZombieFunctions.waitTimes[zombie] = nil
			ZombieFunctions.lastRaycast[zombie] = nil
			ZombieFunctions.onPath[zombie] = nil
			ZombieFunctions.paths[zombie] = nil
			targets[zombie] = nil
			zombieInfo[zombie] = nil

			local index = table.find(zombies, zombie)

			if index then
				table.remove(zombies, index)
			end
		end)

		zombie.Destroying:Once(function()
			if connection then
				connection:Disconnect()
			end

			ZombieFunctions.lastCommanded[zombie] = nil
			ZombieFunctions.waitTimes[zombie] = nil
			ZombieFunctions.lastRaycast[zombie] = nil
			ZombieFunctions.onPath[zombie] = nil
			ZombieFunctions.paths[zombie] = nil
			targets[zombie] = nil
			zombieInfo[zombie] = nil

			local index = table.find(zombies, zombie)

			if index then
				table.remove(zombies, index)
			end
		end)

		table.insert(zombies, zombie)
	end)

	Scheduler.AddToScheduler("Interval_0.2", "ZombieController", onHeartbeat)
end

return module
