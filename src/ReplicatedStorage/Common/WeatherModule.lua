local module = {}
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local weatherTween = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

module.WeatherChances = {
	["Clear"] = 100,
	["Foggy"] = 50,
	["Rain"] = 25,
}

function module.Clear()
	local bloodMoonSky = Lighting:FindFirstChild("BloodMoonSky")
	if bloodMoonSky then
		bloodMoonSky:Destroy()
	end
	if not Lighting:FindFirstChild("DefaultSky") then
		local defaultSky = ReplicatedStorage.Entities.Weather.DefaultSky:Clone()
		defaultSky.Parent = Lighting

		TweenService:Create(defaultSky, weatherTween, {
			SunAngularSize = 11,
			MoonAngularSize = 11,
		}):Play()
	end

	TweenService:Create(Lighting.Atmosphere, weatherTween, {
		Color = Color3.fromRGB(28, 42, 45),
		Decay = Color3.fromRGB(154, 189, 194),
		Haze = 0,
		Glare = 0,
		Density = 0.35
	}):Play()

	TweenService:Create(Lighting.SunRays, weatherTween, {Intensity = 0.06}):Play()
	TweenService:Create(SoundService.Ambience.RainAmb, weatherTween, {Volume = 0}):Play()
end

function module.Foggy()
	local bloodMoonSky = Lighting:FindFirstChild("BloodMoonSky")
	if bloodMoonSky then
		bloodMoonSky:Destroy()
	end
	if not Lighting:FindFirstChild("DefaultSky") then
		local defaultSky = ReplicatedStorage.Entities.Weather.DefaultSky:Clone()
		defaultSky.Parent = Lighting

		TweenService:Create(defaultSky, weatherTween, {
			SunAngularSize = 0,
			MoonAngularSize = 0,
		}):Play()
	end

	TweenService:Create(game.Lighting.Atmosphere, weatherTween, {
		Color = Color3.fromRGB(28, 42, 45),
		Decay = Color3.fromRGB(182, 193, 194),
		Haze = 2.2,
		Glare = 0.75,
		Density = 0.65
	}):Play()

	TweenService:Create(Lighting.SunRays, weatherTween, {Intensity = 0}):Play()
	TweenService:Create(SoundService.Ambience.RainAmb, weatherTween, {Volume = 0}):Play()
end

function module.Rain()
	local bloodMoonSky = Lighting:FindFirstChild("BloodMoonSky")
	if bloodMoonSky then
		bloodMoonSky:Destroy()
	end
	if not Lighting:FindFirstChild("DefaultSky") then
		local defaultSky = ReplicatedStorage.Entities.Weather.DefaultSky:Clone()
		defaultSky.Parent = Lighting

		TweenService:Create(defaultSky, weatherTween, {
			SunAngularSize = 0,
			MoonAngularSize = 0,
		}):Play()
	end

	TweenService:Create(Lighting.Atmosphere, weatherTween, {
		Color = Color3.fromRGB(110, 132, 166),
		Decay = Color3.fromRGB(154, 189, 194),
		Haze = 3.6,
		Glare = 0,
		Density = 0.55
	}):Play()

	TweenService:Create(Lighting.SunRays, weatherTween, {Intensity = 0}):Play()
	TweenService:Create(SoundService.Ambience.RainAmb, weatherTween, {Volume = 0.4}):Play()
end

function module.BloodMoon()
	local defaultSky = Lighting:FindFirstChild("DefaultSky")
	if defaultSky then
		defaultSky:Destroy()
	end
	if not Lighting:FindFirstChild("BloodMoonSky") then
		local bloodMoonSky = ReplicatedStorage.Entities.Weather.BloodMoonSky:Clone()
		bloodMoonSky.Parent = Lighting

		TweenService:Create(bloodMoonSky, weatherTween, {
			SunAngularSize = 11,
			MoonAngularSize = 11,
		}):Play()
	end

	TweenService:Create(Lighting.Atmosphere, weatherTween, {
		Density = 0.6,
		Haze = 10,
		Glare = 0,
		Decay = Color3.fromRGB(80, 0, 0),
		Color = Color3.fromRGB(80, 0, 0)
	}):Play()

	TweenService:Create(Lighting.SunRays, weatherTween, {Intensity = 0}):Play()
end

return module
