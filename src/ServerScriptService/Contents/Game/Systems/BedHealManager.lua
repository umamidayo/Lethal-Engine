local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local BED_HEAL_AMOUNT = 1

local BedHealManager = {}

function BedHealManager.healCharacter(character: Model, amount: number)
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	humanoid.Health += amount
end

function BedHealManager.init()
	Scheduler.AddToScheduler("Interval_0.5", "BedHealManager", function()
		for _, player in Players:GetPlayers() do
			if player.Character and player.Character:GetAttribute("Laying") then
				BedHealManager.healCharacter(player.Character, BED_HEAL_AMOUNT)
			end
		end
	end)
end

return BedHealManager
