local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FlashlightEvent = ReplicatedStorage.RemotesLegacy.FlashlightEvent

local debounce: { [Player]: number } = {}
local FlashlightService = {}

function FlashlightService.init()
	FlashlightEvent.OnServerEvent:Connect(function(player, value)
		if debounce[player] ~= nil and (tick() - debounce[player]) < 0.1 then
			return
		else
			debounce[player] = tick()
		end

		FlashlightEvent:FireAllClients(player.Character.Head, value)
	end)
end

return FlashlightService
