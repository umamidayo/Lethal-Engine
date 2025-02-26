local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local Hooks = ReplicatedStorage.Hooks

local useSpring = require(Hooks.useSpring)

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
		Position = props.Position,
		Size = props.Size,
		ZIndex = props.ZIndex or 10,
	}, {
		uiScale = element("UIScale", {
			Scale = scale:map(function(value)
				return value
			end),
		}),

		imageButton = element("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://15613833552",
			ImageColor3 = Color3.fromRGB(170, 51, 51),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1, 1),
			ZIndex = props.ZIndex or 10,
		}),

		button = element("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Text = "",
			ZIndex = props.ZIndex or 11,

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
			end,

			[React.Event.MouseButton1Up] = function()
				setScale(1)
			end,
		}),
	})
end
