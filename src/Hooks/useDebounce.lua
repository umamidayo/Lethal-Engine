local React = require(game:GetService("ReplicatedStorage").Packages.React)

local function useDebounce(value: any, delay: number)
	local debouncedValue, setDebouncedValue = React.useState(value)
	local timerRef = React.useRef(nil)

	React.useEffect(function()
		-- Clear existing timer
		if timerRef.current then
			task.cancel(timerRef.current)
		end

		-- Set new timer
		timerRef.current = task.delay(delay, function()
			setDebouncedValue(value)
			timerRef.current = nil
		end)

		-- Cleanup
		return function()
			if timerRef.current then
				task.cancel(timerRef.current)
			end
		end
	end, { value })

	return debouncedValue
end

return useDebounce
