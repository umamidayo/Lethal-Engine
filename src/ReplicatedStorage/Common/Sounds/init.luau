local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local SoundIds = require(script.SoundIds)

local Sounds = {
	loadedSounds = {},
}

export type SoundModifications = {
	Volume: number?,
	PlaybackSpeed: number?,
	RollOffMaxDistance: number?,
	RollOffMinDistance: number?,
	RollOffMode: Enum.RollOffMode,
}

function Sounds.loadSound(soundName: string)
	local soundId = SoundIds[soundName]
	if not soundId then
		warn(`No sound id found for {soundName}`)
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = soundName
	sound.SoundId = `rbxassetid://{soundId}`
	sound.Parent = SoundService
	Sounds.loadedSounds[soundName] = sound
	return sound
end

function Sounds.getSound(soundName: string)
	local sound = Sounds.loadedSounds[soundName]
	if not sound then
		sound = Sounds.loadSound(soundName)
	end
	return sound:Clone()
end

function Sounds.playFromPart(soundName: string, part: BasePart, modifications: SoundModifications?)
	local sound = Sounds.getSound(soundName)
	if not sound then
		return
	end

	if modifications then
		for key, value in modifications do
			sound[key] = value
		end
	end

	sound.Parent = part
	sound:Play()
	Debris:AddItem(sound, sound.TimeLength)
end

return Sounds
