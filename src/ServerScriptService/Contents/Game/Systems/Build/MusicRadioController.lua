local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local debounce = {}

function module.init()
	ReplicatedStorage.RemotesLegacy.PlayerRadioEvent.OnServerEvent:Connect(
		function(player, targetradio: Model, soundId: string)
			if not targetradio and soundId then
				return
			end
			if debounce[player] ~= nil and (tick() - debounce[player]) < 1 then
				return
			end
			debounce[player] = tick()

			if targetradio.Parent ~= workspace.Buildables.Player then
				return
			end

			local sound: Sound = targetradio.MeshPart.PlayerRadioSound

			sound.SoundId = "rbxassetid://" .. soundId

			if not sound.IsLoaded then
				sound.Loaded:Wait()
			end

			sound:Play()
		end
	)
end

return module
