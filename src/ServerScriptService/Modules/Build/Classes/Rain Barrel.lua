local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local BuildClass = require(ServerScriptService.Modules.Build.Classes.BuildClass)
local Instancer = require(ReplicatedStorage.Common.Libraries.Instancer)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local module = {}
module.__index = module
setmetatable(module, BuildClass)

function module.new(model: Model, player: Player)
    local self = BuildClass.new(model, player)
    setmetatable(self, module)
    task.delay(0.2, function()
        self:setup()
    end)
    return self
end

function module:setup()
    self.proximityprompt = Instancer.ProximityPrompt({
        maxActivationDistance = 7,
        actionText = "Fill Empty Bottle",
        requiresLineOfSight = false,
        holdDuration = 0.5,
        parent = self.model
    })
    self.rayParams = RaycastParams.new()
    self.rayParams.FilterType = Enum.RaycastFilterType.Exclude
    self.rayParams.FilterDescendantsInstances = {self.model, workspace.Landscape}
    self.waterPart = self.model.Water
    self.waterCFrames = {
        self.waterPart.CFrame,
        self.waterPart.CFrame + Vector3.new(0, 0.5, 0),
        self.waterPart.CFrame + Vector3.new(0, 1, 0),
        self.waterPart.CFrame + Vector3.new(0, 1.5, 0),
        self.waterPart.CFrame + Vector3.new(0, 2, 0),
        self.waterPart.CFrame + Vector3.new(0, 2.5, 0),
        self.waterPart.CFrame + Vector3.new(0, 3, 0)
    }
    self.waterQuantity = 1
    self.debounces = {}
    self.maid:GiveTask(ReplicatedStorage.RemotesLegacy.RainBarrel.Event:Connect(function()
        if self.waterQuantity >= 7 then return end
        if self:isUnderRoof() then return end
        self:incrementWaterQuantity(1)
    end))
    self.maid:GiveTask(self.proximityprompt.Triggered:Connect(function(playerWhoTriggered)
        if self.waterQuantity <= 1 then
            return Notifier.NotificationEvent(playerWhoTriggered, "This rain barrel is empty")
        end
        if self.debounces[playerWhoTriggered.Name] and tick() - self.debounces[playerWhoTriggered.Name] < 60 then
            return Notifier.NotificationEvent(playerWhoTriggered, `Try again in {math.floor(60 - (tick() - self.debounces[playerWhoTriggered.Name]))} seconds`)
        end
        self:fillBottle(playerWhoTriggered)
    end))
end

function module:incrementWaterQuantity(amount: number)
    self.waterQuantity = math.clamp(self.waterQuantity + amount, 1, 7)
    self:updateWater()
end

function module:updateWater()
    self.waterPart.CFrame = self.waterCFrames[self.waterQuantity]
    self.proximityprompt.Enabled = self.waterQuantity > 1
end

function module:isUnderRoof()
    local rayResult = workspace:Raycast(self.model.PrimaryPart.Position, Vector3.new(0, 50, 0), self.rayParams)
    return rayResult
end

function module:fillBottle(player: Player)
    local bottle = player.Character:FindFirstChild("Empty Bottle") or player.Backpack:FindFirstChild("Empty Bottle")
    if not bottle then
        return Notifier.NotificationEvent(player, "You need 1 Empty Bottle")
    end
    bottle:Destroy()
    bottle = ServerStorage.Tools["Water Bottle"]:Clone()
    bottle.Parent = player.Backpack
    self.debounces[player.Name] = tick()
    self.model.Barrel.WaterSound:Play()
    self:incrementWaterQuantity(-1)
end

return module
