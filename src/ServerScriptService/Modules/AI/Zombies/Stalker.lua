local ServerScriptService = game:GetService("ServerScriptService")
local ZombieClass = require(ServerScriptService.Modules.AI.ZombieClass)
local module = {}
module.__index = module
setmetatable(module, ZombieClass)

function module.new(character: Model)
    local self = setmetatable(ZombieClass.new(character), module)
    self.Humanoid.WalkSpeed = 12
    self.Humanoid.JumpPower = 40
    self.Humanoid.MaxHealth = 100
    self.Humanoid.Health = 100
    self.Money = 30
    self.Exp = 2
    self.Damage = 40
    self.SizeScale = 1
    return self
end

return module
