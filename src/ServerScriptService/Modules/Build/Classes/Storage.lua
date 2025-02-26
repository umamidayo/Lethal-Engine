local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuildClass = require(ServerScriptService.Modules.Build.Classes.BuildClass)
local Instancer = require(ReplicatedStorage.Common.Libraries.Instancer)
local StorageModule = require(ServerScriptService.Modules.Build.StorageModule)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local module = {}
module.__index = module
setmetatable(module, BuildClass)

function module.new(model: Model, player: Player)
    local self = BuildClass.new(model, player)
    setmetatable(self, module)
    self.permissions.destroy.ownerOnly = true
    self.proximityprompt = Instancer.ProximityPrompt({
        maxActivationDistance = 7,
        actionText = "Open Storage",
        requiresLineOfSight = false,
        holdDuration = 0.5,
        parent = self.model.PrimaryPart
    })
    self.storage = StorageModule.Create(self.model, self.owner)
    self.maid:GiveTask(self.proximityprompt.Triggered:Connect(function(playerWhoTriggered)
        if not table.find(StorageModule.StoragePermissions[self.model], playerWhoTriggered.Name) then
            return Notifier.NotificationEvent(playerWhoTriggered, `You do not have access to this {self.model.Name}`)
        end
        ReplicatedStorage.RemotesLegacy.Storage_Event:FireClient(playerWhoTriggered, "Open", self.model, StorageModule.Storages[self.model], StorageModule.StoragePermissions[self.model])
    end))
    self.maid:GiveTask(self.model.Destroying:Connect(function()
        StorageModule.CleanUp(self.model)
    end))
    return self
end

return module
