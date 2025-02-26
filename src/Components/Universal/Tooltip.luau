local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Dependencies.Sift)

local useMousePosition = require(ReplicatedStorage.Hooks.useMousePosition)

local e = React.createElement

type Props = {
	state: {
		interface: {
			tooltip: {
				visible: boolean,
				text: string,
				position: Vector2,
				title: string,
			},
		},
	},
}

return React.memo(function(props: Props)
	local tooltip = props.state.interface.tooltip
	local position = useMousePosition()

	return React.useMemo(function()
		return e("Frame", {
			Size = UDim2.fromScale(0.15, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.fromOffset(position.X, position.Y),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = tooltip.visible,
		}, {
			Background = e("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ImageColor3 = Color3.fromRGB(0, 0, 0),
				ImageTransparency = 0.5,
				Size = UDim2.fromScale(1.2, 1.2),
				Image = "rbxassetid://15613805162",
				ScaleType = Enum.ScaleType.Stretch,
				BackgroundTransparency = 1,
				ZIndex = 1,
			}),

			Content = e("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 2,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}),

				Padding = e("UIPadding", {
					PaddingBottom = UDim.new(0, 16),
					PaddingLeft = UDim.new(0, 16),
					PaddingRight = UDim.new(0, 0),
					PaddingTop = UDim.new(0, 0),
				}),

				Layout = e("UIListLayout", {
					Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Title = e("TextLabel", {
					Text = tooltip.title,
					TextColor3 = Color3.fromRGB(150, 150, 210),
					TextSize = 45,
					Font = Enum.Font.PermanentMarker,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					RichText = true,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 1,
					ZIndex = 2,
				}),

				Description = e("TextLabel", {
					Text = tooltip.text,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 25,
					Font = Enum.Font.PermanentMarker,
					AutomaticSize = Enum.AutomaticSize.Y,
					RichText = true,
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 2,
					ZIndex = 2,
				}),
			}),
		})
	end, { position, tooltip.visible, tooltip.title, tooltip.text })
end, function(prevProps, nextProps)
	return Sift.Dictionary.equals(prevProps.state.interface.tooltip, nextProps.state.interface.tooltip)
end)
