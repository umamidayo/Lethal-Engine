local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ZombieClass = require(ServerScriptService.Modules.AI.ZombieClass)
local ZombieEvent = ReplicatedStorage.RemotesLegacy.Zombie_Event
local module = {}
module.__index = module
setmetatable(module, ZombieClass)

local function characterIsVisible(character, OriginPart)
	local explosiveParams = RaycastParams.new()
	explosiveParams.FilterType = Enum.RaycastFilterType.Blacklist
	explosiveParams.FilterDescendantsInstances = {character, workspace.Landscape, workspace.Zombies, workspace.DeadZombies}
	local rayResult = workspace:Raycast(OriginPart.Position, (character.Head.Position - OriginPart.Position), explosiveParams)
	return rayResult == nil
end

local function buildingIsVisible(build: Model, hitPart: BasePart, OriginPart: BasePart)
	local explosiveParams = RaycastParams.new()
	explosiveParams.FilterType = Enum.RaycastFilterType.Blacklist
	explosiveParams.FilterDescendantsInstances = {build, workspace.Landscape, workspace.Zombies, workspace.DeadZombies}
	local rayResult = workspace:Raycast(OriginPart.Position, (hitPart.Position - OriginPart.Position), explosiveParams)
	return rayResult == nil
end

local function explode(Object, Radius, SplashDamage, damagePlayersOnly)
    local Explosion = Instance.new("Explosion")
	Explosion.Visible = false
	Explosion.BlastRadius = Radius * 0.875
	Explosion.BlastPressure = 0
	Explosion.Position = Object.Position
	Explosion.Parent = Object
	Debris:AddItem(Explosion, 3)

	local Hits = {}

	Explosion.Hit:Connect(function(hit, distance)
		if not hit or not hit.Parent then return end
		local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")

		if humanoid then
			if Hits[humanoid] == true then return end
			if not characterIsVisible(hit.Parent, Object) then return end
			Hits[humanoid] = true

			if humanoid.Parent.Parent == workspace.Zombies then
				if damagePlayersOnly then return end
			end

			local player = Players:GetPlayerFromCharacter(humanoid.Parent)

			if player and player:GetAttribute("Protection") then
				SplashDamage = math.clamp(SplashDamage - (player:GetAttribute("Protection") * 0.35), SplashDamage * 0.4, 999)
			end

			local DistanceFactor = distance/Radius
			DistanceFactor = 1 - DistanceFactor

			local HitDamage = DistanceFactor * SplashDamage

			humanoid:TakeDamage(HitDamage)

			if humanoid.Health <= 0 then
				task.wait(0.1)
				hit:ApplyImpulse((hit.Position - Explosion.Position).Unit * distance * 10)
			end
		end

		if hit.Parent:GetAttribute("Health") then
			if Hits[hit.Parent] == true then return end
			Hits[hit.Parent] = true

			if not buildingIsVisible(hit.Parent, hit, Object) then return end

			local DistanceFactor = distance/Radius
			DistanceFactor = 1 - DistanceFactor

			local HitDamage = DistanceFactor * SplashDamage
			hit.Parent:SetAttribute("Health", hit.Parent:GetAttribute("Health") - HitDamage)

			if hit.Parent and hit.Parent:GetAttribute("Health") <= 0 then
				game.Debris:AddItem(hit.Parent, 0)
			end
		end
	end)
end

function module.new(character: Model)
    local self = setmetatable(ZombieClass.new(character), module)
    self.Humanoid.WalkSpeed = 16
    self.Humanoid.JumpPower = 30
	self.Humanoid.MaxHealth = 2000
    self.Humanoid.Health = 2000
    self.Money = 500
	self.Exp = 8
    self.Damage = 40
	self.MeleeRange = 8
	self.SizeScale = 1.4
    self.maid:GiveTask(self.Humanoid.Died:Connect(function()
		ZombieEvent:FireAllClients("ZombieFX", {"AbominationExplode", self.Character})
		task.delay(2, function()
			explode(self.Character.Torso, 20, 100, false)
		end)
	end))
	return self
end

return module