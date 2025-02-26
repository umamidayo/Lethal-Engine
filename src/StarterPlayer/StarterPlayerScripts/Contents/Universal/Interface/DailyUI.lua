local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Network = require(ReplicatedStorage.Common.Network)
local Icon = require(ReplicatedStorage.Dependencies.Icon)
local UIMount = require(ReplicatedStorage.Common.UIModules.UIMount)
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)
local Maid = require(ReplicatedStorage.Common.Libraries.Maid)

local maid = Maid.new()
local player = Players.LocalPlayer
local playerGui = player.PlayerGui or player:WaitForChild("PlayerGui")
local dailyGui: ScreenGui = playerGui:WaitForChild("DailyGui")
local frame = dailyGui:WaitForChild("Frame")
local closeButton: ImageButton = frame:WaitForChild("CloseButton")
local rewardsFrame: Frame = frame:WaitForChild("Rewards")
local contents: Frame = rewardsFrame:WaitForChild("Contents")
local rewardSample: Frame = ReplicatedStorage:WaitForChild("UI"):WaitForChild("Reward"):WaitForChild("RewardSample")
local rewardFrameTimeLabels = {}
local mouseTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local lastClaim = nil
local streak = 0
local nextStreak = 0

local module = {}

function module.init()
	local icon = Icon.new()
	icon:setImage(16304001932)
	icon:setOrder(10)
	icon:bindEvent("selected", function()
		icon:deselect()
		if not dailyGui.Enabled then
			Network.fireServer(Network.RemoteEvents.DailyEvent, "getDailyData")
		end
		dailyGui.Enabled = not dailyGui.Enabled
	end)
end

function module.Format(Int)
	return string.format("%02i", Int)
end

function module.convertToHMS(Seconds)
	local Minutes = (Seconds - Seconds % 60) / 60
	Seconds = Seconds - Minutes * 60
	local Hours = (Minutes - Minutes % 60) / 60
	Minutes = Minutes - Hours * 60
	return module.Format(Hours) .. ":" .. module.Format(Minutes) .. ":" .. module.Format(Seconds)
end

function module.shakeEffect(uiObject: GuiObject, degrees: number)
	local shakeTween = TweenService:Create(uiObject, mouseTweenInfo, {
		Rotation = degrees,
	})
	shakeTween:Play()
	shakeTween.Completed:Wait()
	shakeTween:Destroy()
	TweenService:Create(uiObject, mouseTweenInfo, {
		Rotation = 0,
	}):Play()
end

function module.tweenSize(uiObject: GuiObject, value: number)
	local uiScale = uiObject:FindFirstChild("UIScale")
	if not uiScale then
		return
	end

	local tween = TweenService:Create(uiScale, mouseTweenInfo, {
		Scale = value,
	})
	tween:Play()
	tween.Completed:Wait()
	tween:Destroy()
end

UIMount.mount(closeButton, "button", {
	button = closeButton,
	mouseEnter = function()
		module.shakeEffect(closeButton, 5)
	end,
	mouseClick = function()
		dailyGui.Enabled = not dailyGui.Enabled
	end,
})

function module.updateDailyRewards(data: { any })
	maid:DoCleaning()
	rewardFrameTimeLabels = {}

	lastClaim = data.lastClaim
	streak = data.streak
	nextStreak = streak + 1
	local reward = data.reward

	frame.Streak.Text = `Daily Streak: {streak}`

	local rewardFrame = rewardSample:Clone()
	maid:GiveTask(rewardFrame)
	rewardFrame.Day.Text = `Day {nextStreak}`
	rewardFrame.RewardLabel.Text = `{reward} Tokens`
	rewardFrame.LayoutOrder = nextStreak
	rewardFrame.Parent = contents

	if lastClaim and (os.time() - lastClaim) >= 86400 or lastClaim == nil then
		rewardFrame.ClaimButton.Visible = true
		rewardFrame.ClaimBackground.Visible = true
		UIMount.mount(rewardFrame.ClaimButton, "button", {
			button = rewardFrame.ClaimButton,
			mouseEnter = function()
				module.shakeEffect(rewardFrame.ClaimButton, 5)
			end,
			mouseClick = function()
				Network.fireServer(Network.RemoteEvents.DailyEvent, "claimDailyReward", nextStreak)
			end,
		})
	else
		if lastClaim then
			table.insert(rewardFrameTimeLabels, rewardFrame.TimeLeft)
			rewardFrame.TimeLeft.Visible = true
		end
	end
end

Scheduler.AddToScheduler("Interval_1s", "DailyUI", function()
	if #rewardFrameTimeLabels == 0 then
		return
	end
	if lastClaim == nil then
		return
	end
	for i, label in rewardFrameTimeLabels do
		label.Text = module.convertToHMS(lastClaim + (i * 86400) - os.time())
	end
end)

dailyGui:GetPropertyChangedSignal("Enabled"):Connect(function()
	if dailyGui.Enabled then
		Network.fireServer(Network.RemoteEvents.DailyEvent, "getDailyData")
	end
end)

Network.connectEvent(Network.RemoteEvents.DailyEvent, function(eventType: string, data: { any })
	if eventType == "newData" then
		module.updateDailyRewards(data)
	end
end, Network.t.string, Network.t.any)

return module
