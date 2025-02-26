local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateManager = require(ReplicatedStorage.Common.Shared.Universal.StateManager)

local BuildState = StateManager.new({
	players = {},
	debounces = {},
})

return BuildState
