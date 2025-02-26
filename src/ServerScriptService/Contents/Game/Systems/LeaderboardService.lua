local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Modules.DataStore2)
local Network = require(ReplicatedStorage.Common.Network)

local LEADERBOARD_UPDATE_INTERVAL = 60 * 10 -- 10 minutes
local MINIMUM_KILLS_REQUIRED = 1

local module = {}

local leaderboardStore = {
	lastUpdated = 0,
	pages = nil,
}

local function recordPlayerKills(player: Player)
	local killCount = DataStore2("Kills", player):Get()

	if tonumber(killCount) >= MINIMUM_KILLS_REQUIRED then
		local OrderedDataStore = DataStoreService:GetOrderedDataStore("LevelDataStore")
		OrderedDataStore:SetAsync(player.UserId, tonumber(killCount))
	end
end

local function updateLeaderboardData()
	if tick() - leaderboardStore.lastUpdated < LEADERBOARD_UPDATE_INTERVAL then
		return
	end

	local OrderedDataStore = DataStoreService:GetOrderedDataStore("LevelDataStore")
	leaderboardStore.lastUpdated = tick()
	leaderboardStore.pages = OrderedDataStore:GetSortedAsync(false, 100)
	print(string.format("%s - Updated leaderboard data", script.Name))
end

function module.init()
	Players.PlayerRemoving:Connect(recordPlayerKills)

	Network.connectEvent(Network.RemoteEvents.LeaderboardEvent, function(player: Player, eventType: string)
		if eventType == "fetch" then
			updateLeaderboardData()
			local leaderboardData = leaderboardStore.pages:GetCurrentPage()
			Network.fireAllClients(Network.RemoteEvents.LeaderboardEvent, leaderboardData)
		end
	end, Network.t.instanceOf("Player"), Network.t.string)
end

return module
