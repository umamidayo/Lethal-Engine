local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)

return function(initialValue: number, duration: number?)
	local value, setValue = React.useState(initialValue)

	local linearRef = React.useRef({
		target = initialValue,
		startValue = initialValue,
		startTime = 0,
		duration = duration or 0.3,
		isAnimating = false,
		initialValue = initialValue,
	})

	local function setTarget(newTarget: number)
		local linear = linearRef.current
		linear.startValue = value
		linear.target = newTarget
		linear.startTime = os.clock()
		linear.isAnimating = true
	end

	React.useEffect(function()
		local connection = RunService.RenderStepped:Connect(function()
			local linear = linearRef.current

			if linear.isAnimating then
				local elapsed = os.clock() - linear.startTime
				local alpha = math.clamp(elapsed / linear.duration, 0, 1)

				-- Linear interpolation
				local newValue = linear.startValue + (linear.target - linear.startValue) * alpha
				setValue(newValue)

				-- Stop animation when complete
				if alpha >= 1 then
					linear.isAnimating = false
					setValue(linear.initialValue)
				end
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	return value, setTarget
end
