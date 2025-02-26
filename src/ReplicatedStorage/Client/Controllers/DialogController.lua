local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

export type ChoiceData = {
	Text: string,
	Action: () -> nil,
}

local Maid = require(ReplicatedStorage.Common.Libraries.Maid)

local maid = Maid.new()

local LocalPlayer = Players.LocalPlayer
local PlayerGui: PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Interface: ScreenGui = PlayerGui:WaitForChild("DialogGui")
local Main: Frame = Interface:WaitForChild("Frame")
local TextFrame: Frame = Main:WaitForChild("TextFrame")
local Choices: ScrollingFrame = TextFrame:WaitForChild("Choices")
local NpcNameLabel: TextLabel = TextFrame:WaitForChild("NpcName")
local DialogLabel: TextLabel = TextFrame:WaitForChild("Dialog")

local ChoiceExample: TextButton = ReplicatedStorage.UI.ChoiceExample

local closeThread = nil

local DialogController = {
	currentNpc = nil,
	npcObject = nil,
}

function DialogController.toggle(enabled: boolean)
	if enabled then
		SoundService:PlayLocalSound(SoundService.UI.Slide)
	end

	Interface.Enabled = enabled
	DialogController.npcObject.talking = enabled
end

function DialogController.setDialog(npcName: string, dialog: string)
	DialogController.currentNpc = npcName
	NpcNameLabel.Text = npcName
	DialogLabel.Text = dialog
end

function DialogController.setChoices(dialog: string, choices: { ChoiceData })
	maid:DoCleaning()

	if not choices or next(choices) == nil then
		local speed = 15
		local dialogTime = math.clamp(string.len(dialog) / speed, 3, 8)
		closeThread = task.delay(dialogTime, DialogController.toggle, false)
		return dialogTime
	end

	for _, choice in choices do
		local choiceButton: TextButton = ChoiceExample:Clone()
		maid:GiveTask(choiceButton)
		choiceButton.Text = choice.Text
		choiceButton.LayoutOrder = choice.LayoutOrder
		choiceButton.Parent = Choices

		choiceButton.MouseButton1Click:Connect(function()
			SoundService:PlayLocalSound(SoundService.UI.Click)
			if choice.Action then
				choice.Action()
			end
		end)

		choiceButton.MouseEnter:Connect(function()
			choiceButton.TextColor3 = Color3.fromRGB(182, 182, 182)
			SoundService:PlayLocalSound(SoundService.UI.Hover)
		end)

		choiceButton.MouseLeave:Connect(function()
			choiceButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		end)
	end
end

function DialogController.openDialog(npcObject, npcName: string, dialog: string, choices: { ChoiceData })
	if closeThread then
		task.cancel(closeThread)
	end

	DialogController.npcObject = npcObject
	DialogController.setDialog(npcName, dialog)
	DialogController.setChoices(dialog, choices)
	DialogController.toggle(true)
end

function DialogController.updateDialog(dialog: string, choices: { ChoiceData })
	DialogLabel.Text = dialog
	local dialogTime = DialogController.setChoices(dialog, choices)
	return dialogTime
end

function DialogController.getOrderedDialog(index: number, dialogs: { string })
	local dialog = dialogs[index]
	index = index % #dialogs + 1
	return dialog, index
end

return DialogController
