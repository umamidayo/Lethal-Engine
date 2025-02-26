local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local SoundManager = {
	SoundsLoaded = false,
	Sounds = {} :: { [string]: Sound },
}
SoundManager.__index = SoundManager

function SoundManager.new(sound: Sound)
	local self = setmetatable({}, SoundManager)
	self.Sound = sound
	self.Name = sound.Name

	return self
end

function SoundManager.getSound(soundName: string)
	if not SoundManager.SoundsLoaded then
		local currentTick = tick()
		while not SoundManager.SoundsLoaded do
			task.wait(1)
			if tick() - currentTick >= 7 then
				warn("SoundManager warning: Sounds failed to load.")
				return
			end
		end
	end

	local sound = SoundManager.Sounds[soundName]
	if not sound then
		warn("SoundManager couldn't find a sound called ", { soundName })
		return
	end

	return sound
end

function SoundManager:playFromPart(part: Part, callback: (Sound) -> nil)
	local copySound: Sound = self.Sound:Clone()
	copySound.Parent = part
	if callback then
		task.spawn(callback, copySound)
	end
	copySound:Play()
	return copySound
end

function SoundManager:playLocally(callback: (Sound) -> nil)
	if RunService:IsServer() then
		warn("SoundManager warning: Can't play sounds locally on the server-side.")
		return
	end

	self.Sound:Play()
	if callback then
		task.spawn(callback, self.Sound)
	end
end

function SoundManager.init()
	for _, sound: Sound in SoundService:GetDescendants() do
		if sound:IsA("Sound") then
			SoundManager.Sounds[sound.Name] = SoundManager.new(sound)
		end
	end

	SoundManager.SoundsLoaded = true
end

return SoundManager
