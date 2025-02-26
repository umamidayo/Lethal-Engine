local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Common.Libraries.Maid)
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)
local VectorLib = require(ReplicatedStorage.Common.Libraries.VectorLib)

local LineOfSight = { workspace.Landscape, workspace.DeadZombies, workspace.Zombies }

local module = {}
module.__index = module

module.ScheduledShots = {}

function module.new(ownerName: string, model: Model)
	local player = Players:FindFirstChild(ownerName)
	local sentryLevel = player and player.Character:GetAttribute("SentryLevel") or 0
	local damage = 8
	if sentryLevel >= 1 then
		damage *= 1.15
	end
	local sentry = {
		Barrel = model:WaitForChild("Barrel"),
		Owner = ownerName,
		Model = model,
		Id = HttpService:GenerateGUID(false),
		Target = nil,
		Damage = damage,
		MaxRange = 200,
		FireMode = "Semi",
		Maid = Maid.new(),
		sentryLevel = sentryLevel,
		canBurn = sentryLevel >= 2,
	}

	sentry.Maid:GiveTask(sentry.Model.Destroying:Connect(function()
		sentry:Stop()
		sentry:Destroy()
	end))

	return setmetatable(sentry, module)
end

function module:TargetIsAlive()
	local humanoid = self.Target:FindFirstChildWhichIsA("Humanoid")
	return humanoid and humanoid.Health > 0
end

function module:FindTarget()
	local zombies: { Model } = CollectionService:GetTagged("Zombie")
	if #zombies == 0 then
		return
	end

	local raycastIgnore = { self.Model, zombies, unpack(LineOfSight) }

	for _, zombie in zombies do
		local humanoid = zombie:FindFirstChildWhichIsA("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			continue
		end

		if not VectorLib.inRange(self.Barrel.Position, zombie.PrimaryPart.Position, self.MaxRange) then
			continue
		end

		if not VectorLib.inLineOfSight(self.Barrel.Position, zombie.PrimaryPart.Position, raycastIgnore) then
			continue
		end

		return zombie
	end
end

function module:Start()
	Scheduler.AddToScheduler("Interval_0.2", self.Model, function()
		if not self.Model then
			self:Stop()
			self:Destroy()
		end

		if not self.Target or (self.Target and not self:TargetIsAlive()) then
			self.Target = self:FindTarget()
		else
			if
				not VectorLib.inLineOfSight(
					self.Barrel.Position,
					self.Target.PrimaryPart.Position,
					{ self.Model, self.Target, unpack(LineOfSight) }
				)
			then
				self.Target = self:FindTarget()
			end
		end

		if not self.Target then
			return
		end

		module.ScheduledShots[self.Id] = {
			Model = self.Model,
			Target = self.Target,
		}

		local Humanoid = self.Target:FindFirstChildWhichIsA("Humanoid")
		if Humanoid and Humanoid.Health > 0 then
			Humanoid:TakeDamage(self.Damage)
			if self.canBurn and not self.Target:HasTag("Burning") then
				self.Target:AddTag("Burning")
				if self.sentryLevel >= 3 then
					self.Target:AddTag("FireSpread")
				end
			end
		end
	end)
end

function module:Stop()
	Scheduler.RemoveFromScheduler("Interval_0.2", self.Model)
end

function module:Destroy()
	self.Maid:DoCleaning()
	setmetatable(self, nil)
end

return module
