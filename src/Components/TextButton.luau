local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useSpring = require(ReplicatedStorage.Hooks.useSpring)

local element = React.createElement

return function(props)
	local hovered, setHovered = React.useState(false)
	local scale, setScale = useSpring(1)

	React.useEffect(function()
		setScale(hovered and 1.1 or 1)
	end, { hovered })

	return element("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = props.Position or UDim2.new(),
		Size = props.Size or UDim2.fromScale(0.2, 0.15),
	}, {
		uiScale = element("UIScale", {
			Scale = scale:map(function(value)
				return value
			end),
		}),

		button = element("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Text = "",

			[React.Event.Activated] = function()
				if props.onClick then
					props.onClick()
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
				if props.onDown then
					props.onDown()
				end
			end,

			[React.Event.MouseButton1Up] = function()
				setScale(1)
				if props.onUp then
					props.onUp()
				end
			end,
		}),

		textLabel = element("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.PermanentMarker,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.7),
			Text = props.Text,
			TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			ZIndex = 10,
		}),

		background = element("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://15612423388",
			ImageColor3 = props.BackgroundColor3 or Color3.fromRGB(56, 86, 56),
			ImageTransparency = props.BackgroundTransparency or 0.3,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
		}),
	})
end
