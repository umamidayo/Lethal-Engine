local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local Perks = {
	HealthRegen = {
		Tags = {},
		Constants = {
			HEALTH_REGEN = 2,
			HEALTH_REGEN_RADIUS = 10,
		},
	},
}

local PerkService = {}

function PerkService.getPlayersInRadius(character: Model, radius: number, players: { Player })
	for _, player in Players:GetPlayers() do
		if table.find(players, player) then
			continue
		end
		if not player.Character or player.Character == character then
			continue
		end
		if player.Character:HasTag("HealthRegenAOE") then
			continue
		end
		local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			continue
		end
		if player:DistanceFromCharacter(character.PrimaryPart.Position) <= radius then
			table.insert(players, player)
		end
	end
	return players
end

function PerkService.handleHealthRegenAOE()
	local players = {}
	for _, character: Model in Perks.HealthRegen.Tags do
		local humanoid = character:FindFirstChildWhichIsA("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			continue
		end
		humanoid.Health += Perks.HealthRegen.Constants.HEALTH_REGEN
		players = PerkService.getPlayersInRadius(character, Perks.HealthRegen.Constants.HEALTH_REGEN_RADIUS, players)
	end

	if #players <= 0 then
		return
	end

	for _, player in players do
		local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			continue
		end
		humanoid.Health += Perks.HealthRegen.Constants.HEALTH_REGEN
	end
end

function PerkService.init()
	CollectionService:GetInstanceAddedSignal("HealthRegenAOE"):Connect(function()
		Perks.HealthRegen.Tags = CollectionService:GetTagged("HealthRegenAOE")
	end)

	CollectionService:GetInstanceRemovedSignal("HealthRegenAOE"):Connect(function()
		Perks.HealthRegen.Tags = CollectionService:GetTagged("HealthRegenAOE")
	end)

	Scheduler.AddToScheduler("Interval_1s", "PerkService", function()
		PerkService.handleHealthRegenAOE()
	end)
end

return PerkService
