local RunService = game:GetService("RunService")
--[[
    A spring module that allows you to interpolate smoothly.
    Written by @umamidayo
]]

--!strict

-- Type definitions for supported operations
type Vector = Vector2 | Vector3
type SpringValue = number | Vector | Color3 | CFrame
type SpringParams = {
	initial: SpringValue,
	target: SpringValue?,
	speed: number?,
	damping: number?,
	threshold: number?,
}

--[[
	initial: The initial value of the spring.
	target: The target value of the spring.
	speed: Speed in units per second.
	damping: Spring factor, 1 is least springy, 0 is most springy.
	threshold: The threshold of the spring; when to consider the spring finished.
]]

-- Helper functions for generic operations
local function multiply(value: SpringValue, scalar: number): SpringValue
	local valueType = typeof(value)
	if valueType == "number" then
		return value * scalar
	elseif valueType == "Vector2" or valueType == "Vector3" then
		return value * scalar
	elseif valueType == "Color3" then
		-- Clamp color values between 0 and 1
		return Color3.new(
			math.clamp(value.R * scalar, 0, 1),
			math.clamp(value.G * scalar, 0, 1),
			math.clamp(value.B * scalar, 0, 1)
		)
	elseif valueType == "CFrame" then
		-- For CFrame, we'll interpolate both position and rotation
		local pos = value.Position * scalar
		local axis, angle = value:ToAxisAngle()
		return CFrame.new(pos) * CFrame.fromAxisAngle(axis, angle * scalar)
	end
	error("Unsupported type for multiplication: " .. valueType)
end

local function add(a: SpringValue, b: SpringValue): SpringValue
	local valueType = typeof(a)
	if valueType ~= typeof(b) then
		error("Cannot add values of different types")
	end

	if valueType == "number" then
		return a + b
	elseif valueType == "Vector2" or valueType == "Vector3" then
		return a + b
	elseif valueType == "Color3" then
		return Color3.new(math.clamp(a.R + b.R, 0, 1), math.clamp(a.G + b.G, 0, 1), math.clamp(a.B + b.B, 0, 1))
	elseif valueType == "CFrame" then
		-- For CFrame addition, we'll use CFrame multiplication which combines both position and rotation
		return a * b
	end
	error("Unsupported type for addition: " .. valueType)
end

local function subtract(a: SpringValue, b: SpringValue): SpringValue
	local valueType = typeof(a)
	if valueType ~= typeof(b) then
		error("Cannot subtract values of different types")
	end

	if valueType == "number" then
		return a - b
	elseif valueType == "Vector2" or valueType == "Vector3" then
		return a - b
	elseif valueType == "Color3" then
		return Color3.new(math.clamp(a.R - b.R, 0, 1), math.clamp(a.G - b.G, 0, 1), math.clamp(a.B - b.B, 0, 1))
	elseif valueType == "CFrame" then
		-- For CFrame subtraction, we use ToObjectSpace which gives us the relative transform from b to a
		return b:ToObjectSpace(a)
	end
	error("Unsupported type for subtraction: " .. valueType)
end

local function getZero(template: SpringValue): SpringValue
	local valueType = typeof(template)
	if valueType == "number" then
		return 0
	elseif valueType == "Vector2" then
		return Vector2.new(0, 0)
	elseif valueType == "Vector3" then
		return Vector3.new(0, 0, 0)
	elseif valueType == "Color3" then
		return Color3.new(0, 0, 0)
	elseif valueType == "CFrame" then
		return CFrame.identity
	end
	error("Unsupported type for zero value: " .. valueType)
end

-- Helper function to check if a value is below threshold
local function isBelowThreshold(value: SpringValue, threshold: number): boolean
	local valueType = typeof(value)
	if valueType == "number" then
		return math.abs(value) < threshold
	elseif valueType == "Vector2" then
		return value.Magnitude < threshold
	elseif valueType == "Vector3" then
		return value.Magnitude < threshold
	elseif valueType == "Color3" then
		return math.max(math.abs(value.R), math.abs(value.G), math.abs(value.B)) < threshold
	elseif valueType == "CFrame" then
		return value.Position.Magnitude < threshold
	end
	error("Unsupported type for threshold check: " .. valueType)
end

local Spring = {}
Spring.__index = Spring

-- Creates a new spring with the given parameters
function Spring.new(params: SpringParams)
	local self = setmetatable({}, Spring)

	self.Target = params.target or params.initial
	self.Position = params.initial
	self.Velocity = getZero(params.initial)
	self.Threshold = params.threshold or 0.1
	self.Speed = params.speed or 10
	self.Damping = params.damping or 1

	-- Track active connections
	self._connections = {}

	return self
end

-- Updates the spring physics
function Spring:Update(deltaTime: number): SpringValue
	local scaledDeltaTime = math.min(deltaTime, 1) * self.Speed

	-- Calculate spring force
	local displacement = subtract(self.Target, self.Position)
	local springForce = multiply(displacement, scaledDeltaTime * scaledDeltaTime)

	-- Apply spring physics
	self.Velocity = add(self.Velocity, springForce)
	self.Velocity = multiply(self.Velocity, (1 - math.min(self.Damping * scaledDeltaTime, 1)))
	self.Position = add(self.Position, self.Velocity)

	return self.Position
end

-- Sets a new target value
function Spring:SetTarget(target: SpringValue)
	self.Target = target
end

-- Gets the current position
function Spring:GetPosition()
	return self.Position
end

-- Resets the spring to a specific position
function Spring:Reset(position: SpringValue)
	self.Position = position
	self.Velocity = getZero(position)
end

function Spring:Hook(callback: (springValue: SpringValue) -> ()): () -> ()
	local connection
	connection = RunService.Heartbeat:Connect(function(deltaTime)
		-- Update spring internally
		local springValue = self:Update(deltaTime)

		-- Call callback with current position, maintaining the same type as Target
		callback(springValue)

		-- Check if spring has settled
		local displacement = subtract(self.Target, self.Position)
		if isBelowThreshold(self.Velocity, self.Threshold) and isBelowThreshold(displacement, self.Threshold) then
			-- Set final position to exactly match target before disconnecting
			self.Position = self.Target
			callback(self.Position)
			connection:Disconnect()
			table.remove(self._connections, table.find(self._connections, connection))
		end
	end)

	table.insert(self._connections, connection)

	return function()
		connection:Disconnect()
		table.remove(self._connections, table.find(self._connections, connection))
	end
end

-- Cleans up the spring and its resources
function Spring:Destroy()
	-- Disconnect all active connections
	for _, connection in self._connections do
		connection:Disconnect()
	end
	self._connections = nil

	self.Position = nil
	self.Velocity = nil
	self.Target = nil
	self.Speed = nil
	self.Damping = nil
	self.Threshold = nil
	setmetatable(self, nil)
end

return Spring
