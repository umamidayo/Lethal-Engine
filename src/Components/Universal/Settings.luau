local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Store = require(ReplicatedStorage.Common.Store)

local Modal = require(ReplicatedStorage.Components.Modal)
local ToggleButton = require(ReplicatedStorage.Components.ToggleButton)

local useSpring = require(ReplicatedStorage.Hooks.useSpring)

local element = React.createElement

local function setSetting(setting: string, value: boolean)
	Store:dispatch({
		type = "setSetting",
		setting = setting,
		value = value,
	})
end

local options = {
	-- {
	-- 	name = "Hide User Interface",
	-- 	setting = "hideUI",
	-- 	onToggle = function(enabled)
	-- 		setSetting("hideUI", enabled)
	-- 	end,
	-- },
	-- {
	-- 	name = "Mute Radios",
	-- 	setting = "muteRadios",
	-- 	onToggle = function(enabled)
	-- 		setSetting("muteRadios", enabled)
	-- 	end,
	-- },
	-- {
	-- 	name = "Highlight Players",
	-- 	setting = "highlightPlayers",
	-- 	onToggle = function(enabled)
	-- 		setSetting("highlightPlayers", enabled)
	-- 	end,
	-- },
	-- {
	-- 	name = "Player Tags",
	-- 	setting = "playerTags",
	-- 	onToggle = function(enabled)
	-- 		setSetting("playerTags", enabled)
	-- 	end,
	-- },
}

local function createOption(props)
	local name = props.name
	local enabled = props.enabled
	local onToggle = props.onToggle

	return element("Frame", {
		Name = name,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 0.18),
	}, {
		optionName = element("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.PermanentMarker,
			Position = UDim2.fromScale(0.2, 0.5),
			Size = UDim2.fromScale(0.5, 0.5),
			Text = name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		toggleButton = element(ToggleButton, {
			Position = UDim2.fromScale(0.75, 0.5),
			Size = UDim2.fromScale(0.08, 0.45),
			enabled = enabled,
			onToggle = onToggle,
		}),
	})
end

return function(props)
	local state = props.state

	local interfaceState = state.interface
	local visible, setVisible = React.useState(false)
	local xOffset, setXOffset = useSpring(-0.1)

	local optionComponents = {}
	for _, option in options do
		table.insert(optionComponents, createOption({
			name = option.name,
			enabled = interfaceState[option.setting] or false,
			onToggle = option.onToggle,
		}))
	end


	React.useEffect(function()
		setVisible(interfaceState.currentWindow == "Settings")
		setXOffset(interfaceState.currentWindow == "Settings" and 0 or -0.1)
	end, { interfaceState.currentWindow })

	return element(Modal, {
		Name = "Settings",
		Position = xOffset:map(function(value)
			return UDim2.fromScale(0.5 + value, 0.5)
		end),
		Size = UDim2.fromScale(0.5, 0.5),
		title = "Settings",
		Visible = visible,

		Children = {
			optionsList = element("ScrollingFrame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasSize = UDim2.fromScale(0, 0),
				Position = UDim2.fromScale(0.5, 0.5),
				ScrollBarThickness = 6,
				Size = UDim2.fromScale(0.8, 0.75),
			}, {
				uiListLayout = element("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),

				options = element(React.Fragment, nil, optionComponents),
			}),


		},
	})
end


