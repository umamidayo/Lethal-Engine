local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)

-- Constants
local DEFAULT_AMPLITUDE = 0.25
local DEFAULT_FREQUENCY = 1

-- Shared state for all bob animations
local ActiveBobs = {}
local SharedConnection = nil
local StartTime = os.clock()

-- Pre-allocate commonly used variables
local sin = math.sin
local pi = math.pi
local cos = math.cos

-- Shared update function
local function updateBobs()
	local currentTime = os.clock()
	local elapsed = currentTime - StartTime

	local hasActiveBobs = false
	for bob, setValue in pairs(ActiveBobs) do
		local x = bob.amplitudeX * cos(2 * pi * bob.frequencyX * elapsed)
		local y = bob.amplitudeY * sin(2 * pi * bob.frequencyY * elapsed)
		setValue({ x = x, y = y })
		hasActiveBobs = true
	end

	if not hasActiveBobs and SharedConnection then
		SharedConnection:Disconnect()
		SharedConnection = nil
	end
end

return function(config: {
	amplitudeX: number?,
	amplitudeY: number?,
	frequencyX: number?,
	frequencyY: number?,
}?): (number, number)
	local x, setX = React.useState(0)
	local y, setY = React.useState(0)

	local bobRef = React.useRef({
		amplitudeX = config and config.amplitudeX or DEFAULT_AMPLITUDE,
		amplitudeY = config and config.amplitudeY or DEFAULT_AMPLITUDE,
		frequencyX = config and config.frequencyX or DEFAULT_FREQUENCY,
		frequencyY = config and config.frequencyY or DEFAULT_FREQUENCY,
	})

	React.useEffect(function()
		if not SharedConnection then
			StartTime = os.clock()
			SharedConnection = RunService.RenderStepped:Connect(updateBobs)
		end

		ActiveBobs[bobRef.current] = function(newPosition)
			setX(newPosition.x)
			setY(newPosition.y)
		end

		return function()
			ActiveBobs[bobRef.current] = nil
		end
	end, {})

	return x, y
end
