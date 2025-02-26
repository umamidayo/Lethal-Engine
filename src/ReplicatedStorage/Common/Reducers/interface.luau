local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cryo = require(ReplicatedStorage.Packages.Cryo)

local initialState = {
	currentWindow = "None",
	hideUI = false,
	muteRadios = false,
	highlightPlayers = true,
	playerTags = true,
	tooltip = {
		visible = false,
		text = "",
		title = "",
	},
}

local actions = {
	setupInterface = function(state)
		return Cryo.Dictionary.join(state, initialState)
	end,

	setWindow = function(state, action)
		return state and Cryo.Dictionary.join(state, {
			currentWindow = action.window,
		}) or state
	end,

	setSetting = function(state, action)
		return state and Cryo.Dictionary.join(state, {
			[action.setting] = action.value,
		}) or state
	end,

	setTooltip = function(state, action)
		return state
				and Cryo.Dictionary.join(state, {
					tooltip = Cryo.Dictionary.join(state.tooltip, {
						visible = action.visible,
						text = action.text or state.tooltip.text,
						title = action.title or state.tooltip.title,
					}),
				})
			or state
	end,

	setBuildShiftLock = function(state, action)
		return state and Cryo.Dictionary.join(state, {
			buildShiftLock = action.buildShiftLock,
		}) or state
	end,
}

return function(state, action)
	state = state or initialState
	local actionHandler = actions[action.type]

	if actionHandler then
		return actionHandler(state, action)
	end

	return state
end
