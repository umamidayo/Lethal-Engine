local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local BuildClass = require(ServerScriptService.Modules.Build.Classes.BuildClass)
local Instancer = require(ReplicatedStorage.Common.Libraries.Instancer)
local Randomizer = Random.new()

local module = {}
module.__index = module
setmetatable(module, BuildClass)

function module.new(model: Model, player: Player)
    local self = BuildClass.new(model, player)
    setmetatable(self, module)
    task.delay(0.1, function()
        self:setup()
    end)
    return self
end

-- Required because the CFrame is slow.
function module:setup()
    self.proximityprompt = Instancer.ProximityPrompt({
        maxActivationDistance = 7,
        actionText = `Reset {self.model.Name}`,
        requiresLineOfSight = false,
        holdDuration = 1,
        parent = self.model,
    })
    self.proximityprompt.Enabled = false
    self.trapSet = true
    self.flingPart = self.model.FlingPart
    self.cframeValue = self.flingPart.CFrameValue
    self.originalPivotCFrame = self.flingPart:GetPivot()
    self.cframeValue.Value = self.originalPivotCFrame
    self.hitSound = self.model.Base.TrapHit
    self.resetSound = self.model.Base.TrapReset
    self.debounce = tick()
    self.maid:GiveTask(self.cframeValue:GetPropertyChangedSignal("Value"):Connect(function()
        self.flingPart:PivotTo(self.cframeValue.Value)
    end))
    self.maid:GiveTask(self.model.PrimaryPart.Touched:Connect(function(hit)
        if not self.trapSet then return end
        local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        if Players:GetPlayerFromCharacter(humanoid.Parent) then return end
        if tick() - self.debounce < 0.5 then return end
        self.debounce = tick()
        self.trapSet = false
        self.hitSound.PlaybackSpeed = Randomizer:NextNumber(0.5, 0.8)
        self.hitSound:Play()
        humanoid:TakeDamage(humanoid.MaxHealth)
        self.cframeValue.Value *= CFrame.Angles(0, 0, math.rad(90))
        self.proximityprompt.Enabled = true
    end))
    self.maid:GiveTask(self.proximityprompt.Triggered:Connect(function()
        self.proximityprompt.Enabled = false
        self.resetSound.PlaybackSpeed = Randomizer:NextNumber(0.9, 1.1)
        self.resetSound:Play()
        TweenService:Create(self.cframeValue, TweenInfo.new(0.5), {Value = self.originalPivotCFrame}):Play()
        task.wait(0.5)
        self.trapSet = true
    end))
end

return module
