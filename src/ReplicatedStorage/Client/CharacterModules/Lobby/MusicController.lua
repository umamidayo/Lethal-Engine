local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundManager = require(ReplicatedStorage.Common.Shared.Universal.SoundManager)

local MusicController = {}

function MusicController.init()
	local lobbyMusic = SoundManager.getSound("Why")
	lobbyMusic.Sound.Looped = true
	lobbyMusic:playLocally()

	local windAmb = SoundManager.getSound("WindAmb")
	windAmb.Sound.Looped = true
	windAmb:playLocally()
end

return MusicController
