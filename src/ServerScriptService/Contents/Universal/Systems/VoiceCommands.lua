local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterLibrary = require(ReplicatedStorage.Common.Libraries.CharacterLibrary)
local Network = require(ReplicatedStorage.Common.Network)

local lastPlayed = {}
local VoiceCommands = {}

function VoiceCommands.init()
	Network.connectEvent(
		Network.RemoteEvents.VoiceCommand,
		function(player: Player, actorName: string, voiceName: string)
			if CharacterLibrary.IsDead(player) then
				return
			end
			if lastPlayed[player] and tick() - lastPlayed[player] < 1 then
				return
			end
			lastPlayed[player] = tick()

			Network.fireAllClients(Network.RemoteEvents.VoiceCommand, player, actorName, voiceName)
			--PlayVoiceFromRootPart(player.Character, actorName, voiceName)
		end,
		Network.t.instanceOf("Player"),
		Network.t.string,
		Network.t.string
	)

	Network.connectEvent(
		Network.RemoteEvents.MousePing,
		function(player: Player, actorName: string, Model: Model, HitPosition: Vector3)
			if CharacterLibrary.IsDead(player) then
				return
			end
			if lastPlayed[player] and tick() - lastPlayed[player] < 0.25 then
				return
			end
			lastPlayed[player] = tick()

			if Model then
				Network.fireAllClients(Network.RemoteEvents.MousePing, player, actorName, Model)
			-- PlayVoiceFromRootPart(player.Character, actorName, Model.Name)
			else
				Network.fireAllClients(Network.RemoteEvents.MousePing, player, actorName, HitPosition)
			end
		end,
		Network.t.instanceOf("Player"),
		Network.t.string,
		Network.t.Model,
		Network.t.Vector3
	)

	Players.PlayerRemoving:Connect(function(player: Player)
		lastPlayed[player] = nil
	end)
end

return VoiceCommands
