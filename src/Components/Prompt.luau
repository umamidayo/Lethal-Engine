local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Modal = require(ReplicatedStorage.Components.Modal)
local TextButton = require(ReplicatedStorage.Components.TextButton)

local element = React.createElement

type Props = {
	text: string,
	onYes: () -> (),
	onNo: () -> (),
	visible: boolean,
}

return function(props: Props)
	return element(Modal, {
		Name = "Prompt",
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.3, 0.4),
		Visible = props.visible,
		zIndex = 10,
		hideCloseButton = true,
		Children = {
			Text = element("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.PermanentMarker,
				Position = UDim2.fromScale(0.5, 0.35),
				Size = UDim2.fromScale(0.9, 0.3),
				Text = props.text,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextWrapped = true,
				ZIndex = 10,
			}),

			ButtonContainer = element("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.7),
				Size = UDim2.fromScale(0.9, 0.3),
				ZIndex = 10,
			}, {
				Layout = element("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0.1, 0),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				Yes = element(TextButton, {
					BackgroundColor3 = Color3.fromRGB(71, 138, 71),
					Size = UDim2.fromScale(0.4, 1),
					Text = "Yes",
					onUp = props.onYes,
					ZIndex = 10,
				}),

				No = element(TextButton, {
					BackgroundColor3 = Color3.fromRGB(200, 50, 50),
					Size = UDim2.fromScale(0.4, 1),
					Text = "No",
					onUp = props.onNo,
					ZIndex = 10,
				}),
			}),
		},
	})
end
