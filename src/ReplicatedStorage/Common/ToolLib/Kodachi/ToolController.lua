local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Network = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Network"))
local RaycastHitbox = require(ReplicatedStorage.Common.RaycastHitbox)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local CameraShaker = require(ReplicatedStorage.Common.CameraShaker)
local Maid = require(ReplicatedStorage.Common.Libraries.Maid)

local maid = Maid.new()
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Animation
local Animations = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Weapons"):WaitForChild("Kodachi")
local AnimationTracks = {}
local currentStyle = "Rush" -- Focus or Rush
local currentTrack = nil

-- Swing sequencing and cooldown
local swingCount = 0
local swingSequence = 1
local swingDebounce = tick()

-- Hitbox w/ RaycastHitbox
local meleeHitBox

local module = {}

local function StopAnimations()
	for _, AnimationTrack in AnimationTracks do
		AnimationTrack:Stop()
	end
end

local function ClearAnimationTracks()
	for _, AnimationTrack in AnimationTracks do
		AnimationTrack:Destroy()
	end

	AnimationTracks = {}
end

local function LoadStyleAnimationTracks(Animator: Animator)
	ClearAnimationTracks()

	local swings = 0

	for _, Animation in Animations[currentStyle]:GetChildren() do
		if string.find(Animation.Name, "Swing") then
			AnimationTracks[Animation.Name] = Animator:LoadAnimation(Animation)
			swings += 1
		end
	end

	return swings
end

local function ChangeStyle(Animator: Animator)
	currentStyle = currentStyle == "Focus" and "Rush" or "Focus"
	swingCount = LoadStyleAnimationTracks(Animator)
	currentTrack = AnimationTracks["Swing1"]
	swingSequence = 1
	Notifier.new("Changed fighting style to " .. currentStyle, Color3.fromRGB(219, 197, 96))
end

local function ShakeCamera(shakeCf)
	Camera.CFrame = Camera.CFrame * shakeCf
end

local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, ShakeCamera)
camShake:Start()

function module.Equip(Tool: Tool)
	local Character = LocalPlayer.Character
	if not Character then
		return
	end

	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	if not Humanoid then
		return
	end

	local Animator = Humanoid:FindFirstChildWhichIsA("Animator")
	if not Animator then
		return
	end

	Notifier.new(
		"Current fighting style: " .. currentStyle .. ", press R to change fighting styles",
		Color3.fromRGB(219, 197, 96)
	)

	local hitBegins = {}
	local hitEnds = {}
	local hits = {}
	local lastClick = tick()

	swingCount = LoadStyleAnimationTracks(Animator)
	currentTrack = AnimationTracks["Swing1"]

	local Activation = Tool.Activated:Connect(function()
		if tick() - swingDebounce < currentTrack.Length / 1.25 then
			return
		end
		swingDebounce = tick()

		if tick() - lastClick > currentTrack.Length * 1.5 then
			swingSequence = 1
		end

		lastClick = tick()

		StopAnimations()

		hits = {}

		currentTrack = AnimationTracks["Swing" .. swingSequence]
		currentTrack:Play()
		camShake:Shake(CameraShaker.Presets.MeleeSwing)

		if not hitBegins[currentTrack] then
			hitBegins[currentTrack] = currentTrack:GetMarkerReachedSignal("HitBegin"):Connect(function()
				Network.fireServer(Network.RemoteEvents.MeleeEvent, "Swing", { Tool })
				meleeHitBox:HitStart()
			end)
		end

		if not hitEnds[currentTrack] then
			hitEnds[currentTrack] = currentTrack:GetMarkerReachedSignal("HitEnd"):Connect(function()
				meleeHitBox:HitStop()
			end)
		end

		swingSequence = swingSequence + 1
		if swingSequence > swingCount then
			swingSequence = 1
		end
	end)

	local ChangeStyleKeybind = UserInputService.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.R then
				ChangeStyle(Animator)
			end
		end
	end)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { Character, workspace.Characters, workspace.Friends }
	meleeHitBox = RaycastHitbox.new(Tool.Hitbox)
	meleeHitBox.RaycastParams = raycastParams

	meleeHitBox.OnHit:Connect(function(hit: BasePart, humanoid: Humanoid)
		if hits[humanoid] then
			return
		end
		hits[humanoid] = true

		meleeHitBox:HitStop()
		Network.fireServer(Network.RemoteEvents.MeleeEvent, "Hit", { Tool, hit, humanoid })
		meleeHitBox:HitStart()
	end)

	maid:GiveTask(Activation)
	maid:GiveTask(ChangeStyleKeybind)
end

function module.Unequip()
	meleeHitBox:Destroy()
	maid:DoCleaning()

	for _, AnimationTrack in AnimationTracks do
		AnimationTrack:Stop()
		AnimationTrack:Destroy()
	end

	AnimationTracks = {}
end

return module
