local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local BuildClass = require(ServerScriptService.Modules.Build.Classes.BuildClass)
local Generator = require(ReplicatedStorage.Common.Libraries.Wiremod.Generator)
local Instancer = require(ReplicatedStorage.Common.Libraries.Instancer)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local module = {}
module.__index = module
setmetatable(module, BuildClass)

function module.new(model: Model, player: Player)
    local self = BuildClass.new(model, player)
    setmetatable(self, module)
    self.generator = Generator.new(player.Name, model)
    self.generatorSound = self.model.PrimaryPart.GeneratorSound :: Sound
    self.permissions.destroy.ownerOnly = true
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
        if not self.generator.Enabled then
            self:enable()
        else
            self:disable()
        end
    end))
    return self
end

function module:enable()
    self.generator:Start()
    self.generatorSound.Volume = 0
    self.generatorSound:Play()
    TweenService:Create(self.generatorSound, TweenInfo.new(0.5), {Volume = 0.2}):Play()
    self.proximityprompt.ActionText = "Turn Off"
end

function module:disable()
    self.generator:Stop()
    self.generatorSound.Volume = 0.2
    TweenService:Create(self.generatorSound, TweenInfo.new(0.5), {Volume = 0}):Play()
    task.delay(0.5, function()
        self.generatorSound:Stop()
    end)
    self.proximityprompt.ActionText = "Turn On"
end

return module
