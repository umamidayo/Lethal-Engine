local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local BuildClass = require(ServerScriptService.Modules.Build.Classes.BuildClass)
local CharacterLibrary = require(ReplicatedStorage.Common.Libraries.CharacterLibrary)
local module = {}
module.__index = module
setmetatable(module, BuildClass)

function module.new(model: Model, player: Player)
    local self = BuildClass.new(model, player)
    setmetatable(self, module)
    self.maxAmmo = 10
    self.currentAmmo = self.maxAmmo
    self.totalCost = self.model:GetAttribute("Cost")
    self.ammoSound = self.model.AmmoBox:FindFirstChild("Resupply")
    self.debounces = {}
    self.billboardgui = self.model.BillboardPart:FindFirstChildWhichIsA("BillboardGui")
    self.proximityprompt = self.model.BillboardPart:FindFirstChildWhichIsA("ProximityPrompt")
    self.maid:GiveTask(self.proximityprompt.Triggered:Connect(function(playerWhoTriggered)
        self:giveAmmo(playerWhoTriggered)
    end))

    self.proximityprompt.Enabled = true
    self.billboardgui.TextLabel.Text = `{self.currentAmmo}/{self.maxAmmo} AMMO`

    return self
end

function module:update()
    self.billboardgui.TextLabel.Text = `{self.currentAmmo}/{self.maxAmmo} AMMO`
    self.model:SetAttribute("Cost", math.clamp((self.totalCost / self.maxAmmo) * self.currentAmmo, 0, self.maxAmmo))
    self.ammoSound:Play()
end

function module:giveAmmo(player: Player)
    if CharacterLibrary.IsDead(player) then return end

    local DEBOUNCE_TIME = 1

    if self.debounces[player.Name] and tick() - self.debounces[player.Name] < DEBOUNCE_TIME then return end
    self.debounces[player.Name] = tick()

    for _,v in player.Backpack:GetChildren() do
        if v:IsA("Tool") and v:FindFirstChild("ACS_Settings") then
            local copy = ServerStorage.Tools:FindFirstChild(v.Name)
            if not copy then continue end
            v:Destroy()
            copy = copy:Clone()
            copy.Parent = player.Backpack
        end
    end

    local equippedTool = CharacterLibrary.GetEquippedTool(player)

    if equippedTool and equippedTool:FindFirstChild("ACS_Settings") then
        local copy = ServerStorage.Tools:FindFirstChild(equippedTool.Name)
        if copy then
            equippedTool = CharacterLibrary.UnequipTool(player.Character)
            equippedTool:Destroy()
            copy = copy:Clone()
            copy.Parent = player.Backpack
            CharacterLibrary.EquipTool(player.Character, copy)
        end
    end

    self.currentAmmo -= 1

    if self.currentAmmo <= 0 then
        return self:Destroy()
    end

    self:update()
end

return module
