local Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local TweenService: TweenService = game:GetService("TweenService")

local Network = require(ReplicatedStorage.Common.Network)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local HUNGER_RATE = 0.05
local THIRST_RATE = 0.05
local tips: { [string]: string } = {
	Thirsty = {
		"FILL AN EMPTY BOTTLE AT A BODY OF WATER",
		"FILL AN EMPTY BOTTLE AT A RAIN BARREL",
		"YOU CAN BOIL DIRTY WATER AT A CAMPFIRE",
		"YOU MAY FIND WATER IN A CARDBOARD BOX",
	},

	Hungry = {
		"FORAGE FOR SOME BLUEBERRIES",
		"HUNT A DEER AND COOK IT AT A CAMPFIRE",
		"YOU MAY FIND FOOD IN A CARDBOARD BOX",
	},

	Health = {
		"SLEEP IN A BED TO SLOWLY HEAL",
		"USE A BANDAGE OR MEDKIT TO FULLY HEAL",
		"EAT OR DRINK FOOD TO HEAL SOME HEALTH",
	},
}

local changeTween: TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local character: Model, hungerStat: number, thirstStat: number, lastEnergyDrinkTick: number
local player: Player = Players.LocalPlayer
local playerGui: PlayerGui = player:WaitForChild("PlayerGui")
local main: ScreenGui = playerGui:WaitForChild("Main")
local food: Frame = main:WaitForChild("Food")
local hungerFrame: Frame = food:WaitForChild("Hunger")
local thirstFrame: Frame = food:WaitForChild("Thirst")

local lastNotify: { [string]: number } = {}
local module = {}

local function onCharacterAdded(newcharacter: Model)
	character = newcharacter

	local humanoid: Humanoid = character:WaitForChild("Humanoid")

	character:SetAttribute("Hunger", 30)
	character:SetAttribute("Thirst", 30)

	hungerStat = character:GetAttribute("Hunger")
	thirstStat = character:GetAttribute("Thirst")

	hungerFrame.Filler.Size = UDim2.new(hungerStat / 100, 0, 1, 0)
	thirstFrame.Filler.Size = UDim2.new(thirstStat / 100, 0, 1, 0)

	TweenService:Create(thirstFrame.Filler, changeTween, { Size = UDim2.new(thirstStat / 100, 0, 1, 0) }):Play()
	TweenService:Create(hungerFrame.Filler, changeTween, { Size = UDim2.new(hungerStat / 100, 0, 1, 0) }):Play()

	humanoid.HealthChanged:Connect(function(health)
		if health > 35 or health <= 0 then
			return
		end
		if lastNotify["Health"] ~= nil and tick() - lastNotify["Health"] < 60 then
			return
		end
		lastNotify["Health"] = tick()
		Notifier.new("YOUR HEALTH IS LOW, " .. tips.Health[math.random(1, #tips.Health)], Color3.fromRGB(255, 115, 115))
	end)

	character:GetAttributeChangedSignal("Hunger"):Connect(function()
		hungerStat = character:GetAttribute("Hunger")

		if hungerStat > 100 then
			character:SetAttribute("Hunger", 100)
		elseif hungerStat < 45 and hungerStat > 0 then
			if lastNotify["Hungry"] == nil or tick() - lastNotify["Hungry"] >= 60 then
				lastNotify["Hungry"] = tick()
				Notifier.new(
					"YOU ARE HUNGRY, " .. tips.Hungry[math.random(1, #tips.Hungry)],
					Color3.fromRGB(255, 213, 87)
				)
			end
		elseif hungerStat < 0 then
			if lastNotify["Starve"] == nil or tick() - lastNotify["Starve"] >= 10 then
				lastNotify["Starve"] = tick()
				Notifier.new(
					"YOU ARE STARVING, " .. tips.Hungry[math.random(1, #tips.Hungry)],
					Color3.fromRGB(255, 213, 87)
				)
			end
			character:SetAttribute("Hunger", 0)
			Network.fireServer(Network.RemoteEvents.FoodEvent, "Malnutrition")
		end

		TweenService:Create(hungerFrame.Filler, changeTween, { Size = UDim2.new(hungerStat / 100, 0, 1, 0) }):Play()
	end)

	character:GetAttributeChangedSignal("Thirst"):Connect(function()
		thirstStat = character:GetAttribute("Thirst")

		if thirstStat > 100 then
			character:SetAttribute("Thirst", 100)
		elseif thirstStat < 45 and thirstStat > 0 then
			if lastNotify["Thirsty"] == nil or tick() - lastNotify["Thirsty"] >= 60 then
				lastNotify["Thirsty"] = tick()
				Notifier.new(
					"YOU ARE THIRSTY, " .. tips.Thirsty[math.random(1, #tips.Thirsty)],
					Color3.fromRGB(84, 167, 255)
				)
			end
		elseif thirstStat < 0 then
			if lastNotify["Dehydrated"] == nil or tick() - lastNotify["Dehydrated"] >= 10 then
				lastNotify["Dehydrated"] = tick()
				Notifier.new(
					"YOU ARE DEHYDRATED, " .. tips.Thirsty[math.random(1, #tips.Thirsty)],
					Color3.fromRGB(84, 167, 255)
				)
			end
			character:SetAttribute("Thirst", 0)
			Network.fireServer(Network.RemoteEvents.FoodEvent, "Malnutrition")
		end

		TweenService:Create(thirstFrame.Filler, changeTween, { Size = UDim2.new(thirstStat / 100, 0, 1, 0) }):Play()
	end)

	character:GetAttributeChangedSignal("BonusWalkSpeed"):Connect(function()
		local BonusWalkSpeed: number = character:GetAttribute("BonusWalkSpeed")

		if BonusWalkSpeed and BonusWalkSpeed > 0 then
			lastEnergyDrinkTick = tick()
			Notifier.new("You feel more energetic and are faster at running.")
		else
			Notifier.new("Your energy is back to normal.")
			if character.Humanoid.WalkSpeed > 24 then
				character.Humanoid.WalkSpeed = 24
			elseif character.Humanoid.WalkSpeed < 24 and character.Humanoid.WalkSpeed > 12 then
				character.Humanoid.WalkSpeed = 12
			end
		end
	end)
end

local function onPlayerJoin()
	character = player.Character or player.CharacterAdded:Wait()

	onCharacterAdded(character)

	character:SetAttribute("Hunger", 75)
	character:SetAttribute("Thirst", 75)

	hungerStat = character:GetAttribute("Hunger")
	thirstStat = character:GetAttribute("Thirst")

	hungerFrame.Filler.Size = UDim2.new(hungerStat / 100, 0, 1, 0)
	thirstFrame.Filler.Size = UDim2.new(thirstStat / 100, 0, 1, 0)

	TweenService:Create(thirstFrame.Filler, changeTween, { Size = UDim2.new(thirstStat / 100, 0, 1, 0) }):Play()
	TweenService:Create(hungerFrame.Filler, changeTween, { Size = UDim2.new(hungerStat / 100, 0, 1, 0) }):Play()
end

function module.init()
	repeat
		task.wait()
	until player.Character and player.Character:IsDescendantOf(workspace)

	onPlayerJoin()

	player.CharacterAdded:Connect(onCharacterAdded)

	player.Character:GetAttributeChangedSignal("EnergyConservative"):Connect(function()
		local EnergyConservative = player.Character:GetAttribute("EnergyConservative")
		if EnergyConservative then
			HUNGER_RATE = 0.05 - (0.05 * (EnergyConservative / 100))
		else
			HUNGER_RATE = 0.05
		end
	end)

	Scheduler.AddToScheduler("Interval_1s", "HungerThirst", function()
		if not character or character.Humanoid.Health <= 0 then
			return
		end

		if lastEnergyDrinkTick ~= nil and tick() - lastEnergyDrinkTick > 180 then
			lastEnergyDrinkTick = nil
			character:SetAttribute("BonusWalkSpeed", nil)
		end

		if player.Team ~= Teams.Survivor then
			return
		end

		if not hungerStat or not thirstStat then
			warn(script.Name .. " hunger and thirst stats not connected")
		end

		hungerStat = character:GetAttribute("Hunger")
		thirstStat = character:GetAttribute("Thirst")

		character:SetAttribute("Hunger", hungerStat - HUNGER_RATE)
		character:SetAttribute("Thirst", thirstStat - THIRST_RATE)
	end)

	Network.connectEvent(Network.RemoteEvents.FoodEvent, function(eventType: string, params: {})
		if eventType == "EatFinish" then
			local FoodAmount: number = params.FoodAmount
			local DrinkAmount: number = params.DrinkAmount
			character:SetAttribute("Hunger", hungerStat + FoodAmount)
			character:SetAttribute("Thirst", thirstStat + DrinkAmount)
		end
	end, Network.t.string, Network.t.table)
end

return module
