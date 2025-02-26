local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useSpring = require(ReplicatedStorage.Hooks.useSpring)

local element = React.createElement

return function(props)
    local enabled, setEnabled = React.useState(props.enabled or false)

    local xPosition, setXPosition = useSpring(enabled and 0.7 or 0.3)
    local huePosition, setHuePosition = useSpring(enabled and 0.33 or 0)

    React.useEffect(function()
        setXPosition(enabled and 0.7 or 0.3)
        setHuePosition(enabled and 0.33 or 0)
    end, { enabled })

    return element("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = props.Position or UDim2.new(),
        Size = props.Size or UDim2.fromScale(0.15, 0.15),
    }, {
        background = element("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = huePosition:map(function(hue)
                return Color3.fromHSV(hue, 0.75, 0.5)
            end),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 0, 1, 0),
        }, {
            uiCorner = element("UICorner", {
                CornerRadius = UDim.new(1, 0),
            }),
        }),

        clickButton = element("ImageButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),

            [React.Event.Activated] = function()
                if props.onToggle then
                    props.onToggle(not enabled)
                end
                setEnabled(not enabled)
            end,
        }),

        slider = element("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Position = xPosition:map(function(value)
                return UDim2.fromScale(value, 0.5)
            end),
            Size = UDim2.fromScale(0.5, 0.8),
        }, {
            uiCorner = element("UICorner", {
                CornerRadius = UDim.new(1, 0),
            }),

            uiGradient = element("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(145, 145, 145)),
                }),
                Rotation = 90,
            })
        }),
    })
end

