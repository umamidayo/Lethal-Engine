local UI_Animations = {}

local TweenService = game:GetService("TweenService")

UI_Animations.TabEnter = function(tab: Frame, ImageButton: ImageButton, ImageSize: UDim2)
	tab.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	TweenService:Create(ImageButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{
		Rotation = -10,
		Size = ImageSize + UDim2.new(0.1, 0, 0.1, 0)
	}):Play()
end

UI_Animations.TabLeave = function(tab: Frame, ImageButton: ImageButton, ImageSize: UDim2)
	tab.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	TweenService:Create(ImageButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{
		Rotation = 0,
		Size = ImageSize
	}):Play()
end

UI_Animations.Slide = function(GuiObject: GuiObject, Destination: UDim2)
	TweenService:Create(GuiObject, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Position = Destination
	}):Play()
end

return UI_Animations
