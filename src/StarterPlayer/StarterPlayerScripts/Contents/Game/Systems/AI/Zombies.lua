local module = {}

local SoundService = game:GetService("SoundService")
local Footsteps = SoundService:WaitForChild("Footsteps")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Entities = ReplicatedStorage:WaitForChild("Entities")
local Animations = ReplicatedStorage:WaitForChild("Animations")
local zombieSounds = SoundService:WaitForChild("Zombies")
local animations = Animations:WaitForChild("Zombies")
local ZombieClothing = Entities:WaitForChild("Zombies"):WaitForChild("Clothing")
local ZombieEvent = ReplicatedStorage:WaitForChild("RemotesLegacy"):WaitForChild("Zombie_Event")
local ZombieFX = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("ZombieFX"))

local floorRaycastParams = RaycastParams.new()
floorRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
floorRaycastParams.FilterDescendantsInstances = { workspace.Zombies, workspace.Forcefields, workspace.Landscape }

local Pants: { Pants }
local Shirts: { Shirt }
local Hats: { Accessory }
local ZedFaces: { Decal }
local BodyColors: Folder

local function WeldAccessory(hatAttach: Attachment, headAttach: Attachment)
	local weld = Instance.new("Weld")
	weld.Part0 = headAttach.Parent
	weld.Part1 = hatAttach.Parent
	weld.C0 = headAttach.CFrame
	weld.C1 = hatAttach.CFrame
	weld.Parent = headAttach.Parent
end

local AddClothing = {
	["Stalker"] = function(zombie: Model)
		local bodycolor = BodyColors[zombie.Name]:Clone()

		bodycolor.Parent = zombie

		for i, v in zombie:GetDescendants() do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
				v.Transparency = 0.85
			end
		end
	end,

	["Swarmer"] = function(zombie: Model)
		local pants: Pants, shirt: Shirt, hat: Accessory, bodycolor: BodyColors, face: Decal

		hat = Hats[math.random(1, #Hats)]:Clone()
		face = ZedFaces[math.random(1, #ZedFaces)]:Clone()
		pants = Pants[math.random(1, #Pants)]:Clone()
		shirt = Shirts[math.random(1, #Shirts)]:Clone()
		bodycolor = BodyColors[zombie.Name]:Clone()

		WeldAccessory(hat.Handle.HairAttachment, zombie:WaitForChild("Head").HairAttachment)
		hat.Parent = zombie
		face.Parent = zombie:WaitForChild("Head")
		pants.Parent = zombie
		shirt.Parent = zombie
		bodycolor.Parent = zombie
	end,
}

local function PlayAnimation(animationTrack, priority)
	animationTrack.Priority = priority
	animationTrack:Play()
end

local function AddSound(sourcePart: BasePart, sound: Sound, looped: boolean, volume: number, range: { number })
	local newSound = sound:Clone()
	newSound.PlaybackSpeed = Random.new():NextNumber(sound.PlaybackSpeed - 0.15, sound.PlaybackSpeed + 0.15)
	if volume then
		newSound.Volume = volume
	end

	if range then
		newSound.RollOffMinDistance = range[1]
		newSound.RollOffMaxDistance = range[2]
	end

	newSound.Parent = sourcePart

	if looped then
		newSound.Looped = true
		newSound:Play()
	else
		newSound.PlayOnRemove = true
		newSound:Destroy()
	end
end

local function onZombieAdded(zombie: Model)
	if zombie.Name == "Enemy_Zombie" or #zombie:GetDescendants() < 9 then
		repeat
			task.wait()
		until zombie.Name ~= "Enemy_Zombie" and #zombie:GetDescendants() >= 9
	end

	local humanoid: Humanoid = zombie:WaitForChild("Humanoid")
	local rootpart: BasePart = zombie:WaitForChild("HumanoidRootPart")

	if AddClothing[zombie.Name] ~= nil then
		AddClothing[zombie.Name](zombie)
	else
		AddClothing.Swarmer(zombie)
	end

	-- Animation Setup

	local animator: Animator = humanoid:WaitForChild("Animator")

	local animTracks = {
		idleTrack = animator:LoadAnimation(animations[zombie.Name]["Idle"]),
		runTrack = animator:LoadAnimation(animations[zombie.Name]["Run"]),
		attackTrack = animator:LoadAnimation(animations[zombie.Name]["Attack"]),
		climbTrack = animator:LoadAnimation(animations[zombie.Name]["Climb"]),
	}

	PlayAnimation(animTracks.idleTrack, Enum.AnimationPriority.Idle)

	-- Footsteps Setup

	local footstepSound: Sound = rootpart:WaitForChild("Footsteps")
	local floorMaterial: Enum.Material = nil
	local footstepTick = tick()
	local delayBetweenFootsteps = 0.23
	local floorRaycastResult: RaycastResult

	local function onMove()
		if tick() - footstepTick < delayBetweenFootsteps then
			return
		end
		footstepTick = tick()

		floorRaycastResult = workspace:Raycast(rootpart.Position, -Vector3.yAxis * 3, floorRaycastParams)

		if not floorRaycastResult then
			return
		end

		if floorRaycastResult.Material ~= floorMaterial then
			floorMaterial = floorRaycastResult.Material

			if Footsteps:FindFirstChild(floorMaterial.Name) then
				footstepSound.SoundId = Footsteps:FindFirstChild(floorMaterial.Name).SoundId
				delayBetweenFootsteps = math.clamp(footstepSound.TimeLength * (humanoid.WalkSpeed / 16), 0.15, 0.5)
			end
		end

		if footstepSound.IsLoaded then
			footstepSound.PlaybackSpeed = math.clamp(humanoid.WalkSpeed / 30, 0.75, 1.75)
			footstepSound:Play()
		end
	end

	local runConnection = game["Run Service"].Heartbeat:Connect(onMove)

	humanoid.Died:Once(function()
		if runConnection then
			runConnection:Disconnect()
		end
	end)

	zombie.Destroying:Once(function()
		if runConnection then
			runConnection:Disconnect()
		end
	end)

	-- Humanoid Setup

	local attackSounds = zombieSounds[zombie.Name].Attack:GetChildren()
	local hurtSounds = zombieSounds[zombie.Name].Hurt:GetChildren()
	local breathingSounds = zombieSounds[zombie.Name].Breathing:GetChildren()
	local currenthealth = humanoid.Health
	AddSound(rootpart, breathingSounds[math.random(1, #breathingSounds)], true)

	local damageconnection = humanoid.HealthChanged:Connect(function(health)
		if health >= currenthealth then
			currenthealth = health
		else
			currenthealth = health
			AddSound(zombie.Torso, hurtSounds[math.random(1, #hurtSounds)])
		end
	end)

	zombie:GetAttributeChangedSignal("Attacking"):Connect(function()
		if zombie:GetAttribute("Attacking") == true then
			AddSound(zombie.Torso, attackSounds[math.random(1, #attackSounds)])
			PlayAnimation(animTracks.attackTrack, Enum.AnimationPriority.Action)
		else
			animTracks.attackTrack:Stop()
		end
	end)

	humanoid.Running:Connect(function(speed)
		if speed > 0.1 then
			if animTracks.idleTrack.IsPlaying then
				animTracks.idleTrack:Stop()
			end

			PlayAnimation(animTracks.runTrack, Enum.AnimationPriority.Action)
		else
			if animTracks.runTrack.IsPlaying then
				animTracks.runTrack:Stop()
			end

			PlayAnimation(animTracks.idleTrack, Enum.AnimationPriority.Idle)
		end
	end)

	humanoid.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Climbing then
			if animTracks.runTrack.IsPlaying then
				animTracks.runTrack:Stop()
			end

			PlayAnimation(animTracks.climbTrack, Enum.AnimationPriority.Action)
		elseif new == Enum.HumanoidStateType.Running and old ~= Enum.HumanoidStateType.Running then
			if animTracks.climbTrack.IsPlaying then
				animTracks.climbTrack:Stop()
			end

			AddSound(zombie.HumanoidRootPart, attackSounds[math.random(1, #attackSounds)])
		elseif new == Enum.HumanoidStateType.PlatformStanding then
			if animTracks.climbTrack.IsPlaying then
				animTracks.climbTrack:Stop()
			end

			if animTracks.runTrack.IsPlaying then
				animTracks.runTrack:Stop()
			end
		elseif new == Enum.HumanoidStateType.Dead then
			for i, v in animTracks do
				v:Stop()
			end

			damageconnection:Disconnect()
			runConnection:Disconnect()
		end
	end)
end

local function updateZedHighlight(zombie: Model)
	if #workspace.Zombies:GetChildren() <= 5 then
		local zedHighlight = ReplicatedStorage.Entities.Highlights.ZedHighlight
		zedHighlight.Adornee = workspace.Zombies
		zedHighlight.Enabled = true
	else
		local zedHighlight = ReplicatedStorage.Entities.Highlights.ZedHighlight
		zedHighlight.Adornee = nil
		zedHighlight.Enabled = false
	end
end

function module.init()
	Pants = ZombieClothing.PantsFolder:GetChildren()
	Shirts = ZombieClothing.ShirtFolder:GetChildren()
	Hats = ZombieClothing.HatsFolder:GetChildren()
	ZedFaces = ZombieClothing.FaceFolder:GetChildren()
	BodyColors = ZombieClothing.BodyColors

	workspace.Zombies.ChildAdded:Connect(onZombieAdded)
	workspace.Zombies.ChildAdded:Connect(updateZedHighlight)
	workspace.Zombies.ChildRemoved:Connect(updateZedHighlight)

	ZombieEvent.OnClientEvent:Connect(function(eventType: string, arguments: { any })
		if eventType == "ZombieFX" then
			local fxName, zombie = arguments[1], arguments[2]

			-- Removing the fxName and zombie from the arguments for the spitter
			-- TODO: Rewrite.

			table.remove(arguments, 1)
			table.remove(arguments, 1)

			if ZombieFX[fxName] then
				ZombieFX[fxName](zombie, arguments)
			end
		end
	end)

	if #workspace.Zombies:GetChildren() > 0 then
		for _, zombie in workspace.Zombies:GetChildren() do
			onZombieAdded(zombie)
		end
	end
end

return module
