local ServerScriptService = game:GetService("ServerScriptService")
local BuildClass = require(ServerScriptService.Modules.Build.Classes.BuildClass)

local module = {}
module.__index = module
setmetatable(module, BuildClass)

function module.new(buildModel: Model, player: Player)
    local self = BuildClass.new(buildModel, player)
    return self
end

return module
