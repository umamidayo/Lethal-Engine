local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Common.Network)
local RoundState = require(ReplicatedStorage.Common.States.Game.RoundState)
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

export type MessageData = {
	LastSent: number,
	PlaceId: number,
	ServerId: string,
	ServerUptime: number,
	UserIds: { number },
	Round: number,
}

local GAME_ID = 18707544787
local LOBBY_ID = 11614561669
local TEST_GAME_ID = 125199028804410
local TEST_LOBBY_ID = 15853388084

local CURRENT_ID = game.PlaceId
local isPrivateServer = game.PrivateServerId ~= ""

local ServerManager = {
	ServerStartTimeStamp = os.time(),
	servers = {},
}

function ServerManager:getUserIds()
	local userIds: { number } = {}
	for _, player in Players:GetPlayers() do
		table.insert(userIds, player.UserId)
	end
	return userIds
end

function ServerManager:updateServerListing()
	local success = pcall(function()
		local data = HttpService:JSONEncode({
			PlaceId = game.PlaceId,
			ServerId = game.JobId,
			ServerUptime = os.time() - self.ServerStartTimeStamp,
			UserIds = self:getUserIds(),
			Round = RoundState.state.round or 1,
		})
		return MessagingService:PublishAsync("ListServer", data)
	end)

	if not success then
		warn("Failed to update server listing")
	end
end

function ServerManager:listen()
	Network.bindFunction(Network.RemoteFunctions.RequestServerListing, function(player: Player)
		if not self.servers or #self.servers < 0 then
			return false, "Internal error: unable to find any servers"
		end

		return true, self.servers
	end, Network.t.instanceOf("Player"))

	MessagingService:SubscribeAsync("ListServer", function(message)
		local data, lastSent = HttpService:JSONDecode(message.Data), message.Sent
		ServerManager.servers[data.ServerId] = {
			LastSent = lastSent,
			PlaceId = data.PlaceId,
			ServerId = data.ServerId,
			ServerUptime = data.ServerUptime,
			UserIds = data.UserIds,
			Round = data.Round,
		}
	end)

	MessagingService:SubscribeAsync("RemoveServer", function(message)
		local data = HttpService:JSONDecode(message.Data)
		if ServerManager.servers[data.ServerId] then
			ServerManager.servers[data.ServerId] = nil
		end
	end)
end

function ServerManager.init()
	if CURRENT_ID == LOBBY_ID or CURRENT_ID == TEST_LOBBY_ID then
		ServerManager:listen()
	elseif (CURRENT_ID == GAME_ID or CURRENT_ID == TEST_GAME_ID) and not isPrivateServer then
		ServerManager:updateServerListing()

		Scheduler.AddToScheduler("Interval_10s", "UpdateServerListing", function()
			ServerManager:updateServerListing()
		end)

		game:BindToClose(function()
			local success = pcall(function()
				local data = HttpService:JSONEncode({
					ServerId = game.JobId,
				})
				return MessagingService:PublishAsync("RemoveServer", data)
			end)
			if not success then
				warn("Failed to remove server listing")
			end
		end)
	else
		warn("Not listening to server list, place Id does not meet criteria.")
	end
end

return ServerManager
