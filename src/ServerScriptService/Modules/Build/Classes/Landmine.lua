local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BuildClass = require(ServerScriptService.Modules.Build.Classes.BuildClass)
local Sounds = require(ReplicatedStorage.Common.Sounds)
local TrapsModule = require(ServerScriptService.Modules.Build.TrapsModule)

local BigPoison: ParticleEmitter = ReplicatedStorage.Entities.Effects.Particles.BigPoison

local module = {}
module.__index = module
setmetatable(module, BuildClass)

local function toxicCloud(model: Model, explosiveTrapLevel: number)
	local poisonPart = Instance.new("Part")
	poisonPart.Name = "PoisonCloud"
	poisonPart.Anchored = true
	poisonPart.CanCollide = false
	poisonPart.CanTouch = false
	poisonPart.CanQuery = false
	poisonPart.Shape = Enum.PartType.Ball
	poisonPart.Size = Vector3.one * 30
	poisonPart.Transparency = 1
	poisonPart:PivotTo(model.PrimaryPart.CFrame)
	poisonPart.Parent = workspace
	local poisonGas = BigPoison:Clone()
	poisonGas.Parent = poisonPart
	Sounds.playFromPart("GasLeak", poisonPart, {
		RollOffMaxDistance = 100,
	})
	Debris:AddItem(poisonPart, 3)
	task.delay(2, function()
		poisonGas.Enabled = false
	end)

	local zombies = CollectionService:GetTagged("Zombie")
	for _, zombie in zombies do
		local primaryPart = zombie.PrimaryPart
		if not primaryPart then
			continue
		end

		local distance = (primaryPart.Position - model.PrimaryPart.Position).Magnitude
		if distance < 40 then
			if explosiveTrapLevel >= 3 then
				zombie:AddTag("LethalGas")
				if explosiveTrapLevel >= 5 then
					zombie:AddTag("Contagion")
				end
			else
				zombie:AddTag("Toxic")
			end
		end
	end
end

function module.new(model: Model, player: Player)
	local self = BuildClass.new(model, player)
	setmetatable(self, module)
	self.debounce = false
	self.explosiveTrapLevel = player.Character:GetAttribute("ExplosiveTrapLevel") or 0
	self.armedSound = self.model.PrimaryPart.ArmedSound
	self.maid:GiveTask(self.model.PrimaryPart.Touched:Connect(function(hit)
		if self.debounce then
			return
		end
		local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end
		if Players:GetPlayerFromCharacter(humanoid.Parent) then
			return
		end
		self.debounce = true
		self.armedSound:Play()
		self.model:SetAttribute("Cost", 0)
		task.wait(0.3)
		if self.explosiveTrapLevel >= 2 then
			toxicCloud(self.model, self.explosiveTrapLevel)
		end
		local damage = 20
		if self.explosiveTrapLevel >= 1 then
			damage *= 1.25
		end
		TrapsModule.Explode(self.model, damage, 2000)
		ReplicatedStorage.RemotesLegacy.GrenadeClientEvent:FireAllClients(self.model.PrimaryPart)
		task.wait(3)
		self:Destroy()
	end))
	return self
end

return module
