local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local BuildClass = require(ServerScriptService.Modules.Build.Classes.BuildClass)
local Consumer = require(ReplicatedStorage.Common.Libraries.Wiremod.Consumer)
local Instancer = require(ReplicatedStorage.Common.Libraries.Instancer)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local module = {}
module.__index = module
setmetatable(module, BuildClass)

function module.new(model: Model, player: Player)
    local self = BuildClass.new(model, player)
    setmetatable(self, module)
    self.consumer = Consumer.new(player.Name, model, self)
    self.lightPart = self.model.LightPart
    self.light = self.lightPart.SpotLight
    self.proximityprompt = Instancer.ProximityPrompt({
        maxActivationDistance = 7,
        actionText = "Turn On",
        requiresLineOfSight = false,
        holdDuration = 0.5,
        parent = self.model.WirePart
    })
    self.maid:GiveTask(self.proximityprompt.Triggered:Connect(function(playerWhoTriggered)
        if playerWhoTriggered ~= self.owner then
            return Notifier.NotificationEvent(playerWhoTriggered, `You do not own this {self.model.Name}`)
        end
        if not self.consumer.Powered then
            self:enable()
        else
            self:disable()
        end
    end))
    self:disable()
    return self
end

function module:enable()
    if not self.consumer:IsPowered() then return end
    self.consumer:Start()
    self.proximityprompt.ActionText = "Turn Off"
    self.lightPart.Material = Enum.Material.Neon
    self.light.Enabled = true
end

function module:disable()
    self.consumer:Stop()
    self.proximityprompt.ActionText = "Turn On"
    self.lightPart.Material = Enum.Material.Glass
    self.light.Enabled = false
end

return module
