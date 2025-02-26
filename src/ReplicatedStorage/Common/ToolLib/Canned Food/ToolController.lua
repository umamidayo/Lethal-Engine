local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local Network = require(ReplicatedStorage.Common.Network)
local Maid = require(ReplicatedStorage.Common.Libraries.Maid)
local ProgressBarController = require(ReplicatedStorage.Common.UIModules.ProgressBarController)
local maid = Maid.new()
local animations = ReplicatedStorage.Animations.Tools["Cooked Meat"]
local player = Players.LocalPlayer
local module = {}

local eating = false
local equipped = false

local function startEating(character: Model, Humanoid: Humanoid)
    eating = true
    local startPosition = character.PrimaryPart.Position
    local startTick = tick()
    while player:DistanceFromCharacter(startPosition) <= 4 do
        Humanoid.WalkSpeed = 3
        task.wait()
        if tick() - startTick > 3 then break end
        if not equipped then
            Notifier.new("Eating cancelled", nil, 5)
            return
        end
    end
    if player:DistanceFromCharacter(startPosition) > 4 then
        Notifier.new("Eating was cancelled for moving too much", nil, 5)
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
        if eating then return end
        animTracks["EatAnim"]:Play()
        Network.fireServer(Network.RemoteEvents.ToolEvent, "EatStart", {
            Tool = tool,
        })

        ProgressBarController.startProgress(3, `Consuming {tool.Name}`)
        local success = startEating(character, humanoid)

        if success then
            Network.fireServer(Network.RemoteEvents.ToolEvent, "EatFinish")
            ProgressBarController.completeProgress(`Finished consuming {tool.Name}`)
        else
            ProgressBarController.stopProgress(`Failed to eat`)
        end

        eating = false
        animTracks["EatAnim"]:Stop()
        humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed
    end))
end

function module.Unequip()
    equipped = false
    maid:DoCleaning()
end

return module
