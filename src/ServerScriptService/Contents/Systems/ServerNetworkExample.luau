-- Example of how to use the Network module to send and receive events between the client and server.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Shared.Network)

local ServerNetworkExample = {}

function ServerNetworkExample.init()
	Network.connectEvent(Network.RemoteEvents.FoodEvent, function(player: Player, food: string)
		-- Server-side logic
		print(player.Name, "ate", food)

		local sendData = `{player.Name} ate {food}`
		Network.fireClient(Network.RemoteEvents.FoodEvent, player, sendData)
	end, Network.t.instanceOf("Player"), Network.t.string)
end

return ServerNetworkExample
