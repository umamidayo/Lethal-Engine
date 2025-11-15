-- Example of how to use the Network module to send and receive events between the client and server.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Shared.Network)

local ClientNetworkExample = {}

function ClientNetworkExample.init()
	task.delay(5, function()
		Network.fireServer(Network.RemoteEvents.FoodEvent, "Pizza")
	end)

	Network.connectEvent(Network.RemoteEvents.FoodEvent, function(response: string)
		-- Client-side logic
		print(response)
	end, Network.t.string)
end

return ClientNetworkExample
