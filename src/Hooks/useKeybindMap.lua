local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)

type KeybindMapping = {
    [Enum.KeyCode]: () -> ()
}

return function(keybindMapping: KeybindMapping)
    React.useEffect(function()
        local inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then
                return
            end

            local callback = keybindMapping[input.KeyCode]
            if callback then
                callback()
            end
        end)

        return function()
            inputConnection:Disconnect()
        end
    end)

    return nil
end
