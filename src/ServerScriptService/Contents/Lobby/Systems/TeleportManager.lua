local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Notify = ReplicatedStorage.RemotesLegacy.Notifier

local Network = require(ReplicatedStorage.Common.Network)

local GAME_ID = 18707544787
local LOBBY_ID = 11614561669
local TEST_GAME_ID = 125199028804410
local TEST_LOBBY_ID = 15853388084
local CURRENT_ID = game.PlaceId

if CURRENT_ID == TEST_GAME_ID or CURRENT_ID == TEST_LOBBY_ID then
	GAME_ID = TEST_GAME_ID
	LOBBY_ID = TEST_LOBBY_ID
end

local TeleportManager = {}

function TeleportManager.init()
	Network.connectEvent(Network.RemoteEvents.TeleportEvent, function(player: Player, eventType: string)
		if eventType == "PrivateServer" then
			if game.PrivateServerId == "" then
				Notify:FireClient(player, "Cannot start a private game in a public server.")
				return
			end

			if game.PrivateServerOwnerId ~= player.UserId then
				Notify:FireClient(player, "Only the owner of the private server can start a private game.")
				return
			end

			local reservedServer = TeleportService:ReserveServer(GAME_ID)
			if reservedServer then
				TeleportService:TeleportToPrivateServer(GAME_ID, reservedServer, Players:GetPlayers())
			end
		elseif eventType == "RandomServer" then
			TeleportService:TeleportAsync(GAME_ID, { player })
		end
	end, Network.t.instanceOf("Player"), Network.t.string)

	Network.bindFunction(
		Network.RemoteFunctions.RequestTeleport,
		function(player: Player, teleportType: string, serverId: string?)
			if teleportType == "JoinServer" then
				local success, response = pcall(function()
					return TeleportService:TeleportToPlaceInstance(GAME_ID, serverId, player)
				end)

				if not success then
					warn("Failed to teleport: " .. response)
					return false, `Failed to teleport: {response}`
				else
					return true
				end
			end
		end,
		Network.t.instanceOf("Player"),
		Network.t.string,
		Network.t.optional(Network.t.string)
	)
end

return TeleportManager
