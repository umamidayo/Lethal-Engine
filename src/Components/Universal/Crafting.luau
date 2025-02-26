local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Common.Network)
local React = require(ReplicatedStorage.Packages.React)

local Modal = require(ReplicatedStorage.Components.Modal)
local TextButton = require(ReplicatedStorage.Components.TextButton)
local IconButton = require(ReplicatedStorage.Components.IconButton)

-- TODO: Replace Notifier with ReactLua notification system.
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local StoreUtility = require(ReplicatedStorage.Common.StoreUtility)
local Store = require(ReplicatedStorage.Common.Store)

local useSpring = require(ReplicatedStorage.Hooks.useSpring)

local Items = require(ReplicatedStorage.Common.Items)

local LocalPlayer = Players.LocalPlayer

local element = React.createElement

local function getItemFromInventory(itemName: string)
	local character = LocalPlayer.Character
	local backpack = LocalPlayer.Backpack

	local totalItems = 0
	for _, item in character:GetChildren() do
		if item:IsA("Tool") and item.Name == itemName then
			totalItems += 1
		end
	end

	for _, item in backpack:GetChildren() do
		if item:IsA("Tool") and item.Name == itemName then
			totalItems += 1
		end
	end

	return totalItems
end

local function createCategories(setCategory: (string) -> ())
	return {
		all = element(IconButton, {
			Icon = "rbxassetid://15614001233",
			LayoutOrder = 0,
			Size = UDim2.fromScale(0.18, 1),
			squareBackground = true,
			text = "All",
			onClick = function()
				setCategory("All")
			end,
		}),

		tools = element(IconButton, {
			Icon = "rbxassetid://15614002386",
			LayoutOrder = 1,
			Size = UDim2.fromScale(0.18, 1),
			squareBackground = true,
			text = "Tools",
			onClick = function()
				setCategory("Tools")
			end,
		}),

		rations = element(IconButton, {
			Icon = "rbxassetid://15614003530",
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.18, 1),
			squareBackground = true,
			text = "Rations",
			onClick = function()
				setCategory("Rations")
			end,
		}),

		medical = element(IconButton, {
			Icon = "rbxassetid://15614005083",
			LayoutOrder = 3,
			Size = UDim2.fromScale(0.18, 1),
			squareBackground = true,
			text = "Medical",
			onClick = function()
				setCategory("Medical")
			end,
		}),

		materials = element(IconButton, {
			Icon = "rbxassetid://15614005732",
			LayoutOrder = 4,
			Size = UDim2.fromScale(0.18, 1),
			squareBackground = true,
			text = "Materials",
			onClick = function()
				setCategory("Materials")
			end,
		}),
	}
end

local function createItems(itemType: string, setSelectedItem: (string) -> ())
	local items = {}
	for itemName, itemInfo in Items do
		if typeof(itemInfo) ~= "table" then
			continue
		end

		if itemType ~= "All" then
			local tags = itemInfo.Tags or {}
			if not table.find(tags, itemType) then
				continue
			end
		end

		items[itemName] = element(TextButton, {
			BackgroundColor3 = Color3.fromRGB(75, 75, 75),
			Size = UDim2.fromScale(0.9, 0.15),
			Text = itemInfo.Name,
			onClick = function()
				setSelectedItem(itemInfo)
			end,
		})
	end

	return items
end

local function createItemIngredients(ingredients, quantity: number)
	local materials = StoreUtility.waitForValue("inventory", LocalPlayer.UserId, "materials")

	if not ingredients then
		return
	end

	local layoutOrder = 0
	local itemIngredients = {}
	for itemName, itemAmount in ingredients do
		layoutOrder += 1

		local materialsAmount = materials[itemName] or getItemFromInventory(itemName)
		local textColor = materialsAmount >= itemAmount * quantity
			and Color3.fromRGB(75, 163, 75)
			or Color3.fromRGB(201, 69, 69)

		itemIngredients[itemName] = element("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			Size = UDim2.fromScale(1, 0.12),
		}, {
			itemNameLabel = element("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.PermanentMarker,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(0.5, 1),
				Text = itemName,
				TextColor3 = textColor,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			itemAmountLabel = element("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.PermanentMarker,
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromScale(0.5, 1),
				Text = `{itemAmount * quantity} ({materialsAmount})`,
				TextColor3 = textColor,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
			}),
		})
	end

	return itemIngredients
end

local function createMaterials(materials)
	if not materials then
		return
	end

	local materialItems = {}
	for materialName, materialAmount in materials do
		if materialAmount == 0 then
			continue
		end

		materialItems[materialName] = element("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.08),
		}, {
			materialLabel = element("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.PermanentMarker,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(0.75, 1),
				Text = materialName,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
			}),

			materialAmountLabel = element("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.PermanentMarker,
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromScale(0.25, 0.75),
				Text = `{materialAmount} / 99`,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
			}),
		})
	end

	return materialItems
end

local function craftItem(itemName: string, quantity: number)
	local success, message = Network.invokeServerAsync(Network.RemoteFunctions.Craft, itemName, quantity)
	if not success then
		Notifier.new(message)
	else
		Notifier.new(`Successfully crafted {quantity} {quantity > 1 and "units" or "unit"} of {itemName}`)
	end
end

return function(props)
	local state = props.state
	local interfaceState = state.interface
	local inventory = state.inventory[LocalPlayer.UserId] or {}
	local materialsData = inventory.materials or {}

	local visible, setVisible = React.useState(false)
	local category, setCategory = React.useState("All")
	local selectedItem, setSelectedItem = React.useState(nil)
	local quantity, setQuantity = React.useState(1)

	local categories = createCategories(setCategory)
	local items = createItems(category, setSelectedItem)
	local itemIngredients = createItemIngredients(selectedItem and selectedItem.Ingredients, quantity)
	local materials = createMaterials(materialsData)

	local xOffset, setXOffset = useSpring(-0.1)

	React.useEffect(function()
		setVisible(interfaceState.currentWindow == "Crafting")
		setXOffset(interfaceState.currentWindow == "Crafting" and 0 or -0.1)
	end, { interfaceState.currentWindow })

	React.useEffect(function()
		setQuantity(1)
	end, { selectedItem })

	return element(Modal, {
		Name = "Crafting",
		Position = xOffset:map(function(value)
			return UDim2.fromScale(0.5 + value, 0.5)
		end),
		Size = UDim2.fromScale(0.75, 0.75),
		title = "Crafting",
		Visible = visible,

		Children = {
			craftButton = element(TextButton, {
				Position = UDim2.fromScale(0.82, 0.78),
				Size = UDim2.fromScale(0.2, 0.1),
				Text = "Craft",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundColor3 = Color3.fromRGB(56, 86, 56),
				onClick = function()
					craftItem(selectedItem.Name, quantity)
				end,
			}),

			quantityFrame = element("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.82, 0.65),
				Size = UDim2.fromScale(0.12, 0.1),
			}, {
				decrementButton = element(TextButton, {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromScale(0.5, 0.8),
					Text = "-",
					onClick = function()
						setQuantity(math.clamp(quantity - 1, 1, 99))
					end,
				}),

				quantityLabel = element("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Font = Enum.Font.PermanentMarker,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.75, 0.65),
					Text = quantity,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
				}),

				incrementButton = element(TextButton, {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(1, 0.5),
					Size = UDim2.fromScale(0.5, 0.8),
					Text = "+",
					onClick = function()
						setQuantity(math.clamp(quantity + 1, 1, 99))
					end,
				}),
			}),

			craftLocation = selectedItem and selectedItem.BuildRequired and element("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.PermanentMarker,
				Position = UDim2.fromScale(0.82, 0.58),
				Size = UDim2.fromScale(0.2, 0.04),
				Text = `Craft at a {selectedItem.BuildRequired}`,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,

				[React.Event.MouseEnter] = function()
					Store:dispatch({
						type = "setTooltip",
						visible = true,
						text = `Must be near a {selectedItem.BuildRequired} to craft`,
						position = UDim2.fromScale(0.82, 0.58),
						title = "Requirement",
					})
				end,

				[React.Event.MouseLeave] = function()
					Store:dispatch({
						type = "setTooltip",
						visible = false,
					})
				end,
			}),

			categoryFrame = element("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.62, 0.2),
				Size = UDim2.fromScale(0.45, 0.12),
			}, {
				uiListLayout = element("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				categories = element(React.Fragment, nil, categories),
			}),

			itemsFrame = element("ScrollingFrame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasSize = UDim2.fromScale(0, 0),
				Position = UDim2.fromScale(0.55, 0.55),
				ScrollBarThickness = 6,
				Size = UDim2.fromScale(0.3, 0.55),
			}, {
				uiListLayout = element("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),

				items = element(React.Fragment, nil, items),
			}),

			materialsHeader = element("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.PermanentMarker,
				Position = UDim2.fromScale(0.25, 0.2),
				Size = UDim2.fromScale(0.2, 0.06),
				Text = "Materials",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
			}),

			materialsFrame = element("ScrollingFrame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasSize = UDim2.fromScale(0, 0),
				Position = UDim2.fromScale(0.25, 0.55),
				ScrollBarThickness = 6,
				Size = UDim2.fromScale(0.25, 0.58),
			}, {
				uiListLayout = element("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),

				materials = materials and element(React.Fragment, nil, materials),
			}),

			selectedItemFrame = selectedItem and element("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.82, 0.43),
				Size = UDim2.fromScale(0.2, 0.3),
			}, {
				uiListLayout = element("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				textLabel = element("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Font = Enum.Font.PermanentMarker,
					LayoutOrder = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 0.15),
					Text = selectedItem.Name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
				}),

				ingredients = element(React.Fragment, nil, itemIngredients),
			}),
		},
	})
end
