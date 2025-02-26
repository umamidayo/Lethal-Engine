local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)

-- Constants
local DEFAULT_SPEED = 1500 -- 15 * 100
local DEFAULT_DAMPING = 0.2
local MAX_DELTA = 1 / 30

-- Pre-allocate commonly used variables
local abs = math.abs
local min = math.min

return function(initialValue: number, config: { speed: number?, damping: number? }?, enabled: boolean?)
	local value, setValue = React.useBinding(initialValue)

	-- Create spring ref with memoized config
	local springRef = React.useRef({
		target = initialValue,
		position = initialValue,
		velocity = 0,
		speed = config and config.speed * 100 or DEFAULT_SPEED,
		damping = config and config.damping or DEFAULT_DAMPING,
		lastUpdateTime = os.clock(),
		active = true,
	})

	local function setTarget(newTarget: number)
		local spring = springRef.current

		spring.target = newTarget
		spring.active = true
	end

	React.useEffect(function()
		if enabled == false then
			return
		end

		local connection = RunService.RenderStepped:Connect(function(dt)
			local spring = springRef.current

			if spring.active then
				local limitedDt = min(dt, MAX_DELTA)

				if abs(spring.target - spring.position) < 0.005 and abs(spring.velocity) < 0.005 then
					spring.position = spring.target
					spring.velocity = 0
					spring.active = false
					setValue(spring.position)
				else
					local force = (spring.target - spring.position) * spring.speed
					spring.velocity = (spring.velocity * spring.damping) + (force * limitedDt)
					spring.position = spring.position + spring.velocity * limitedDt
					setValue(spring.position)
				end
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, { enabled })

	return value, setTarget
end
