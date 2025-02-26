local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cryo = require(ReplicatedStorage.Packages.Cryo)

type MaterialData = { [string]: number }

local initialState = {}

local actions = {
	setMaterials = function(state, action)
		local userId = action.userId
		local materials: MaterialData = action.materials

		return state[userId]
				and Cryo.Dictionary.join(state, {
					[userId] = Cryo.Dictionary.join(state[userId], {
						materials = Cryo.Dictionary.join(state[userId].materials, materials),
					}),
				})
			or state
	end,
}

return function(state, action)
	state = state or initialState
	local actionHandler = actions[action.type]

	if action.userId and not state[action.userId] then
		state[action.userId] = {
			materials = {},
		}
	end

	if actionHandler then
		return actionHandler(state, action)
	end

	return state
end
