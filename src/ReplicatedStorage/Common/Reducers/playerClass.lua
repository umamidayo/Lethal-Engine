local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cryo = require(ReplicatedStorage.Packages.Cryo)

local initialState = {}

local actions = {
	SETUP_PLAYER = function(state, action)
		local userId = action.userId
		local className = action.className
		local level = action.level
		local experience = action.experience
		local requiredExperience = action.requiredExperience
		local perkpoints = action.perkpoints
		local perks = action.perks
		local classes = action.classes

		return state[userId]
				and Cryo.Dictionary.join(state, {
					[userId] = Cryo.Dictionary.join(state[userId], {
						className = className,
						level = level,
						experience = experience,
						requiredExperience = requiredExperience,
						perkpoints = perkpoints,
						perks = perks,
						classes = classes,
					}),
				})
			or state
	end,

	INCREMENT_LEVEL = function(state, action)
		local userId = action.userId
		local increment = action.increment
		local requiredExperience = action.requiredExperience

		if state[userId] and state[userId].level and state[userId].level < 10 then
			return state[userId]
					and Cryo.Dictionary.join(state, {
						[userId] = Cryo.Dictionary.join(state[userId], {
							level = state[userId].level + increment,
							experience = 0,
							requiredExperience = requiredExperience,
							perkpoints = state[userId].perkpoints + increment,
						}),
					})
				or state
		end

		return state
	end,

	INCREMENT_EXP = function(state, action)
		local userId = action.userId

		if state[userId] and state[userId].level and state[userId].level >= 10 then
			return state[userId]
					and Cryo.Dictionary.join(state, {
						[userId] = Cryo.Dictionary.join(state[userId], {
							experience = state[userId].requiredExperience,
						}),
					})
				or state
		end

		local increment = action.increment
		if state[userId] and state[userId].experience then
			return state[userId]
					and Cryo.Dictionary.join(state, {
						[userId] = Cryo.Dictionary.join(state[userId], {
							experience = state[userId].experience + increment,
						}),
					})
				or state
		end

		return state
	end,

	CLEANUP_PLAYER = function(state, action)
		local userId = action.userId

		return Cryo.Dictionary.join(state, {
			[userId] = Cryo.None,
		}) or state
	end,

	SPEND_PERK_POINT = function(state, action)
		local userId = action.userId
		local perkName = action.perkName
		local perks = state[userId].perks

		if state[userId] and state[userId].perkpoints then
			return state[userId]
					and Cryo.Dictionary.join(state, {
						[userId] = Cryo.Dictionary.join(state[userId], {
							perkpoints = state[userId].perkpoints - 1,
							perks = Cryo.List.join(perks, { perkName }),
						}),
					})
				or state
		end

		return state
	end,

	RESET_PERKS = function(state, action)
		local userId = action.userId

		if state[userId] and state[userId].perkpoints then
			return state[userId]
					and Cryo.Dictionary.join(state, {
						[userId] = Cryo.Dictionary.join(state[userId], {
							perkpoints = state[userId].level,
							perks = {},
						}),
					})
				or state
		end

		return state
	end,

	ADD_CLASS = function(state, action)
		local userId = action.userId
		local class = action.class

		if state[userId] and state[userId].classes then
			return state[userId]
					and Cryo.Dictionary.join(state, {
						[userId] = Cryo.Dictionary.join(state[userId], {
							classes = Cryo.List.join(state[userId].classes, { class }),
						}),
					})
				or state
		end

		return state
	end,
}

return function(state, action)
	state = state or initialState
	local actionHandler = actions[action.type]

	if action.userId and not state[action.userId] then
		state[action.userId] = {}
	end

	if actionHandler then
		return actionHandler(state, action)
	end

	return state
end
