local ReplicatedStorage = game:GetService("ReplicatedStorage")

local animationsFolder = ReplicatedStorage:WaitForChild("Animations")

local Animations = {
	animations = {},
	characters = {},
}
Animations.__index = Animations

function Animations.new(character: Model)
	local self = setmetatable({}, Animations)
	self.character = character
	self.humanoid = character:WaitForChild("Humanoid")
	self.animator = self.humanoid:WaitForChild("Animator")
	self.tracks = {}
	Animations.characters[character.Name] = self

	return self
end

function Animations:destroy()
	Animations.characters[self.character.Name] = nil
	setmetatable(self, nil)
end

function Animations:playAnimation(trackName: string)
	local track: AnimationTrack = self.tracks[trackName]
	if track then
		track:Play()
		return track
	end
end

function Animations:loadAnimations(animationNames: string | { string }, AnimationPriority: Enum.AnimationPriority?)
	if typeof(animationNames) == "table" then
		for _, animationName in animationNames do
			self:loadAnimations(animationName)
		end
	else
		local animation = Animations.animations[animationNames]
		if not animation then
			local currentTick = tick()
			repeat
				animation = Animations.animations[animationNames]
				task.wait(0.1)
			until animation or tick() - currentTick >= 5
		end
		if animation then
			local track: AnimationTrack = self.animator:LoadAnimation(animation)
			track.Priority = AnimationPriority or Enum.AnimationPriority.Idle
			self.tracks[animationNames] = track
		end
	end
end

function Animations:stopAnimation(animationName: string)
	local track: AnimationTrack = self.tracks[animationName]
	if track then
		track:Stop()
		return track
	end
end

function Animations:setSpeed(speed: number?, animationName: string)
	local track: AnimationTrack = self.tracks[animationName]
	if track then
		track:AdjustSpeed(speed or 1)
	end
end

function Animations.init()
	for _, animation in animationsFolder:GetDescendants() do
		if animation:IsA("Animation") then
			Animations.animations[animation.Name] = animation
		end
	end
end

return Animations
