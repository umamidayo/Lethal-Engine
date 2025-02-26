local module = {}
module.__index = module

local LEVELING_XP_REQUIREMENT = 20
local LEVELING_XP_EXPONENT = 2

-- Creates a new class object.
function module.new(className: string, currentLevel: number, currentExp: number)
    local self = setmetatable({}, module)
    self.name = className
    self.level = currentLevel
    self.experience = currentExp
    self.levelUpXP = (self.level + 1) * LEVELING_XP_REQUIREMENT * (self.level + 1) ^ LEVELING_XP_EXPONENT
    return self
end

-- Increases the current level and updates the required XP to level up.
function module:levelup()
    self.level += 1
    self.levelUpXP = (self.level + 1) * LEVELING_XP_REQUIREMENT * (self.level + 1) ^ LEVELING_XP_EXPONENT
    self.currentExp = 0
    return self.level, self.levelUpXP
end

function module:Destroy()
    setmetatable(self, nil)
end

return module