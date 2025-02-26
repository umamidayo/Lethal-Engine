local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Modules.DataStore2)
local Network = require(ReplicatedStorage.Common.Network)

local LEADERBOARD_NAME = "LevelDataStore"
local UPDATE_INTERVAL = 60 * 10 -- 10 minutes
local MINIMUM_KILLS = 1

local LeaderboardService = {}

function LeaderboardService.init()
	local orderedDataStore = DataStoreService:GetOrderedDataStore(LEADERBOARD_NAME)
	local leaderboardCache = {
		lastUpdated = 0,
		pages = nil,
	}

	local function recordPlayerKills(player: Player)
		local kills = DataStore2("Kills", player):Get()
		if not kills or kills < MINIMUM_KILLS then
			return
		end

		orderedDataStore:SetAsync(player.UserId, kills)
	end

	local function updateLeaderboardData()
		local now = tick()
		if now - leaderboardCache.lastUpdated < UPDATE_INTERVAL then
			return
		end

		leaderboardCache.lastUpdated = now
		leaderboardCache.pages = orderedDataStore:GetSortedAsync(false, 100)
		print(string.format("%s - Updated leaderboard data", script.Name))
	end

	Players.PlayerRemoving:Connect(recordPlayerKills)

	Network.connectEvent(Network.RemoteEvents.LeaderboardEvent, function(_: Player, eventType: string)
		if eventType ~= "fetch" then
			return
		end

		updateLeaderboardData()
		local leaderboardData = leaderboardCache.pages:GetCurrentPage()
		Network.fireAllClients(Network.RemoteEvents.LeaderboardEvent, leaderboardData)
	end, Network.t.instanceOf("Player"), Network.t.string)
end

return LeaderboardService
