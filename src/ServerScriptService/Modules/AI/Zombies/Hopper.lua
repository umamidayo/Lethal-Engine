local ServerScriptService = game:GetService("ServerScriptService")
local ZombieClass = require(ServerScriptService.Modules.AI.ZombieClass)
local module = {}
module.__index = module
setmetatable(module, ZombieClass)

function module.new(character: Model)
    local self = setmetatable(ZombieClass.new(character), module)
    self.Humanoid.WalkSpeed = 16
    self.Humanoid.JumpPower = 60
    self.Humanoid.MaxHealth = 25
    self.Humanoid.Health = 25
    self.Money = 50
    self.Exp = 1
    self.Damage = 15
    self.SizeScale = 0.65
    return self
end

return module
