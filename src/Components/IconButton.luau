local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useSpring = require(ReplicatedStorage.Hooks.useSpring)

local element = React.createElement

return function(props)
	local hovered, setHovered = React.useState(false)
	local scale, setScale = useSpring(1)

	local backgroundColor3 = props.backgroundColor3
	local backgroundTransparency = props.backgroundTransparency
	local Icon = props.Icon
	local IconSize = props.IconSize
	local LayoutOrder = props.LayoutOrder
	local onClick = props.onClick
	local Position = props.Position
	local Size = props.Size
	local squareBackground = props.squareBackground
	local text = props.text
	local TextFrameSize = props.TextFrameSize

	React.useEffect(function()
		setScale(hovered and 1.1 or 1)
	end, { hovered })

	return element("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = Position or UDim2.new(),
		Size = Size or UDim2.fromScale(0.08, 0.25),
		LayoutOrder = LayoutOrder or 0,
	}, {
		uiScale = element("UIScale", {
			Scale = scale:map(function(value)
				return value
			end),
		}),

		background = element("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = squareBackground and "rbxassetid://15612015686" or "rbxassetid://15612076928",
			ImageColor3 = backgroundColor3 or Color3.fromRGB(0, 0, 0),
			ImageTransparency = backgroundTransparency or 0.3,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
		}),

		icon = element("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = Icon,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = IconSize or UDim2.fromScale(0.5, 0.5),
			ZIndex = 10,
		}),

		button = element("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Text = "",
			ZIndex = 11,

			[React.Event.Activated] = function()
				if onClick then
					onClick()
				end
			end,

			[React.Event.MouseEnter] = function()
				setHovered(true)
			end,

			[React.Event.MouseLeave] = function()
				setHovered(false)
			end,

			[React.Event.MouseButton1Down] = function()
				setScale(1 - 0.1 * scale:getValue())
			end,

			[React.Event.MouseButton1Up] = function()
				setScale(1)
			end,
		}),

		hoverText = text and element("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.PermanentMarker,
			Position = UDim2.fromScale(0.5, 1),
			Size = TextFrameSize or UDim2.fromScale(1, 0.25),
			Text = text,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			Visible = hovered,
			ZIndex = 11,
		}),
	})
end
