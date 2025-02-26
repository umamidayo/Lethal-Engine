local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BuildClass = require(ServerScriptService.Modules.Build.Classes.BuildClass)
local Sounds = require(ReplicatedStorage.Common.Sounds)

local module = {}
module.__index = module
setmetatable(module, BuildClass)

local function shockZombies(firstHit: BasePart, barbedWireLevel: number)
	local firstZombie = firstHit.Parent
	local nearbyZombies = {
		[firstZombie] = 0,
	}

	local zombies = CollectionService:GetTagged("Zombie")
	local range = barbedWireLevel >= 3 and 20 or 10
	for _, zombie in zombies do
		if not zombie.PrimaryPart then
			continue
		end

		local distance = (zombie.PrimaryPart.Position - firstHit.Position).Magnitude
		if distance <= range then
			nearbyZombies[zombie] = distance
		end
	end

	Sounds.playFromPart("ElectricShock", firstHit, {
		RollOffMaxDistance = 100,
	})

	local beam: Beam = ReplicatedStorage.Entities.Effects.Beams.ElectricBeam
	local sparks: ParticleEmitter = ReplicatedStorage.Entities.Effects.Particles.Sparks
	local lastZombie = firstZombie

	-- Sort zombies by distance to create chain
	local sortedZombies = {}
	for zombie, distance in nearbyZombies do
		table.insert(sortedZombies, { zombie = zombie, distance = distance })
	end
	table.sort(sortedZombies, function(a, b)
		return a.distance < b.distance
	end)

	-- Create chain of beams
	for _, zombieData in sortedZombies do
		local zombie = zombieData.zombie

		local humanoid = zombie:FindFirstChild("Humanoid")
		if humanoid then
			local damage = barbedWireLevel >= 3 and 0.2 or 0.1
			humanoid:TakeDamage(humanoid.MaxHealth * damage)
		end

		local newSparks = sparks:Clone()
		newSparks.Parent = zombie.PrimaryPart
		Debris:AddItem(newSparks, 2)

		if zombie ~= firstZombie then
			local newBeam = beam:Clone()
			local attachment0 = lastZombie.Torso:FindFirstChild("WaistCenterAttachment")
			local attachment1 = zombie.Torso:FindFirstChild("WaistCenterAttachment")
			if attachment0 and attachment1 then
				newBeam.Attachment0 = attachment0
				newBeam.Attachment1 = attachment1
				newBeam.Parent = zombie.PrimaryPart
			end

			lastZombie = zombie
			Debris:AddItem(newBeam, 0.25)
		end
	end
end

function module.new(model: Model, player: Player)
	local self = BuildClass.new(model, player)
	setmetatable(self, module)
	self.hitSound = self.model.PrimaryPart.BarbedWireSound
	self.debounce = tick()

	local barbedWireLevel: number = player.Character:GetAttribute("BarbedWireLevel") or 0
	local canShock = barbedWireLevel >= 2

	if canShock then
		self.model.SpiralBarbs.Sparks.Enabled = true
	end

	self.maid:GiveTask(self.model.PrimaryPart.Touched:Connect(function(hit)
		if not hit or not hit.Parent then
			return
		end

		local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end

		if tick() - self.debounce < 1 then
			return
		else
			self.debounce = tick()
		end

		self.hitSound:Play()
		if Players:GetPlayerFromCharacter(hit.Parent) then
			humanoid:TakeDamage(10)
		else
			local damage = 50
			if barbedWireLevel >= 1 then
				damage *= 1.25
			end
			humanoid:TakeDamage(damage)
			if canShock then
				shockZombies(hit, barbedWireLevel)
			end
		end
	end))

	return self
end

return module
