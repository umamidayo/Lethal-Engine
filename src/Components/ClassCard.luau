local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local TextButton = require(ReplicatedStorage.Components.TextButton)

local element = React.createElement

return function(props)
    local title = props.title or "Class"
    local description = props.description or "No description available"
    local uiBackgroundColor = props.uiBackgroundColor or Color3.new(1, 1, 1)
    local layoutOrder = props.layoutOrder or 1

    return element("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.9, 0.75),
        LayoutOrder = layoutOrder,
    }, {
        Background = element("ImageLabel", {
            Image = "rbxassetid://15613805162",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = uiBackgroundColor,
            ZIndex = 1,
        }),

        Title = element("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.2),
            Size = UDim2.fromScale(0.8, 0.15),
            Text = title,
            TextColor3 = Color3.new(255, 255, 255),
            TextScaled = true,
            Font = Enum.Font.PermanentMarker,
            ZIndex = 2,
        }),

        Description = element("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.4),
            Size = UDim2.fromScale(0.8, 0.2),
            Text = description,
            TextColor3 = Color3.new(255, 255, 255),
            TextScaled = true,
            Font = Enum.Font.PermanentMarker,
            TextWrapped = true,
            ZIndex = 2,
        }),

        SelectButton = element(TextButton, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.7),
            Size = UDim2.fromScale(0.3, 0.25),
            Text = "Select",
            TextScaled = true,
            ZIndex = 2,

            onUp = function()
                if props.onClick then
                    props.onClick()
                end
            end,
        }),
    })
end