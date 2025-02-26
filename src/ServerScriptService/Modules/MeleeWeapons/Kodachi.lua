local ServerScriptService = game:GetService("ServerScriptService")
local MeleeClass = require(ServerScriptService.Modules.MeleeWeapons.MeleeClass)

local module = {}

local Stats: MeleeClass.WeaponStats = {
    Damage = 500,
}

function module.new()
    local weapon = MeleeClass.new(Stats)

    weapon.HitBonus = module.LifeSteal

    return weapon
end

function module.LifeSteal(player: Player)
    if not player.Character then return end
    local character = player.Character
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    humanoid.Health += humanoid.MaxHealth * 0.07
end

return module
