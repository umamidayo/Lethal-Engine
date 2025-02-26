local ServerScriptService = game:GetService("ServerScriptService")
local BuildClass = require(ServerScriptService.Modules.Build.Classes.BuildClass)

local module = {}
module.__index = module

function module.new(model: Model, player: Player)
    local self = BuildClass.new(model, player)
    self.model:AddTag("GlobalMarker")
    self.model.Light.Color = Color3.fromRGB(math.random(150, 250), math.random(150, 250), math.random(150, 250))
    return self
end

return module
