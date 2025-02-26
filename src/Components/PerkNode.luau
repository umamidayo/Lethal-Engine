local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Network = require(ReplicatedStorage.Common.Network)

local useSpring = require(ReplicatedStorage.Hooks.useSpring)
local Store = require(ReplicatedStorage.Common.Store)
local useDebounce = require(ReplicatedStorage.Hooks.useDebounce)

local element = React.createElement

-- Move tooltip text construction outside component to prevent recreating function
local function constructTooltipText(description: string, requirements: { string }?, playerPerks: { string })
	if not requirements then
		return description
	end

	local text = description .. "\n\nRequirements:"
	for _, requirement in requirements do
		local hasRequirement = table.find(playerPerks, requirement) ~= nil
		local color = hasRequirement and "rgb(71, 138, 71)" or "rgb(200, 50, 50)"
		text = text .. `\n<font color="{color}">• {requirement}</font>`
	end
	return text
end

return function(props)
	local perkData = props.perkData
	local perkName = props.perkName
	local isActive = props.isActive

	local hovered, setHovered = React.useState(false)
	local sizeScale, setSizeScale = useSpring(1, {
		speed = 50,
	})

	-- Reduce debounce time to improve responsiveness while still preventing spam
	local debouncedHovered = useDebounce(hovered, 0.033)

	-- Cache tooltip text
	local tooltipText = React.useMemo(function()
		return constructTooltipText(perkData.Description, perkData.Requirements, props.playerPerks)
	end, { perkData.Description, perkData.Requirements, props.playerPerks })

	-- Handle tooltip visibility with a single dispatch
	React.useEffect(function()
		setSizeScale(debouncedHovered and 1.1 or 1)

		Store:dispatch({
			type = "setTooltip",
			visible = debouncedHovered,
			title = debouncedHovered and perkName or "",
			text = debouncedHovered and tooltipText or "",
		})
	end, { debouncedHovered })

	-- Memoize the button to prevent unnecessary re-renders
	local button = React.useMemo(function()
		return element("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = sizeScale:map(function(value)
				return UDim2.fromScale(1 * value, 1 * value)
			end),
			Image = "rbxassetid://15612076928",
			ImageColor3 = isActive and Color3.fromRGB(71, 138, 71) or Color3.fromRGB(56, 56, 56),
			ScaleType = Enum.ScaleType.Fit,

			[React.Event.MouseButton1Click] = function()
				Network.fireServer(Network.RemoteEvents.PlayerClassEvent, "SpendPerkPoint", {
					perkName = perkName,
				})
			end,

			[React.Event.MouseEnter] = function()
				setHovered(true)
			end,

			[React.Event.MouseLeave] = function()
				setHovered(false)
			end,
		})
	end, { sizeScale, isActive, perkName })

	-- Memoize the text label
	local textLabel = React.useMemo(function()
		return element("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.PermanentMarker,
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(hovered and 1.25 or 1, 0.25),
			Text = perkName,
			TextColor3 = hovered and Color3.fromRGB(255, 232, 148) or Color3.fromRGB(255, 255, 255),
			TextScaled = true,
		})
	end, { hovered, perkName })

	return element(React.Fragment, nil, {
		perkNode = element("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = props.Position or UDim2.fromScale(0.5, 0.5),
			Size = props.Size or UDim2.fromScale(0.1, 0.9),
		}, {
			button = button,
			perkName = textLabel,
		}),
	})
end
