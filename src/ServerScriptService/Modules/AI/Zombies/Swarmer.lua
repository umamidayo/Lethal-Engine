local ServerScriptService = game:GetService("ServerScriptService")

local ZombieClass = require(ServerScriptService.Modules.AI.ZombieClass)

local module = {}
module.__index = module
setmetatable(module, ZombieClass)

function module.new(character: Model)
	local self = setmetatable(ZombieClass.new(character), module)
	self.Humanoid.WalkSpeed = 16
	self.Humanoid.JumpPower = 40
	self.Humanoid.MaxHealth = 100
	self.Humanoid.Health = 100
	self.Money = 20
	self.Exp = 1
	self.Damage = 25
	self.SizeScale = 1
	self.lastHealth = self.Humanoid.Health
	self.maid:GiveTask(self.Humanoid.HealthChanged:Connect(function(health)
		if health < self.lastHealth then
			self.Humanoid.PlatformStand = true
			task.delay(1, function()
				if not self.Humanoid then
					return
				end
				self.Humanoid.PlatformStand = false
			end)
		end
	end))
	return self
end

return module
