local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local DEFAULT_CLOCKTIME = 6.3

local DayCycle = {}

function DayCycle.init()
	if RunService:IsStudio() then
		DEFAULT_CLOCKTIME = 12
	end

	Lighting.ClockTime = DEFAULT_CLOCKTIME

	Scheduler.AddToScheduler("Interval_1s", "DayCycle", function()
		Lighting:SetMinutesAfterMidnight(Lighting:GetMinutesAfterMidnight() + 0.5)
	end)
end

return DayCycle
