local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")

local BadgeData = {}
local TitlesManager = {}

local BadgeAwards = {
	[0] = function(player: Player)
		if BadgeData[player] == nil or BadgeData[player][2152792803] == true then
			return
		end
		BadgeService:AwardBadge(player.UserId, 2152792803)
		print(player.DisplayName .. " earned the badge Alpha Player")
	end,

	[1000] = function(player: Player)
		if BadgeData[player] == nil or BadgeData[player][2152792903] == true then
			return
		end
		BadgeService:AwardBadge(player.UserId, 2152792903)
		print(player.DisplayName .. " earned the badge Alpha Expert")
	end,

	[10000] = function(player: Player)
		if BadgeData[player] == nil or BadgeData[player][2152793083] == true then
			return
		end
		BadgeService:AwardBadge(player.UserId, 2152793083)
		print(player.DisplayName .. " earned the badge Alpha Legend")
	end,
}

local KillTitles = {
	{ Title = "Rookie", Kills = 0 },
	{ Title = "Learning", Kills = 100 },
	{ Title = "Experienced", Kills = 500 },
	{ Title = "Veteran", Kills = 1000 },
	{ Title = "Master", Kills = 2500 },
	{ Title = "Grand", Kills = 5000 },
	{ Title = "Apocalyptic", Kills = 10000 },
	{ Title = "Malicious", Kills = 15000 },
	{ Title = "Hazardous", Kills = 20000 },
	{ Title = "Ominous", Kills = 30000 },
	{ Title = "Anomaly", Kills = 40000 },
	{ Title = "[REDACTED]", Kills = 50000 },
}

function TitlesManager.getKillTitle(kills: number)
	local killTitle = nil

	for i, info in ipairs(KillTitles) do
		if kills >= info.Kills then
			killTitle = info.Title
		end
	end

	return killTitle
end

function TitlesManager.init()
	Players.PlayerAdded:Connect(function(player)
		if BadgeData[player] == nil then
			repeat
				BadgeData[player] = {
					[2152792803] = BadgeService:UserHasBadgeAsync(player.UserId, 2152792803),
					[2152792903] = BadgeService:UserHasBadgeAsync(player.UserId, 2152792903),
					[2152793083] = BadgeService:UserHasBadgeAsync(player.UserId, 2152793083),
				}
				task.wait(1)
			until BadgeData[player] ~= nil
		end

		local kills = player:GetAttribute("Kills")
		if kills == nil then
			repeat
				task.wait(1)
				kills = player:GetAttribute("Kills")
			until kills
		end

		for i, _ in BadgeAwards do
			if kills >= i then
				BadgeAwards[i](player)
			end
		end

		player:SetAttribute("Title", TitlesManager.getKillTitle(kills))

		player:GetAttributeChangedSignal("Kills"):Connect(function()
			if player:GetAttribute("Title") == "Lone Survivor" then
				return
			end
			player:SetAttribute("Title", TitlesManager.getKillTitle(kills))
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		if BadgeData[player] ~= nil then
			BadgeData[player] = nil
		end
	end)
end

return TitlesManager
