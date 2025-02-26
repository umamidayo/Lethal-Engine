local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JournalData = require(ReplicatedStorage.Common.JournalData)
local React = require(ReplicatedStorage.Packages.React)

local Modal = require(ReplicatedStorage.Components.Modal)
local TextButton = require(ReplicatedStorage.Components.TextButton)

local useSpring = require(ReplicatedStorage.Hooks.useSpring)

local element = React.createElement

local function createTabs(currentTab, setTab)
	return {
		Zombies = element(TextButton, {
			BackgroundColor3 = currentTab == "Zombies" 
				and Color3.fromRGB(75, 75, 75) 
				or Color3.fromRGB(45, 45, 45),
			Size = UDim2.fromScale(0.4, 0.8),
			Text = "Zombies",
			LayoutOrder = 1,
			onClick = function()
				setTab("Zombies")
			end,
		}),

		Survival = element(TextButton, {
			BackgroundColor3 = currentTab == "Survival" 
				and Color3.fromRGB(75, 75, 75) 
				or Color3.fromRGB(45, 45, 45),
			Size = UDim2.fromScale(0.4, 0.8),
			Text = "Survival",
			LayoutOrder = 2,
			onClick = function()
				setTab("Survival")
			end,
		}),
	}
end

local function createJournalEntries(category)
	local entries = {}
	local data = category == "Zombies" and JournalData.zombieTypes or JournalData.survival

	for entryName, entryData in pairs(data) do
		entries[entryName] = element("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.2),
			LayoutOrder = entryData.layoutOrder,
		}, {
			Title = element("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.PermanentMarker,
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.fromScale(1, 0.4),
				Text = entryName,
				TextColor3 = entryData.titleColor or Color3.fromRGB(189, 59, 59),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			Description = element("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.PermanentMarker,
				Position = UDim2.fromScale(0, 0.35),
				Size = UDim2.fromScale(1, 1),
				Text = entryData.description,
				TextColor3 = Color3.fromRGB(220, 220, 220),
				TextScaled = true,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),
		})
	end
	return entries
end

local function createScrollingContainer(props)
	return element("ScrollingFrame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.53),
		Size = UDim2.fromScale(0.8, 0.65),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0),
		Visible = props.visible,
	}, {
		Layout = element("UIListLayout", {
			Padding = UDim.new(0, 60),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Padding = element("UIPadding", {
			PaddingLeft = UDim.new(0, 20),
			PaddingRight = UDim.new(0, 20),
			PaddingTop = UDim.new(0, 20),
			PaddingBottom = UDim.new(0, 20),
		}),

		Entries = element(React.Fragment, nil, props.entries),

		paddingSpacer = element("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 100,
			Size = UDim2.fromScale(0, 0.2),
		}),
	})
end

return function(props)
	local state = props.state
	local interfaceState = state.interface
	local visible, setVisible = React.useState(false)
	local xOffset, setXOffset = useSpring(-0.1)
	local currentTab, setTab = React.useState("Zombies")

	React.useEffect(function()
		setVisible(interfaceState.currentWindow == "Journal")
		setXOffset(interfaceState.currentWindow == "Journal" and 0 or -0.1)
	end, { interfaceState.currentWindow })

	local entries = currentTab == "Zombies" and createJournalEntries("Zombies") or createJournalEntries("Survival")
	local tabs = createTabs(currentTab, setTab)

	return element(Modal, {
		Name = "Journal",
		Position = xOffset:map(function(value)
			return UDim2.fromScale(0.5 + value, 0.5)
		end),
		Size = UDim2.fromScale(0.5, 0.85),
		title = "Journal",
		Visible = visible,
		Children = {
			TabsContainer = element("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0.1),
				Size = UDim2.fromScale(0.85, 0.08),
				BackgroundTransparency = 1,
			}, {
				Layout = element("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Tabs = element(React.Fragment, nil, tabs),
			}),

			entriesContainer = element(createScrollingContainer, {
				entries = entries,
			}),
		},
	})
end
