local module = {}
module.__index = module

export type WeaponStats = {
    Damage: number,
}

function module.new(newWeaponStats: WeaponStats)
    local weapon = {
        Damage = newWeaponStats.Damage,
    }

    return setmetatable(weapon, module)
end

return module
