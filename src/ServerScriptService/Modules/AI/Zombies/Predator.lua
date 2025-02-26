local ServerScriptService = game:GetService("ServerScriptService")
local ZombieClass = require(ServerScriptService.Modules.AI.ZombieClass)
local module = {}
module.__index = module
setmetatable(module, ZombieClass)

function module.new(character: Model)
    local self = setmetatable(ZombieClass.new(character), module)
    self.Humanoid.WalkSpeed = 25
    self.Humanoid.JumpPower = 40
    self.Humanoid.MaxHealth = 500
    self.Humanoid.Health = 500
    self.Money = 250
    self.Exp = 5
    self.Damage = 50
    self.MeleeRange = 6
    self.SizeScale = 1.3
    return self
end

return module