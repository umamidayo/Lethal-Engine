local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Store = require(ReplicatedStorage.Common.Store)

local useSpring = require(ReplicatedStorage.Hooks.useSpring)
local useKeybindMap = require(ReplicatedStorage.Hooks.useKeybindMap)

local IconButton = require(ReplicatedStorage.Components.IconButton)

local LocalPlayer = Players.LocalPlayer

local element = React.createElement

local function changeWindow(window: string)
	local state = Store:getState()
	local currentWindow = state.interface.currentWindow

	Store:dispatch({
		type = "setWindow",
		window = window ~= currentWindow and window or "None",
	})
end

local function createIconButtons()
	return {
		craft = element(IconButton, {
			Icon = "rbxassetid://15612276715",
			Size = UDim2.fromScale(1, 0.15),
			text = "Craft",
			LayoutOrder = 0,

			onClick = function()
				changeWindow("Crafting")
			end,
		}),

		journal = element(IconButton, {
			Icon = "rbxassetid://15612352003",
			Size = UDim2.fromScale(1, 0.15),
			text = "Journal",
			LayoutOrder = 1,

			onClick = function()
				changeWindow("Journal")
			end,
		}),

		perks = element(IconButton, {
			Icon = "rbxassetid://16163943366",
			Size = UDim2.fromScale(1, 0.15),
			text = "Perks",
			LayoutOrder = 3,

			onClick = function()
				changeWindow("Perks")
			end,
		}),

		-- settings = element(IconButton, {
		-- 	Icon = "rbxassetid://15612371702",
		-- 	Size = UDim2.fromScale(1, 0.15),
		-- 	text = "Settings",
		-- 	LayoutOrder = 4,

		-- 	onClick = function()
		-- 		changeWindow("Settings")
		-- 	end,
		-- }),
	}
end

return function()
	local opened, setOpened = React.useState(false)
	local showIcons, setShowIcons = React.useState(false)
	local paddingScale, setPaddingScale = useSpring(-0.15)

	local iconButtons = createIconButtons()

	useKeybindMap({
		[Enum.KeyCode.LeftControl] = function()
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Build Shovel") then
				return
			end

			changeWindow("Crafting")
		end,

		[Enum.KeyCode.J] = function()
			changeWindow("Journal")
		end,

		[Enum.KeyCode.M] = function()
			changeWindow("Perks")
		end,
	})

	React.useEffect(function()
		if opened then
			setPaddingScale(0.02)
			setShowIcons(true)
		else
			setPaddingScale(-0.15)
			task.delay(0.05, function()
				setShowIcons(false)
			end)
		end
	end, { opened })

	return element("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Name = "HUD",
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
	}, {
		navbar = element("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.01, 0.5),
			Size = UDim2.fromScale(0.05, 0.5),
		}, {
			uiListLayout = element("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = paddingScale:map(function(value)
					return UDim.new(value, 0)
				end),
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			menuIcon = element(IconButton, {
				Icon = not opened and "rbxassetid://15612352003" or "rbxassetid://15613833552",
				Size = UDim2.fromScale(1.2, 0.2),
				text = "Menu",
				LayoutOrder = 2,

				onClick = function()
					setOpened(not opened)
				end,
			}),

			icons = showIcons and element(React.Fragment, nil, iconButtons),
		}),
	})
end
