local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)

-- Constants
local MAX_DELTA = 1 / 30
local DEFAULT_PHASE_OFFSET = 0
local DEFAULT_FREQUENCY = 1
local DEFAULT_AMPLITUDE = 1
local FREQUENCY_MULTIPLIER = 1.25

-- Shared state for all sparkle instances
local ActiveInstances = {}
local SharedConnection = nil

-- Pre-allocate commonly used variables
local min = math.min
local abs = math.sin

-- Shared update function
local function updateInstances(dt)
	local limitedDt = min(dt, MAX_DELTA)

	for instance, setValue in pairs(ActiveInstances) do
		instance.age += limitedDt
		setValue(
			instance.amplitude
				* abs((instance.age * (instance.frequency * FREQUENCY_MULTIPLIER) + instance.phaseOffset) * math.pi)
		)
	end

	if next(ActiveInstances) == nil and SharedConnection then
		SharedConnection:Disconnect()
		SharedConnection = nil
	end
end

return function(phaseOffset: number?, frequency: number?, amplitude: number?): number
	local value, setValue = React.useState(0)

	-- Create instance ref
	local instanceRef = React.useRef({
		value = value,
		age = 0,
		phaseOffset = phaseOffset or DEFAULT_PHASE_OFFSET,
		frequency = frequency or DEFAULT_FREQUENCY,
		amplitude = amplitude or DEFAULT_AMPLITUDE,
	})

	React.useEffect(function()
		-- Create shared connection if it doesn't exist
		if not SharedConnection then
			SharedConnection = RunService.RenderStepped:Connect(updateInstances)
		end

		-- Add instance to active instances
		ActiveInstances[instanceRef.current] = setValue

		return function()
			-- Cleanup: remove instance from active instances on unmount
			ActiveInstances[instanceRef.current] = nil
		end
	end, {})

	return value
end
