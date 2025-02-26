local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Common.Libraries.Signal)

local StateManager = {}
StateManager.__index = StateManager

-- Creates a new state object
function StateManager.new(initialState)
	local self = setmetatable({
		state = initialState,
		changed = Signal.new(),
	}, StateManager)

	return self
end

-- Waits for the value of the key name
function StateManager:waitForValue(key: string)
	local value = self.state[key]

	if value then
		return value
	end

	local promise = Instance.new("BindableEvent")
	local connection

	connection = self.changed:Connect(function(newState)
		if newState[key] then
			promise:Fire(newState[key])
			connection:Disconnect()
		end
	end)

	return promise.Event:Wait()
end

-- Sets a key in the state to a new value
function StateManager:setValue(key: string, value: any)
	local newState = { [key] = value }

	for k, v in pairs(self.state) do
		if k ~= key then
			newState[k] = v
		end
	end

	self.state = newState
	self.changed:Fire(newState)
end

-- Sets the entire state to a new table
function StateManager:setState(newState: table)
	self.state = newState
	self.changed:Fire(newState)
end

return StateManager
