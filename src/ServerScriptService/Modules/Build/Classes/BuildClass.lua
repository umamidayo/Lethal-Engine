local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Common.Libraries.Maid)
local Randomizer = Random.new()
local module = {}
module.__index = module

function module.new(buildModel: Model, player: Player)
    local self = {}
    setmetatable(self, module)
    self.model = buildModel
    self.owner = player
    self.ownerName = player.Name
    self.permissions = {
        destroy = {
            ownerOnly = false,
        }
    }
    self.model:SetAttribute("Owner", self.ownerName)
    self.maid = Maid.new()
    self.lastHealth = self.model:GetAttribute("Health")

    self.maid:GiveTask(self.model:GetAttributeChangedSignal("Health"):Connect(function()
        local currentHealth = self.model:GetAttribute("Health")

        if currentHealth <= 0 then
            return self:Destroy()
        end

        if currentHealth < self.lastHealth then
            local soundSource = self.model:FindFirstChildWhichIsA("BasePart")
            if not soundSource then return end
            local hitSound = SoundService.BuildDamage:FindFirstChild(tostring(soundSource.Material)):Clone()
            hitSound.PlaybackSpeed = Randomizer:NextNumber(0.9, 1.1)
            hitSound.Parent = soundSource
            hitSound.PlayOnRemove = true
            hitSound:Destroy()
        end

        self.lastHealth = currentHealth
    end))

    return self
end

function module:Destroy()
    self.maid:DoCleaning()
    self.model:Destroy()
    setmetatable(self, nil)
end

return module
