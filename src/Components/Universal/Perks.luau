local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Network = require(ReplicatedStorage.Common.Network)

local ClassCard = require(ReplicatedStorage.Components.ClassCard)
local IconButton = require(ReplicatedStorage.Components.IconButton)
local Modal = require(ReplicatedStorage.Components.Modal)
local PerkNode = require(ReplicatedStorage.Components.PerkNode)
local TextButton = require(ReplicatedStorage.Components.TextButton)
local Prompt = require(ReplicatedStorage.Components.Prompt)

local useSpring = require(ReplicatedStorage.Hooks.useSpring)

local Perks = {
	Doctor = require(ReplicatedStorage.Common.PlayerClass.Perks.Doctor),
	Engineer = require(ReplicatedStorage.Common.PlayerClass.Perks.Engineer),
	Survivor = require(ReplicatedStorage.Common.PlayerClass.Perks.Survivor),
}

local Classes = {
	Doctor = require(ReplicatedStorage.Common.PlayerClass.Classes.Doctor),
	Engineer = require(ReplicatedStorage.Common.PlayerClass.Classes.Engineer),
	Survivor = require(ReplicatedStorage.Common.PlayerClass.Classes.Survivor),
}

local element = React.createElement

local LocalPlayer = Players.LocalPlayer

local function createPerkNodes(playerClass: string, playerPerks: { string })
	local perkNodes = {}
	for perkName, perkData in Perks[playerClass] do
		local tier = perkData.Tier
		perkNodes[tier] = perkNodes[tier] or {}
		perkNodes[tier][perkName] = element(PerkNode, {
			perkData = perkData,
			perkName = perkName,
			isActive = table.find(playerPerks, perkName) ~= nil,
			playerPerks = playerPerks,
		})
	end

	local tierFrames = {}
	for tier = 1, 5 do
		tierFrames[tier] = element("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.4),
		}, {
			uiListLayout = element("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.05, 0),
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Wraps = true,
			}),

			perkNodes = element(React.Fragment, nil, perkNodes[tier]),
		})
	end

	return tierFrames
end

local function handleClassChange(selectedClass: string)
	Network.fireServer(Network.RemoteEvents.PlayerClassEvent, "ChangeClass", {
		className = selectedClass,
	})
end

local function handleResetPerks()
	Network.fireServer(Network.RemoteEvents.PlayerClassEvent, "ResetPerks")
end

return function(props)
	local state = props.state
	local interfaceState = state.interface
	local playerClass = state.playerClass[LocalPlayer.UserId] or {}
	local playerClasses = playerClass.classes or {}
	local className = playerClass.className or "Survivor"
	local playerPerks = playerClass.perks or {}
	local perkPoints = playerClass.perkpoints or 0

	local perkNodes = createPerkNodes(className, playerPerks)
	local showingClassList, setShowingClassList = React.useState(false)

	local visible, setVisible = React.useState(false)
	local xOffset, setXOffset = useSpring(-0.1)

	local promptVisible, setPromptVisible = React.useState(false)
	local promptText, setPromptText = React.useState("")
	local promptAction, setPromptAction = React.useState(nil)
	local selectedClass, setSelectedClass = React.useState(className)

	React.useEffect(function()
		setVisible(interfaceState.currentWindow == "Perks")
		setXOffset(interfaceState.currentWindow == "Perks" and 0 or -0.1)
	end, { interfaceState.currentWindow })

	return element(Modal, {
		Name = "Perks",
		Position = xOffset:map(function(value)
			return UDim2.fromScale(0.5 + value, 0.5)
		end),
		Size = UDim2.fromScale(0.65, 0.65),
		title = "Perks",
		Visible = visible,

		Children = {
			classInfo = element("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.07),
				Size = UDim2.fromScale(0.9, 0.1),
			}, {
				classLabel = element("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.65, 0),
					Size = UDim2.fromScale(0.2, 0.5),
					Text = `Class: {className}`,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					RichText = true,
					Font = Enum.Font.PermanentMarker,
				}),

				perkPoints = element("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.65, 0.5),
					Size = UDim2.fromScale(0.2, 0.5),
					Text = `Perk Points: <font color="rgb(150, 150, 210)">{perkPoints}</font>`,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					RichText = true,
					Font = Enum.Font.PermanentMarker,
				}),

				changeClass = element(TextButton, {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.3, 0.5),
					Size = UDim2.fromScale(0.2, 0.8),
					Text = showingClassList and "Perk Tree" or "Change Class",
					TextColor3 = Color3.fromRGB(255, 255, 255),

					onUp = function()
						setShowingClassList(not showingClassList)
					end,
				}, {
					corner = element("UICorner", {
						CornerRadius = UDim.new(0, 4),
					}),
				}),
			}),

			resetPerks = element(IconButton, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				backgroundTransparency = 1,
				Position = UDim2.fromScale(0.15, 0.15),
				Size = UDim2.fromScale(0.05, 0.1),
				Icon = "rbxassetid://16172430037",
				IconSize = UDim2.fromScale(1, 1),
				text = "Reset Perks",
				TextFrameSize = UDim2.fromScale(2, 0.25),
				onClick = function()
					setPromptVisible(true)
					setPromptText("Are you sure you want to reset your perks? This will also reset your character.")
					setPromptAction("resetPerks")
				end,
			}),

			perksList = not promptVisible and not showingClassList and element("ScrollingFrame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.52),
				Size = UDim2.fromScale(0.8, 0.65),
				CanvasSize = UDim2.fromScale(0, 0),
				ScrollBarThickness = 6,
			}, {
				uiListLayout = element("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.05, 0),
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),

				perkNodes = element(React.Fragment, nil, perkNodes),

				paddingSpacer = element("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 0.2),
					LayoutOrder = 999,
				}),
			}) or nil,

			classList = not promptVisible and showingClassList and element("ScrollingFrame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.52),
				Size = UDim2.fromScale(0.8, 0.65),
				CanvasSize = UDim2.fromScale(0, 0),
				ScrollBarThickness = 6,
			}, {
				uiListLayout = element("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),

				classNodes = element(React.Fragment, nil, {
					doctor = table.find(playerClasses, "Doctor") and element(ClassCard, {
						title = Classes.Doctor.Name,
						description = Classes.Doctor.Description,
						uiBackgroundColor = Classes.Doctor.uiBackgroundColor,
						onClick = function()
							setSelectedClass("Doctor")
							setPromptVisible(true)
							setPromptText("Are you sure you want to change to Doctor?")
							setPromptAction("changeClass")
						end,
					}) or nil,
					engineer = table.find(playerClasses, "Engineer") and element(ClassCard, {
						title = Classes.Engineer.Name,
						description = Classes.Engineer.Description,
						uiBackgroundColor = Classes.Engineer.uiBackgroundColor,
						onClick = function()
							setSelectedClass("Engineer")
							setPromptVisible(true)
							setPromptText("Are you sure you want to change to Engineer?")
							setPromptAction("changeClass")
						end,
					}) or nil,
					survivor = table.find(playerClasses, "Survivor") and element(ClassCard, {
						title = Classes.Survivor.Name,
						description = Classes.Survivor.Description,
						uiBackgroundColor = Classes.Survivor.uiBackgroundColor,
						onClick = function()
							setSelectedClass("Survivor")
							setPromptVisible(true)
							setPromptText("Are you sure you want to change to Survivor?")
							setPromptAction("changeClass")
						end,
					}) or nil,
				}),
			}) or nil,

			prompt = element(Prompt, {
				visible = promptVisible,
				text = promptText,
				onYes = function()
					setPromptVisible(false)
					if promptAction == "resetPerks" then
						handleResetPerks()
					elseif promptAction == "changeClass" then
						handleClassChange(selectedClass)
					end
					setPromptAction(nil)
				end,
				onNo = function()
					setPromptVisible(false)
					setPromptAction(nil)
				end,
			}),
		},
	})
end
