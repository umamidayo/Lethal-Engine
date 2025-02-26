local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local UIAnimations = require(ReplicatedStorage.Common.Libraries.UIAnimations)

local FlashlightEvent = ReplicatedStorage.RemotesLegacy.FlashlightEvent
local player = Players.LocalPlayer
local flashlightIcon = player.PlayerGui:WaitForChild("Main"):WaitForChild("IconBar"):WaitForChild("Flashlight")

local iconSize = flashlightIcon.ImageButton.Size
local lightEnabled = false

local module = {}

local function toggleLight(source, value)
	source.Enabled = value
	source.Parent.FlashlightSound:Play()
end

local function newFlashlight(parent)
	local flashlight = Instance.new("SpotLight")
	flashlight.Angle = 90
	flashlight.Range = 60
	flashlight.Brightness = 0.7
	flashlight.Shadows = true
	flashlight.Name = "Flashlight"
	flashlight.Parent = parent

	local flashlightSound = SoundService:WaitForChild("CharacterSounds"):WaitForChild("FlashlightSound"):Clone()
	flashlightSound.Parent = parent

	return flashlight
end

local function onAction()
	lightEnabled = not lightEnabled
	FlashlightEvent:FireServer(lightEnabled)
end

local keybinds = { "Enum.KeyCode.F", "Enum.KeyCode.DPadDown" }

function module.init()
	if not UserInputService.KeyboardEnabled then
		flashlightIcon.KeybindLabel.Text = ""
	else
		flashlightIcon.KeybindLabel.Text = "[F]"
	end

	flashlightIcon.ImageButton.MouseButton1Click:Connect(onAction)

	flashlightIcon.ImageButton.MouseEnter:Connect(function()
		UIAnimations.TabEnter(flashlightIcon, flashlightIcon.ImageButton, iconSize)
	end)

	flashlightIcon.ImageButton.MouseLeave:Connect(function()
		UIAnimations.TabLeave(flashlightIcon, flashlightIcon.ImageButton, iconSize)
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.Gamepad1 then
			if table.find(keybinds, tostring(input.KeyCode)) then
				onAction()
			end
		end
	end)

	FlashlightEvent.OnClientEvent:Connect(function(characterHead, value)
		local flashlight = characterHead:FindFirstChild("Flashlight")

		if flashlight then
			toggleLight(flashlight, value)
		else
			flashlight = newFlashlight(characterHead)

			toggleLight(flashlight, value)
		end
	end)
end

return module
