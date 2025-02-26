local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local Modal = require(ReplicatedStorage.Components.Modal)

local UpdateLogData = require(ReplicatedStorage.Common.UpdateLogData)

local element = React.createElement

local function LogSection(props)
	local logs = {}
	for index, item in props.items do
		table.insert(
			logs,
			element("TextLabel", {
				BackgroundTransparency = 1,
				Text = "• " .. item,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextSize = 32,
				Font = Enum.Font.PermanentMarker,
				TextWrapped = true,
				Size = UDim2.fromScale(0.95, 0),
				Position = UDim2.fromScale(0.05, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = index,
			})
		)
	end

	return element("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.layoutOrder,
	}, {
		Header = element("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.08),
			LayoutOrder = 1,
		}, {
			Padding = element("UIPadding", {
				PaddingBottom = UDim.new(0, 20),
			}),

			Icon = element("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.05, 0.5),
				BackgroundTransparency = 1,
				Image = UpdateLogData.icons[props.logType],
				ImageColor3 = props.iconColor,
				Size = UDim2.fromOffset(32, 32),
			}),

			Title = element("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.12, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.PermanentMarker,
				Text = string.upper(props.logType),
				TextColor3 = props.iconColor,
				TextSize = 36,
				Size = UDim2.fromScale(0.8, 0.8),
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		}),

		Content = element("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 0.3),
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
		}, {
			Layout = element("UIListLayout", {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),

			Logs = element(React.Fragment, nil, logs),
		}),
	})
end

return function()
	local visible, setVisible = React.useState(true)

	return element(Modal, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.45, 0.85),
		Name = "UpdateLog",
		Visible = visible,
		title = "Update Version " .. UpdateLogData.version,
		titleSize = UDim2.fromScale(0.75, 0.075),

		onClick = function()
			setVisible(false)
		end,

		Children = {
			updateDate = element("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.11),
				Size = UDim2.fromScale(0.25, 0.03),
				BackgroundTransparency = 1,
				Font = Enum.Font.PermanentMarker,
				Text = UpdateLogData.date,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Center,
			}),

			ScrollingFrame = element("ScrollingFrame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0.12),
				Size = UDim2.fromScale(0.75, 0.68),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromScale(0, 0),
				ScrollBarThickness = 4,
				ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
			}, {
				Layout = element("UIListLayout", {
					Padding = UDim.new(0.1, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Padding = element("UIPadding", {
					PaddingTop = UDim.new(0, 24),
					PaddingBottom = UDim.new(0, 24),
				}),

				New = element(LogSection, {
					logType = "new",
					items = UpdateLogData.new,
					iconColor = UpdateLogData.iconColors.new,
					layoutOrder = 1,
				}),

				Changes = element(LogSection, {
					logType = "changes",
					items = UpdateLogData.changes,
					iconColor = UpdateLogData.iconColors.changes,
					layoutOrder = 2,
				}),

				Fixes = element(LogSection, {
					logType = "fixes",
					items = UpdateLogData.fixes,
					iconColor = UpdateLogData.iconColors.fixes,
					layoutOrder = 3,
				}),
			}),
		},
	})
end
