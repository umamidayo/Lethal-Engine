-- Disables the body temperature system
if true then
	return {}
end

local Teams = game:GetService("Teams")
local module = {}

function module.init()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local CollectionService = game:GetService("CollectionService")
	local Lighting = game:GetService("Lighting")
	local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)
	local Network = require(ReplicatedStorage.Common.Network)
	local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
	local LocalPlayer = Players.LocalPlayer
	local PlayerGui = LocalPlayer.PlayerGui or LocalPlayer:WaitForChild("PlayerGui")
	local MainGui: ScreenGui = PlayerGui:WaitForChild("Main")
	local effects = MainGui:WaitForChild("Effects")
	local container: Frame = MainGui:WaitForChild("BodyTemp")
	local pointer: ImageLabel = container:WaitForChild("Pointer")
	local heatSources = CollectionService:GetTagged("HeatSource")
	local blur = Lighting:WaitForChild("BodyTempBlur")

	local tweeninfos = {
		pointerTween = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		effectsTween = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	}

	local notifyColors = {
		Cold = Color3.fromRGB(141, 177, 255),
		Hot = Color3.fromRGB(255, 172, 133),
	}

	local currentWeather = nil
	local lastNotified = nil
	local currentBodyTemp = 0
	local COLD_TEMP = -0.75
	local HOT_TEMP = 0.75
	local COLD_RATE = 0.001
	local COLD_RATE_DAY = 0.0025
	local COLD_RATE_NIGHT = 0.005
	local COLD_RATE_RAIN = 0.01
	local HOT_RATE = 0.6
	local SWIM_MULTIPLIER = 4
	local COLD_TOLERANCE = -0.9
	local HOT_TOLERANCE = 0.9

	local function rotatePointer()
		local angle = 170 * currentBodyTemp
		TweenService:Create(pointer, tweeninfos.pointerTween, { Rotation = angle }):Play()
	end

	local function isAlive()
		local Character = LocalPlayer.Character
		if not Character then
			return
		end
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		if not Humanoid then
			return
		end
		return Humanoid.Health > 0, Humanoid, Character
	end

	local function applyResistancePerks(Character: Model)
		local ColdResistance = Character:GetAttribute("ColdResistance") or 0
		local HeatResistance = Character:GetAttribute("HeatResistance") or 0

		COLD_TEMP = -0.75 + (-0.75 * ColdResistance / 100)
		HOT_TEMP = 0.75 + (0.75 * HeatResistance / 100)

		return ColdResistance > 0, HeatResistance > 0
	end

	local function updateEffects()
		if currentBodyTemp <= COLD_TEMP then
			if not lastNotified or tick() - lastNotified >= 30 then
				lastNotified = tick()
				Notifier.new("You are freezing, stand close to heat sources", notifyColors.Cold, 5)
			end
			local coldIntensity = 1 - math.abs(currentBodyTemp)
			TweenService:Create(effects.ColdFX, tweeninfos.effectsTween, { ImageTransparency = coldIntensity }):Play()
			TweenService:Create(effects.HotFX, tweeninfos.effectsTween, { ImageTransparency = 1 }):Play()
			if currentBodyTemp <= COLD_TOLERANCE then
				blur.Enabled = true
				TweenService:Create(blur, tweeninfos.effectsTween, { Size = 15 }):Play()
				return
			else
				local blurTween = TweenService:Create(blur, tweeninfos.effectsTween, { Size = 0 })
				blurTween:Play()
				blurTween.Completed:Wait()
				blur.Enabled = false
				return
			end
		elseif currentBodyTemp >= HOT_TEMP then
			if not lastNotified or tick() - lastNotified >= 30 then
				lastNotified = tick()
				Notifier.new("You are overheating, stay away from heat sources", notifyColors.Hot, 5)
			end
			local hotIntensity = 1 - currentBodyTemp
			TweenService:Create(effects.HotFX, tweeninfos.effectsTween, { ImageTransparency = hotIntensity }):Play()
			TweenService:Create(effects.ColdFX, tweeninfos.effectsTween, { ImageTransparency = 1 }):Play()
			if currentBodyTemp >= HOT_TOLERANCE then
				blur.Enabled = true
				TweenService:Create(blur, tweeninfos.effectsTween, { Size = 15 }):Play()
				return
			else
				local blurTween = TweenService:Create(blur, tweeninfos.effectsTween, { Size = 0 })
				blurTween:Play()
				blurTween.Completed:Wait()
				blur.Enabled = false
				return
			end
		else
			lastNotified = nil
			TweenService:Create(effects.HotFX, tweeninfos.effectsTween, { ImageTransparency = 1 }):Play()
			TweenService:Create(effects.ColdFX, tweeninfos.effectsTween, { ImageTransparency = 1 }):Play()
			if blur.Enabled then
				local blurTween = TweenService:Create(blur, tweeninfos.effectsTween, { Size = 0 })
				blurTween:Play()
				blurTween.Completed:Wait()
				blur.Enabled = false
				return
			end
		end
	end

	CollectionService:GetInstanceAddedSignal("HeatSource"):Connect(function()
		heatSources = CollectionService:GetTagged("HeatSource")
	end)

	CollectionService:GetInstanceRemovedSignal("HeatSource"):Connect(function()
		heatSources = CollectionService:GetTagged("HeatSource")
	end)

	ReplicatedStorage.RemotesLegacy.WeatherEvent.OnClientEvent:Connect(function(weather)
		currentWeather = weather
	end)

	Scheduler.AddToScheduler("Interval_1s", "BodyTemp", function()
		if Lighting.ClockTime < 6 or Lighting.ClockTime > 18 then
			if currentWeather == "Rain" and COLD_RATE ~= COLD_RATE_RAIN + COLD_RATE_NIGHT then
				COLD_RATE = COLD_RATE_RAIN + COLD_RATE_NIGHT
			else
				if COLD_RATE ~= COLD_RATE_NIGHT then
					COLD_RATE = COLD_RATE_NIGHT
				end
			end
		else
			if currentWeather == "Rain" and COLD_RATE ~= COLD_RATE_RAIN + COLD_RATE_DAY then
				COLD_RATE = COLD_RATE_RAIN + COLD_RATE_DAY
			else
				if COLD_RATE ~= COLD_RATE_DAY then
					COLD_RATE = COLD_RATE_DAY
				end
			end
		end

		local alive, Humanoid, Character = isAlive()
		if not alive then
			currentBodyTemp = 0
			rotatePointer()
			updateEffects()
			return
		end
		if LocalPlayer.Team ~= Teams.Survivor then
			currentBodyTemp = 0
			rotatePointer()
			updateEffects()
			return
		end

		local hasColdResist, hasHotResist = applyResistancePerks(Character)

		if hasColdResist and currentBodyTemp < -0.25 then
			COLD_RATE = COLD_RATE / 2
		end

		if currentBodyTemp <= COLD_TOLERANCE or currentBodyTemp >= HOT_TOLERANCE then
			Network.fireServer(Network.RemoteEvents.BodyTempEvent, "Damage")
		end

		if Humanoid:GetState() == Enum.HumanoidStateType.Swimming then
			currentBodyTemp = math.clamp(currentBodyTemp - (COLD_RATE * SWIM_MULTIPLIER), -1, 1)
			rotatePointer()
			updateEffects()
			return
		end

		if #heatSources == 0 then
			currentBodyTemp = math.clamp(currentBodyTemp - COLD_RATE, -1, 1)
			rotatePointer()
			updateEffects()
			return
		end

		local nearHeatSource, sourceDistance = nil, nil

		for _, heatSource in heatSources do
			sourceDistance = (LocalPlayer:DistanceFromCharacter(heatSource.WorldPivot.Position))
			if sourceDistance <= 15 then
				nearHeatSource = true
				break
			end
		end

		if nearHeatSource then
			local heatIntensity = HOT_RATE / sourceDistance ^ 2
			if hasHotResist and currentBodyTemp > 0.25 then
				heatIntensity = heatIntensity / 2
			end
			currentBodyTemp = math.clamp(currentBodyTemp + heatIntensity, -1, 1)
			rotatePointer()
			updateEffects()
			return
		else
			currentBodyTemp = math.clamp(currentBodyTemp - COLD_RATE, -1, 1)
			rotatePointer()
			updateEffects()
			return
		end
	end)
end

return module
