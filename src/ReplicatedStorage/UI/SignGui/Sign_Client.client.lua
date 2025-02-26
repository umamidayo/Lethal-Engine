local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sign_Event = ReplicatedStorage:WaitForChild("RemotesLegacy"):WaitForChild("Sign_Event")
local Gui = script.Parent
local Sign = Gui.Sign.Value
local focusConnection

Gui.Frame.Submit.MouseButton1Click:Connect(function()
	Sign_Event:FireServer(Sign, Gui.Frame.TextBox.Text)
	Sign_Event.OnClientEvent:Wait()
	Gui:Destroy()
end)

focusConnection = UIS.InputBegan:Connect(function(input, processed)
	if not processed then return end
	
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.Return then
			Gui.Frame.TextBox:ReleaseFocus(true)
			Sign_Event:FireServer(Sign, Gui.Frame.TextBox.Text)
			Sign_Event.OnClientEvent:Wait()
			Gui:Destroy()
		end
	end
end)
