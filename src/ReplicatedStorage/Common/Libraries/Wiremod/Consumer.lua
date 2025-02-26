local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Wiremod = require(script.Parent.Wiremod)
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local module = {}
module.__index = module
setmetatable(module, Wiremod)

function module.new(ownerName: string, model: Model, buildObject: {})
    local Consumer = Wiremod.new(ownerName, model)
    setmetatable(Consumer, module)

    Consumer.ObjectType = "Consumer"
    Consumer.Model = model
    Consumer.Powered = false
    Consumer.TransferSpeed = 1
    Consumer.Model:AddTag("WiremodObject")
    Consumer.buildObject = buildObject

    return Consumer
end

function module:Start()
    self.Powered = true

    Scheduler.AddToScheduler("Interval_1s", self.Model, function()
        if #self.Connections == 0 then
            if self.Powered then
                if self.buildObject and self.buildObject.disable then
                    self.buildObject:disable()
                end
            else
                self:Stop()
            end
            return
        end

        for _,Wire in self.Connections do
            if Wire.ObjectA.ObjectType == "Generator" and Wire.ObjectA.Enabled then
                return
            elseif Wire.ObjectB.ObjectType == "Generator" and Wire.ObjectB.Enabled then
                return
            end

            if Wire.ObjectA.ObjectType == "Battery" and Wire.ObjectA.Model:GetAttribute("Energy") > 0 then
                if Wire.ObjectA.DecrementEnergy then
                    return Wire.ObjectA:DecrementEnergy(self.TransferSpeed)
                end
            elseif Wire.ObjectB.ObjectType == "Battery" and Wire.ObjectB.Model:GetAttribute("Energy") > 0 then
                if Wire.ObjectB.DecrementEnergy then
                    return Wire.ObjectB:DecrementEnergy(self.TransferSpeed)
                end
            end
        end

        if self.buildObject and self.buildObject.disable then
            self.buildObject:disable()
        else
            self:Stop()
        end
    end)
end

function module:Stop()
    self.Powered = false
    Scheduler.RemoveFromScheduler("Interval_1s", self.Model)
end

function module:IsPowered()
    for _,Wire in self.Connections do
        if (Wire.ObjectA.ObjectType == "Generator" and Wire.ObjectA.Enabled) or (Wire.ObjectA.ObjectType == "Battery" and Wire.ObjectA.Model:GetAttribute("Energy") > 0) then
            return true
        end

        if (Wire.ObjectB.ObjectType == "Generator" and Wire.ObjectB.Enabled) or (Wire.ObjectB.ObjectType == "Battery" and Wire.ObjectB.Model:GetAttribute("Energy") > 0)then
            return true
        end
    end
end

return module
