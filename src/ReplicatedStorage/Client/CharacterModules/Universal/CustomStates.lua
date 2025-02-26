local module = {}

function module.init()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid: Humanoid = character:WaitForChild("Humanoid")

    character.ChildAdded:Connect(function(child)
        task.wait()
        if character:FindFirstChildWhichIsA("Tool") and character:GetAttribute("Laying") then
            humanoid:UnequipTools()
        end
    end)
end

return module
