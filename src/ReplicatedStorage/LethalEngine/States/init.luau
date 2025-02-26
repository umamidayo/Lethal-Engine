local States = {}
States.__index = States

function States.new(initialState: { any }?)
	local self = setmetatable({}, States)
	self.state = initialState or {}
	return self
end

function States:waitForValue(...: any): any?
	local params = { ... }
	local state = self.state
	local currentValue = state

	for i, key in params do
		if not currentValue[key] then
			local startTime = os.time()
			repeat
				task.wait(0.1)
				state = self.state
				currentValue = state
				for j = 1, i - 1 do
					currentValue = currentValue[params[j]]
				end
			until currentValue[key] or os.time() - startTime > 10

			if os.time() - startTime > 10 then
				warn(`Failed to find value {key} in path:`)
				print(state)
				return nil
			end
		end
		currentValue = currentValue[key]
	end

	return currentValue
end

function States:getValue(...: any): any?
	local params = { ... }
	local currentValue = self.state

	for _, key in params do
		if not currentValue[key] then
			return nil
		end
		currentValue = currentValue[key]
	end

	return currentValue
end

function States:setValue(...: any): ()
	local params = { ... }
	local value = params[#params]
	local currentValue = self.state

	for i = 1, #params - 2 do
		local key = params[i]
		if not currentValue[key] then
			currentValue[key] = {}
		end
		currentValue = currentValue[key]
	end

	local finalKey = params[#params - 1]
	currentValue[finalKey] = value

	return currentValue[finalKey]
end

return States
