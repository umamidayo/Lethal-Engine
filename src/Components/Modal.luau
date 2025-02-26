local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Store = require(ReplicatedStorage.Common.Store)

local CloseButton = require(ReplicatedStorage.Components.CloseButton)

local element = React.createElement

return function(props)
	local children = props.Children or {}
	props.hideCloseButton = props.hideCloseButton or false
	props.zIndex = props.zIndex or 1

	return element("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Name = props.Name or "Modal",
		Position = props.Position,
		Rotation = props.Rotation or 0,
		Size = props.Size,
		Visible = props.Visible,
		ZIndex = props.zIndex - 1,
	}, {
		background = element("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Image = "rbxassetid://15613805162",
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.3,
			ZIndex = props.zIndex,
		}),

		closeButton = not props.hideCloseButton and element(CloseButton, {
			Position = UDim2.fromScale(0.94, 0.08),
			Size = UDim2.fromScale(0.06, 0.1),
			ZIndex = props.zIndex,
			Visible = not props.hideCloseButton,

			onClick = function()
				if props.onClick then
					props.onClick()
				else
					Store:dispatch({
						type = "setWindow",
						window = "None",
					})
				end
			end,
		}),

		title = props.title and element("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.PermanentMarker,
			Position = UDim2.fromScale(0.5, 0.05),
			Size = props.titleSize or UDim2.fromScale(0.75, 0.15),
			Text = props.title,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			ZIndex = props.zIndex,
		}),
	}, children)
end
