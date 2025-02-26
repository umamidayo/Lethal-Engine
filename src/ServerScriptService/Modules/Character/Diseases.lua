local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Common.Libraries.Maid)

local module = {}
module.__index = module

function module.new(diseaseName: string, diseaseData: {any})
    local self = setmetatable({}, module)

    self.name = diseaseName
    self.data = diseaseData
    self.maid = Maid.new()

    return self
end

function module:Destroy()
    self.maid:DoCleaning()
    setmetatable(self, nil)
end

return module