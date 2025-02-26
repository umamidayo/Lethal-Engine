local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local PlayerRadioEvent = ReplicatedStorage:WaitForChild("RemotesLegacy"):WaitForChild("PlayerRadioEvent")
local Gui = playerGui:WaitForChild("PlayerRadioGui")
local Frame = Gui:WaitForChild("Frame")
local Radio: Model = nil

local songs = {7024132063, 5410085763, 5410086218, 7024143472, 5410080926, 7024154355, 7023445033}

function module.init()
    Frame.PlayButton.MouseButton1Click:Connect(function()
        PlayerRadioEvent:FireServer(Radio, Frame.TextBox.Text)
        Gui.Enabled = false
    end)

    Frame.CancelButton.MouseButton1Click:Connect(function()
        Gui.Enabled = false
    end)

    PlayerRadioEvent.OnClientEvent:Connect(function(newRadio: Model)
        Radio = newRadio
        Gui.Frame.TextBox.Text = songs[Random.new():NextInteger(1, #songs)]
        Gui.Enabled = true
    end)
end

return module
