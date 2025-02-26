local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)

local function useMousePosition()
	local position, setPosition = React.useState(Vector2.new())

	React.useEffect(function()
		local connection = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				setPosition(Vector2.new(input.Position.X + 20, input.Position.Y + 20))
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	return position
end

return useMousePosition
