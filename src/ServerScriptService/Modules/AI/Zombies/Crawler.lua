local ServerScriptService = game:GetService("ServerScriptService")
local ZombieClass = require(ServerScriptService.Modules.AI.ZombieClass)
local module = {}
module.__index = module
setmetatable(module, ZombieClass)

function module.new(character: Model)
    local self = setmetatable(ZombieClass.new(character), module)
    self.Humanoid.WalkSpeed = 18
    self.Humanoid.JumpPower = 40
    self.Humanoid.MaxHealth = 135
    self.Humanoid.Health = 135
    self.Money = 30
    self.Exp = 1
    self.Damage = 25
    self.AbilityRange = 15
    self.SizeScale = 1
    return self
end

function module:useAbility()
    if math.random(1, 8) ~= 1 then return end
    self.Humanoid.Jump = true
    self.Character.PrimaryPart.AssemblyLinearVelocity = (self.Target.Position - self.Character.PrimaryPart.Position).Unit * 65
end

return module
