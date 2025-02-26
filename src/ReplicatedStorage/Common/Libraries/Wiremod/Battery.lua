local Wiremod = require(script.Parent.Wiremod)

local module = {}
module.__index = module
setmetatable(module, Wiremod)

function module.new(ownerName: string, model: Model, buildObject: {})
    local Battery = Wiremod.new(ownerName, model)
    setmetatable(Battery, module)

    Battery.ObjectType = "Battery"
    Battery.Model = model
    Battery.Model:AddTag("WiremodObject")
    Battery.buildObject = buildObject

    return Battery
end

function module:IncrementEnergy(amount: number)
    local Energy = self.Model:GetAttribute("Energy")
    local MaxEnergy = self.Model:GetAttribute("MaxEnergy")

    if Energy + amount >= MaxEnergy then
        self.Model:SetAttribute("Energy", MaxEnergy)
    else
        self.Model:SetAttribute("Energy", Energy + amount)
    end
end

function module:DecrementEnergy(amount: number)
    local Energy = self.Model:GetAttribute("Energy")

    if Energy - amount <= 0 then
        self.Model:SetAttribute("Energy", 0)
    else
        self.Model:SetAttribute("Energy", Energy - amount)
    end
end

return module
