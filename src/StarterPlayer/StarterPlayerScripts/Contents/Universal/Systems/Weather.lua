local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local WeatherEvent = ReplicatedStorage:WaitForChild("RemotesLegacy"):WaitForChild("WeatherEvent")
local WeatherModule = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("WeatherModule"))
local RainPart = ReplicatedStorage:WaitForChild("Entities"):WaitForChild("RainPart"):Clone()
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)

local AmbienceSounds = SoundService:WaitForChild("Ambience")
local currentWeather = nil
local rainTween = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

local currentAmbient, currentOutdoorAmbient
local lightningTween = TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut)
local thunderCooldown = tick()
local thunderRandomWait = math.random(30, 120)

local function RainFX()
	local rayparams = RaycastParams.new()
	rayparams.FilterDescendantsInstances = {player.Character}
	local rayResult = workspace:Raycast(camera.CFrame.Position, Vector3.new(0, -100, 0), rayparams)

	if not rayResult then return end

	if rayResult.Instance.Name == "Terrain" then
		if RainPart.Parent ~= workspace then
			RainPart.Parent = workspace
			TweenService:Create(RainPart.ParticleEmitter, rainTween, {Rate = 100}):Play()
			TweenService:Create(AmbienceSounds.RainAmb.EqualizerSoundEffect, rainTween, {HighGain = 0}):Play()
			TweenService:Create(AmbienceSounds.Thunder.EqualizerSoundEffect, rainTween, {
				HighGain = 0,
				LowGain = 0,
				MidGain = 0
			}):Play()
		end

		RainPart.CFrame = CFrame.new(camera.CFrame.Position + Vector3.new(0, 300, 0))
	else
		rayResult = workspace:Raycast(camera.CFrame.Position, Vector3.new(0, 100, 0), rayparams)

		if not rayResult then return end

		RainPart.Parent = game.ReplicatedStorage
		TweenService:Create(AmbienceSounds.RainAmb.EqualizerSoundEffect, rainTween, {HighGain = -50}):Play()
		TweenService:Create(AmbienceSounds.Thunder.EqualizerSoundEffect, rainTween, {
			HighGain = -50,
			LowGain = 5,
			MidGain = -10
		}):Play()
		TweenService:Create(RainPart.ParticleEmitter, rainTween, {Rate = 0}):Play()
	end
end

local function ThunderFX()
	if tick() - thunderCooldown < thunderRandomWait then return end

	local thunderChance = math.random(1, 100)
	if thunderChance > 25 then return end

	thunderCooldown = tick()

	currentAmbient = Lighting.Ambient
	currentOutdoorAmbient = Lighting.OutdoorAmbient

	local resetFX = TweenService:Create(Lighting, lightningTween, {
		Ambient = currentOutdoorAmbient,
		OutdoorAmbient = currentAmbient,
	})

	Lighting.Ambient = Color3.fromRGB(193, 212, 255)
	Lighting.OutdoorAmbient = Color3.fromRGB(193, 212, 255)
	task.wait(0.12)

	resetFX:Play()

	task.wait(Random.new():NextNumber(0.1, 1))
	AmbienceSounds.Thunder.PlaybackSpeed = Random.new():NextNumber(0.85, 1.15)
	AmbienceSounds.Thunder.Volume = Random.new():NextNumber(5, 8)
	AmbienceSounds.Thunder:Play()

	thunderRandomWait = math.random(30, 120)
end

function module.init()
    RunService.RenderStepped:Connect(function()
        if currentWeather ~= "Rain" then
            if RainPart.Parent ~= game.ReplicatedStorage then
                local tween = TweenService:Create(RainPart.ParticleEmitter, rainTween, {Rate = 0})
                tween:Play()
                tween.Completed:Wait()
                RainPart.Parent = game.ReplicatedStorage
            end
        else
            RainFX()
            ThunderFX()
        end
    end)

    WeatherEvent.OnClientEvent:Connect(function(weather)
        currentWeather = weather

        if currentWeather == "Clear" then
            WeatherModule.Clear()
        elseif currentWeather == "Foggy" then
            WeatherModule.Foggy()
        elseif currentWeather == "Rain" then
            WeatherModule.Rain()
		elseif currentWeather == "BloodMoon" then
			WeatherModule.BloodMoon()
			SoundService:PlayLocalSound(SoundService.Weather.BloodMoon.BloodMoonBell)
			SoundService:PlayLocalSound(SoundService.Weather.BloodMoon.ScreamBender)
			SoundService:PlayLocalSound(SoundService.Weather.BloodMoon.DarkDrone)
			Notifier.new("A blood moon has risen! All zombies are worth double XP!", Color3.fromRGB(189, 46, 46), 10)
        end
    end)
end

return module
