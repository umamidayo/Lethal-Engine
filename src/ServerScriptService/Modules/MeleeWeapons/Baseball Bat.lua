local ServerScriptService = game:GetService("ServerScriptService")
local MeleeClass = require(ServerScriptService.Modules.MeleeWeapons.MeleeClass)

local module = {}

local Stats: MeleeClass.WeaponStats = {
    Damage = 30,
}

function module.new()
    local weapon = MeleeClass.new(Stats)

    weapon.HitBonus = module.Finisher

    return weapon
end

local function ChanceStagger(targetHumanoid: Humanoid)
    if targetHumanoid.PlatformStand then return end

    local chance = math.random(1, 2)
    if chance == 1 then return end

    targetHumanoid.PlatformStand = true
    task.delay(3, function()
        targetHumanoid.PlatformStand = false
    end)
end

function module.Finisher(player: Player, targetHumanoid: Humanoid)
    if not targetHumanoid.PlatformStand then
        return ChanceStagger(targetHumanoid)
    end

    targetHumanoid:TakeDamage(targetHumanoid.MaxHealth)
end

return module
