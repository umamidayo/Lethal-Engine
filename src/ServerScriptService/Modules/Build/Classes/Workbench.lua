local ServerScriptService = game:GetService("ServerScriptService")
local BuildClass = require(ServerScriptService.Modules.Build.Classes.BuildClass)

local module = {}
module.__index = module

function module.new(model: Model, player: Player)
    local self = BuildClass.new(model, player)
    self.model:AddTag("Workbench")
    return self
end

return module
