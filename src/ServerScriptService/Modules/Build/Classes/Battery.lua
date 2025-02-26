local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local BuildClass = require(ServerScriptService.Modules.Build.Classes.BuildClass)
local Battery = require(ReplicatedStorage.Common.Libraries.Wiremod.Battery)
local module = {}
module.__index = module
setmetatable(module, BuildClass)

function module.new(model: Model, player: Player)
    local self = BuildClass.new(model, player)
    setmetatable(self, module)
    self.permissions.destroy.ownerOnly = true
    self.battery = Battery.new(player.Name, model, self)
    return self
end

return module
