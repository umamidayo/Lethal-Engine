local RadioManager = {}

local Chat = game:GetService("Chat")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local radio_event = Instance.new("RemoteEvent")
radio_event.Name = "Radio_Event"
radio_event.Parent = ReplicatedStorage:WaitForChild("RemotesLegacy")

local debounce = {}

function RadioManager.init()
	radio_event.OnServerEvent:Connect(function(player, message, source, channels)
		if player.Name ~= source then
			return
		end
		if debounce[player] ~= nil and (tick() - debounce[player] < 1) then
			return
		end

		local filteredMessage

		local success, errorMsg = pcall(function()
			filteredMessage = Chat:FilterStringAsync(message, player, player)
		end)

		if success then
			radio_event:FireAllClients(filteredMessage, player, channels)
		else
			warn(errorMsg)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		debounce[player] = nil
	end)
end

return RadioManager
