local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Teams = game:GetService("Teams")

local BaseClass = require(ServerScriptService.Modules.AI.BaseClass)
local Ragdoll = require(ReplicatedStorage.Dependencies.Ragdoll)
local DataStore2 = require(ServerScriptService.Modules.DataStore2)
local classer = require(ServerScriptService.Modules.Player.Classer)
local Weather = require(ServerScriptService.Contents.Universal.Systems.Weather)
local store = require(ReplicatedStorage.Common.Store)

local module = {}
module.__index = module
setmetatable(module, BaseClass)

local function giveKillReward(zombie, zombieModel: Model)
	local killerTags = {}

	for _, killerTag in zombie.Humanoid:GetChildren() do
		if killerTag.Name == "creator" then
			if not table.find(killerTags, killerTag.Value) then
				table.insert(killerTags, killerTag.Value)
			end
		end
	end

	if #killerTags == 0 then
		return
	end

	local reward = math.round(zombie.Money / #killerTags)

	for _, killer in killerTags do
		local cash = killer:GetAttribute("Cash")
		local kills = killer:GetAttribute("Kills")
		local killsStore = DataStore2("Kills", killer)

		killer:SetAttribute("Cash", cash + reward)
		killer:SetAttribute("Kills", kills + 1)
		killsStore:Increment(1)

		local xpAward = zombie.Exp or 1

		if Weather.currentWeather == "BloodMoon" then
			xpAward *= 2
		end

		store:dispatch({
			type = "INCREMENT_EXP",
			userId = killer.UserId,
			increment = xpAward,
		})

		local state = store:getState().playerClass[killer.UserId]
		local requiredExperience = state.requiredExperience
		local experience = state.experience
		local level = state.level

		if experience >= requiredExperience and level < 10 then
			store:dispatch({
				type = "INCREMENT_LEVEL",
				userId = killer.UserId,
				increment = 1,
				requiredExperience = (level + 2)
					* classer.LEVELING_XP_REQUIREMENT
					* (level + 2) ^ classer.LEVELING_XP_EXPONENT,
			})
		end

		ReplicatedStorage.RemotesLegacy.KillCounter:FireClient(killer, zombieModel.Name, reward)
	end
end

--[[
    Creates a new zombie object with the given character model.
]]
function module.new(character: Model)
	local self = setmetatable(BaseClass.new(character), module)
	self.Target = nil
	self.LastAttacked = tick()
	self.MeleeRange = 4
	self.Exp = 1
	self.maid:GiveTask(self.Humanoid.Died:Once(function()
		giveKillReward(self, self.Character)
		self.Character.Parent = workspace.DeadZombies
		Ragdoll(self.Character)
		Debris:AddItem(self.Character, 120)
	end))
	local lastHealth = self.Humanoid.Health
	self.maid:GiveTask(self.Humanoid.HealthChanged:Connect(function(currentHealth)
		if currentHealth >= lastHealth then
			return
		end
		local attacker = self:getAttackerTarget()
		if not attacker then
			return
		end
		self.Target = attacker
	end))
	return self
end

function module:findTarget(): Part
	local target
	local distance = 2100
	for _, survivor: Player in Teams.Survivor:GetPlayers() do
		if not self.Character:FindFirstChild("Torso") then
			continue
		end
		if not survivor.Character then
			continue
		end
		if not survivor.Character:FindFirstChild("Humanoid") then
			continue
		end
		if survivor.Character.Humanoid.Health <= 0 then
			continue
		end
		local rootpart = survivor.Character:FindFirstChild("HumanoidRootPart")
		if not rootpart then
			continue
		end
		local magnitude = survivor:DistanceFromCharacter(self.Character.Torso.Position)
		if magnitude > distance then
			continue
		end
		target = rootpart
		distance = magnitude
	end
	return target
end

function module:getAttackerTarget(): Part
	local attackerTag = self.Humanoid:FindFirstChild("creator")
	if not attackerTag then
		return
	end
	local attacker = attackerTag.Value
	if not attacker then
		return
	end
	if not attacker.Character then
		return
	end
	if not attacker.Character:FindFirstChild("Humanoid") then
		return
	end
	if attacker.Character.Humanoid.Health <= 0 then
		return
	end
	local rootpart = attacker.Character:FindFirstChild("HumanoidRootPart")
	if not rootpart then
		return
	end
	return rootpart
end

function module:targetMoved(): boolean
	if not self.Target or not self.Destination then
		return
	end
	local movedDistance = (self.Target.Position - self.Destination).Magnitude
	return movedDistance > 10
end

function module:blockedLineOfSight(position: Vector3): RaycastResult
	if (self.Character.Torso.Position - self.Target.Position).Magnitude > 100 then
		return false
	end
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances =
		{ self.Character, self.Target.Parent, workspace.Landscape, workspace.Zombies, workspace.DeadZombies }
	return workspace:Raycast(self.Character.Head.Position, position - self.Character.Head.Position, raycastParams)
end

function module:withinRange(range: number): boolean
	return (self.Character.PrimaryPart.Position - self.Target.Position).Magnitude <= range
end

--[[
    Moves the NPC with `Humanoid:MoveTo()` behind by 5 studs in a random direction.
]]
function module:unstuck()
	self.Humanoid:MoveTo(
		self.Character.PrimaryPart.Position
			+ self.Character.PrimaryPart.CFrame.LookVector * -5
			+ Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
	)
end

local function hitPartIsBuildable(hitPart: BasePart)
	local folder = hitPart:FindFirstAncestorWhichIsA("Folder")
	if not folder then
		return
	end
	local model = hitPart:FindFirstAncestorWhichIsA("Model")
	if not model then
		return
	end
	return model
end

function module:damageBuild(build: Model)
	if tick() - self.LastAttacked < 2 then
		return
	end
	self.LastAttacked = tick()
	local health = build:GetAttribute("Health")
	if not health then
		return
	end
	local damage = math.clamp(self.Damage * 0.5, 1, 999)
	if health - damage <= 0 then
		build:Destroy()
	else
		build:SetAttribute("Health", health - damage)
	end
end

function module:damageCharacter(character: Model)
	local Humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not Humanoid then
		return
	end
	local protection = character:GetAttribute("Protection")
	if not protection then
		protection = 0
	end
	local damageResistance = character:GetAttribute("DamageResistance") or 0
	local damage =
		math.clamp((self.Damage - (protection * 0.35)) - (self.Damage * damageResistance / 100), self.Damage * 0.1, 999)
	Humanoid:TakeDamage(damage)
end

--[[
    Performs a pathfinding algorithm to the given destination.

    destination: The destination for the NPC to pathfind to.
]]
function module:Pathfind(destination: Vector3): nil
	if not self.Target then
		return
	end
	if not self.Target.Parent then
		self.Target = nil
		return
	end
	local Head = self.Target.Parent:FindFirstChild("Head")
	if not Head then
		self.Target = nil
		return
	end
	local lineOfSightRayResult = self:blockedLineOfSight(Head.Position)
	if not lineOfSightRayResult then
		self.Humanoid:MoveTo(self.Target.Position)
		return
	else
		if lineOfSightRayResult.Distance < 4 then
			local build = hitPartIsBuildable(lineOfSightRayResult.Instance)
			if build then
				self:damageBuild(build)
			end
			self:unstuck()
			return
		end
	end
	local pathCancelled = false
	self.maid:GiveTask(function()
		pathCancelled = true
		self.Pathfinding = false
	end)
	self.Path:ComputeAsync(self.Character.PrimaryPart.Position, destination)
	if self.Path.Status ~= Enum.PathStatus.Success then
		-- Move to the player, regardless is pathfinding fails.
		return self.Humanoid:MoveTo(destination)
	end
	self.Pathfinding = true
	local waypoints = self.Path:GetWaypoints()
	self.Waypoints = waypoints
	self.Destination = destination
	for _, waypoint: PathWaypoint in waypoints do
		if pathCancelled then
			return
		end
		if not self:blockedLineOfSight(self.Target.Parent.Head.Position) then
			break
		end
		if self:targetMoved() then
			break
		end
		if waypoint.Action == Enum.PathWaypointAction.Jump then
			self.Humanoid.Jump = true
		else
			local travelDistance = (waypoint.Position - self.Character.PrimaryPart.Position).Magnitude * 0.6
			local travelTime = travelDistance / self.Humanoid.WalkSpeed
			self.Humanoid:MoveTo(waypoint.Position)
			task.wait(travelTime)
			-- local timeout = tick()
			-- self.Humanoid:MoveTo(waypoint.Position)
			-- repeat task.wait() until (self.Character.PrimaryPart.Position - waypoint.Position).Magnitude <= 4 or tick() - timeout >= 1
		end
	end
	if not pathCancelled then
		self.Waypoints = nil
		self.Destination = nil
		self.Pathfinding = false
	end
end

return module
