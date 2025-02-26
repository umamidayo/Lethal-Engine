local ServerScriptService = game:GetService("ServerScriptService")
local BaseClass = require(ServerScriptService.Modules.Player.BaseClass)

local module = {}
module.__index = module
setmetatable(module, BaseClass)

function module.new(className: string)
    local self = setmetatable(BaseClass.new(className), module)
    return self
end

return module
