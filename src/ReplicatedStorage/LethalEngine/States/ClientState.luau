local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LethalEngineShared = ReplicatedStorage.LethalEngine

local States = require(LethalEngineShared.States)

local ClientState = States.new({
	Movement = {
		Stance = "Standing",
		Sprinting = false,
	},
})

return ClientState
