local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Wiremod = require(script.Parent.Wiremod)
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local module = {}
module.__index = module
setmetatable(module, Wiremod)

function module.new(ownerName: string, model: Model)
    local Generator = Wiremod.new(ownerName, model)
    setmetatable(Generator, module)

    Generator.ObjectType = "Generator"
    Generator.Enabled = false
    Generator.TransferSpeed = 5
    Generator.Model = model
    Generator.Model:AddTag("WiremodObject")

    return Generator
end

function module:Start()
	self.Enabled = true

    Scheduler.AddToScheduler("Interval_1s", self.Model, function()
        if #self.Connections == 0 then return end
    
        for _,Wire in self.Connections do
            if Wire.ObjectA.ObjectType == "Battery" then
                if Wire.ObjectA.IncrementEnergy then
                    Wire.ObjectA:IncrementEnergy(self.TransferSpeed)
                end
            elseif Wire.ObjectB.ObjectType == "Battery" then
                if Wire.ObjectB.IncrementEnergy then
                    Wire.ObjectB:IncrementEnergy(self.TransferSpeed)
                end
            end
        end
    end)
end

function module:Stop()
	self.Enabled = false

    Scheduler.RemoveFromScheduler("Interval_1s", self.Model)

    if #self.Connections == 0 then return end

    for _,Wire in self.Connections do
        if Wire.ObjectA.ObjectType == "Consumer" and not Wire.ObjectA:IsPowered() then
            if Wire.ObjectA.buildModel then
                Wire.ObjectA.buildModel:disable()
            end
        end

        if Wire.ObjectB.ObjectType == "Consumer" and not Wire.ObjectB:IsPowered() then
            if Wire.ObjectB.buildModel then
                Wire.ObjectB.buildModel:disable()
            end
        end
    end
end

return module
