local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local Ambience: SoundGroup = SoundService:WaitForChild("Ambience")
local Music: SoundGroup = SoundService:WaitForChild("Music")
local SoundBlocks: Folder = workspace:WaitForChild("SoundBlocks")

local AmbienceTween = TweenInfo.new(30, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local transitioning: boolean = nil
local lastWoodPecker: number = nil

--time changer
local mam: number --minutes after midnight
local timeShift = 0.5 --how many minutes you shift every "tick"
local pi = math.pi

--brightness
local amplitudeB = 1
local offsetB = 2

--outdoor ambieant
local var: number
local amplitudeO = 10
local offsetO = 10

--shadow softness
local amplitudeS = 0.2
local offsetS = 0.8

--color shift top
local pointer: number

-- 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
local rColorList = {
	000,
	000,
	000,
	000,
	000,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	000,
	000,
	000,
	000,
	000,
}
local gColorList = {
	165,
	165,
	165,
	165,
	165,
	255,
	215,
	230,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	245,
	230,
	215,
	255,
	165,
	165,
	165,
	165,
	165,
}
local bColorList = {
	255,
	255,
	255,
	255,
	255,
	255,
	110,
	135,
	255,
	255,
	255,
	255,
	255,
	255,
	255,
	215,
	135,
	110,
	255,
	255,
	255,
	255,
	255,
	255,
}
local r, g, b

local module = {}

local function onTimeChange()
	mam = Lighting:GetMinutesAfterMidnight() + timeShift
	mam = mam / 60

	var = amplitudeO * math.cos(mam * (pi / 12) + pi) + offsetO

	pointer = math.clamp(math.ceil(mam), 1, 24)
	r = ((rColorList[pointer % 24 + 1] - rColorList[pointer]) * (mam - pointer + 1)) + rColorList[pointer]
	g = ((gColorList[pointer % 24 + 1] - gColorList[pointer]) * (mam - pointer + 1)) + gColorList[pointer]
	b = ((bColorList[pointer % 24 + 1] - bColorList[pointer]) * (mam - pointer + 1)) + bColorList[pointer]

	Lighting.Brightness = amplitudeB * math.cos(mam * (pi / 12) + pi) + offsetB
	Lighting.OutdoorAmbient = Color3.fromRGB(var, var, var)
	Lighting.Ambient = Color3.fromRGB(var, var, var)
	Lighting.ShadowSoftness = amplitudeS * math.cos(mam * (pi / 6)) + offsetS
	Lighting.ColorShift_Top = Color3.fromRGB(r, g, b)
end

local function PlayMusic()
	local RandomSound: Sound = Music:GetChildren()[Random.new():NextInteger(1, #Music:GetChildren())]
	RandomSound:Play()
end

local function SetupSoundBlocks()
	for i, part: BasePart in SoundBlocks:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end
		part.Transparency = 1

		local sound: Sound = Ambience:FindFirstChild(part.Name)

		if sound then
			sound = sound:Clone()
			sound.RollOffMaxDistance = part:GetAttribute("AreaSoundRange") + 50
			sound.RollOffMinDistance = part:GetAttribute("AreaSoundRange") * 0.05
			sound.Parent = part
			sound:Play()
		end
	end
end

local function PlayWoodPecker()
	if lastWoodPecker ~= nil and tick() - lastWoodPecker < 30 then
		return
	end
	lastWoodPecker = tick()

	local sound: Sound = Ambience:FindFirstChild("Wood Pecker")

	if sound then
		sound = sound:Clone()

		local trees: { Model } = {}

		for i, tree in workspace.Landscape:GetChildren() do
			if tree.Name ~= "Tree" then
				continue
			end
			table.insert(trees, tree)
		end

		local randomTree = trees[math.random(1, #trees)]

		if randomTree.PrimaryPart then
			sound.Parent = randomTree.PrimaryPart
		else
			sound.Parent = randomTree:FindFirstChildWhichIsA("BasePart")
		end

		sound:Play()
		Debris:AddItem(sound, sound.TimeLength)
	end
end

function module.init()
	SetupSoundBlocks()

	Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
		if transitioning then
			return
		end

		if Lighting.ClockTime >= 6.3 and Lighting.ClockTime <= 18 then
			if Ambience.DayAmb.Volume < 0.074 then
				transitioning = true
				PlayMusic()
				TweenService:Create(Ambience.NightAmb, AmbienceTween, { Volume = 0 }):Play()
				local tween = TweenService:Create(Ambience.DayAmb, AmbienceTween, { Volume = 0.074 })
				tween:Play()
				tween.Completed:Wait()
				transitioning = nil
			end
		else
			if Ambience.NightAmb.Volume < 0.092 then
				transitioning = true
				PlayMusic()
				TweenService:Create(Ambience.DayAmb, AmbienceTween, { Volume = 0 }):Play()
				local tween = TweenService:Create(Ambience.NightAmb, AmbienceTween, { Volume = 0.092 })
				tween:Play()
				tween.Completed:Wait()
				transitioning = nil
			end
		end
	end)

	Scheduler.AddToScheduler("Interval_1s", "Ambience", function()
		onTimeChange()
		PlayWoodPecker()
	end)
end

return module
