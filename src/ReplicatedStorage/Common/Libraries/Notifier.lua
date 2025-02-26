local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = {
	NotificationTween = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
}

local Network = require(ReplicatedStorage.Common.Network)

-- Creates a notification.
function module.new(text: string, textColor: Color3?, showSeconds: number?)
	local player: Player = game.Players.LocalPlayer
	local playerGui = player.PlayerGui
	local mainGui = playerGui:WaitForChild("Main")
	local notifications = mainGui:WaitForChild("Notifications")

	task.spawn(function()
		local TS = game:GetService("TweenService")
		local notification: TextLabel = script.NotificationLabel:Clone()
		notification.Text = string.upper(text)
		if textColor then
			notification.TextColor3 = textColor
		end
		notification.TextTransparency = 1
		notification.Parent = notifications
		local tween = TS:Create(notification, module.NotificationTween, { TextTransparency = 0 })
		tween:Play()
		tween.Completed:Wait()
		if showSeconds then
			task.wait(showSeconds)
		else
			task.wait(3)
		end
		tween = TS:Create(notification, module.NotificationTween, { TextTransparency = 1 })
		tween:Play()
		tween.Completed:Wait()
		notification:Destroy()
	end)
end

-- Fires a notification event to the client.
function module.NotificationEvent(player: Player, text: string, textColor: Color3?, showSeconds: number?)
	Network.fireClient(Network.RemoteEvents.NotifierEvent, player, text, textColor, showSeconds)
end

return module
