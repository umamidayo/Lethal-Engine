local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local WeatherModule = require(ReplicatedStorage.Common.WeatherModule)
local WeatherEvent = ReplicatedStorage.RemotesLegacy.WeatherEvent

local WEATHER_TIMER = 60 * 5 -- 5 minutes
local BLOODMOON_TIMER = 60 * 10 -- 10 minutes

local WeatherService = {
	currentWeather = nil,
	lastBloodMoon = nil,
}

local lastWeatherChange = nil

function WeatherService.activateBloodMoon()
	lastWeatherChange = tick()
	WeatherService.lastBloodMoon = tick()
	WeatherService.currentWeather = "BloodMoon"
	Lighting.ClockTime = 0
	WeatherEvent:FireAllClients("BloodMoon")
end

local function updateWeather()
	if WeatherService.currentWeather == "BloodMoon" then
		if lastWeatherChange and (tick() - lastWeatherChange) < BLOODMOON_TIMER then
			return
		end
	else
		if lastWeatherChange and (tick() - lastWeatherChange) < WEATHER_TIMER then
			return
		end
	end

	lastWeatherChange = tick()

	local newWeather
	if RunService:IsStudio() then
		newWeather = "Clear"
	else
		local chance = Random.new():NextNumber(0, 100)
		if chance > WeatherModule.WeatherChances.Foggy then
			newWeather = "Clear"
		elseif chance > WeatherModule.WeatherChances.Rain then
			newWeather = "Foggy"
		else
			newWeather = "Rain"
		end
	end

	WeatherService.currentWeather = newWeather
	print(script.Name .. ": " .. newWeather)
	WeatherEvent:FireAllClients(newWeather)

	if newWeather == "Rain" then
		task.spawn(function()
			while WeatherService.currentWeather == "Rain" and (tick() - lastWeatherChange) < WEATHER_TIMER do
				task.wait(40)
				ReplicatedStorage.RemotesLegacy.RainBarrel:Fire()
			end
		end)
	end
end

function WeatherService.init()
	task.wait(5)

	Lighting:GetPropertyChangedSignal("ClockTime"):Connect(updateWeather)

	Players.PlayerAdded:Connect(function(player)
		WeatherEvent:FireClient(player, WeatherService.currentWeather)
	end)
end

return WeatherService
