local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GrenadeClientEvent = ReplicatedStorage:WaitForChild("RemotesLegacy"):WaitForChild("GrenadeClientEvent")
local VFXModule = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("VFX_Module"))

function module.init()
    local camera = workspace.CurrentCamera
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid: Humanoid = character:WaitForChild("Humanoid")

    GrenadeClientEvent.OnClientEvent:Connect(function(grenadeSource: BasePart)
        grenadeSource.Explode:Play()
        
        if (camera.CFrame.Position - grenadeSource.Position).Magnitude > grenadeSource.Echo.RollOffMinDistance then
            grenadeSource.Echo:Play()
        end
        
        if humanoid.Health <= 0 then return end
        
        if player:DistanceFromCharacter(grenadeSource.Position) < 100 then
            VFXModule.ShakeCamera()
        end
    end)
end

return module
