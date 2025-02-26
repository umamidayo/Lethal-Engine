local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local Network = require(ReplicatedStorage.Common.Network)
local Maid = require(ReplicatedStorage.Common.Libraries.Maid)
local ProgressBarController = require(ReplicatedStorage.Common.UIModules.ProgressBarController)
local maid = Maid.new()
local animations = ReplicatedStorage.Animations.Tools.Medkit
local player = Players.LocalPlayer
local mouse  = player:GetMouse()
local equipped = false
local healing = false
local module = {}

local function getOtherPlayerFromMouse()
    if not mouse.Target then return end
    local character = mouse.Target:FindFirstAncestorWhichIsA("Model")
    if not character or not  character:FindFirstChildWhichIsA("Humanoid") then return end
    local otherPlayer = Players:GetPlayerFromCharacter(character)
    if not otherPlayer or otherPlayer == player then return end
    return otherPlayer
end

local function startSelfHealing(character: Model, humanoid: Humanoid)
    healing = true
    local healStartPosition = character.PrimaryPart.Position
    local startHealTick = tick()
    while player:DistanceFromCharacter(healStartPosition) <= 4 do
        humanoid.WalkSpeed = 3
        task.wait()
        if tick() - startHealTick > 3 then break end
        if not equipped then
            Notifier.new("Healing cancelled", nil, 5)
            return
        end
    end
    if player:DistanceFromCharacter(healStartPosition) > 4 then
        Notifier.new("Healing was cancelled for moving too much", nil, 5)
        return
    end
    return true
end

local function startOtherHealing(character: Model, humanoid: Humanoid, otherPlayer: Player)
    local otherPlayerCharacter = otherPlayer.Character
    if not otherPlayerCharacter then return end
    local otherHumanoid = otherPlayerCharacter:FindFirstChildWhichIsA("Humanoid")
    if not otherHumanoid then return end
    if otherHumanoid.Health >= otherHumanoid.MaxHealth then
        Notifier.new("Player is already at full health", nil, 5)
        return
    end
    healing = true
    local startHealTick = tick()
    while otherPlayer:DistanceFromCharacter(character.PrimaryPart.Position) <= 6 do
        humanoid.WalkSpeed = 3
        task.wait()
        if tick() - startHealTick > 3 then break end
        if not equipped then
            Notifier.new("Healing cancelled", nil, 5)
            return
        end
        if otherHumanoid.Health <= 0 then
            Notifier.new("Healing was cancelled, player is dead", nil, 5)
            return
        end
    end
    if otherPlayer:DistanceFromCharacter(character.PrimaryPart.Position) > 6 then
        Notifier.new("Healing was cancelled, player is out of reach", nil, 5)
        return
    end
    return true
end

function module.Equip(tool: Tool)
    local character = tool.Parent
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    local animator = humanoid:FindFirstChildWhichIsA("Animator")
    if not animator then return end

    equipped = true

    local animTracks = {}
    for _,animation in animations:GetChildren() do
        animTracks[animation.Name] = animator:LoadAnimation(animation)
        maid:GiveTask(animTracks[animation.Name])
    end

    maid:GiveTask(tool.Activated:Connect(function()
        if healing then return end
        local otherPlayer = getOtherPlayerFromMouse()
        if otherPlayer then
            animTracks["HealOtherAnim"]:Play()
            Network.fireServer(Network.RemoteEvents.ToolEvent, "HealOtherStart", {
                Tool = tool,
                OtherPlayer = otherPlayer,
            })

            ProgressBarController.startProgress(3, `Healing {otherPlayer.Name}`)
            local success = startOtherHealing(character, humanoid, otherPlayer)

            if success then
                Network.fireServer(Network.RemoteEvents.ToolEvent, "HealOtherFinish")
                ProgressBarController.completeProgress(`Healed {otherPlayer.Name}`)
            else
                ProgressBarController.stopProgress(`Failed to heal {otherPlayer.Name}`)
            end

            healing = false
            animTracks["HealOtherAnim"]:Stop()
            humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed
        else
            if humanoid.Health >= humanoid.MaxHealth then
                Notifier.new("You are already at full health", nil, 5)
                return
            end
            animTracks["SelfHealAnim"]:Play()
            Network.fireServer(Network.RemoteEvents.ToolEvent, "HealStart", {
                Tool = tool,
            })

            ProgressBarController.startProgress(3, `Healing self`)
            local success = startSelfHealing(character, humanoid)

            if success then
                Network.fireServer(Network.RemoteEvents.ToolEvent, "HealFinish")
                ProgressBarController.completeProgress(`Healed self`)
            else
                ProgressBarController.stopProgress(`Failed to heal self`)
            end

            healing = false
            animTracks["SelfHealAnim"]:Stop()
            humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed
        end
    end))
end

function module.Unequip()
    equipped = false
    maid:DoCleaning()
end

return module
