local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local StateManager = require(ReplicatedStorage.Common.Shared.Universal.StateManager)

local RoundState = StateManager.new({
	zombieTypes = {},
	started = false,
	round = 0,
	intermission = true,
	roundSeconds = RunService:IsStudio() and 180 or 300,
	fastRoundSeconds = 60,
	isFastRound = false,
	roundStartTick = nil,
	baseZombieCount = RunService:IsStudio() and 10 or 15,
	zombiesPerRound = 2,
	intermissionSeconds = RunService:IsStudio() and 10 or 45,
	intermissionStartTick = nil,
	loneSurvivor = true,
	zombieCount = 0,
	zombiesSpawned = 0,
})

return RoundState
