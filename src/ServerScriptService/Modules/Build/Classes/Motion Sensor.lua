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
    self.proximityprompt = Instancer.ProximityPrompt({
        maxActivationDistance = 7,
        actionText = "Turn On",
        requiresLineOfSight = false,
        holdDuration = 0.5,
        parent = self.model.WirePart or self.model.PrimaryPart
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
    return self
end

function module:enable()
    if not self.consumer:IsPowered() then return end
    self.consumer:Start()
    self.proximityprompt.ActionText = "Turn Off"
    task.delay(0.2, function()
        self.model.LightPart.MotionSensorArmed:Play()
        self.model.LightPart.Transparency = 0
        self.model.LightPart.PointLight.Enabled = true
        self.model:AddTag("MotionSensor")
    end)
end

function module:disable()
    self.consumer:Stop()
    self.proximityprompt.ActionText = "Turn On"
    self.model.LightPart.MotionSensorArmed:Stop()
    self.model.LightPart.Transparency = 1
    self.model.LightPart.PointLight.Enabled = false
    self.model:RemoveTag("MotionSensor")
end

return module
