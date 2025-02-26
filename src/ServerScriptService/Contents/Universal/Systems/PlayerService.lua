local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Classer = require(ServerScriptService.Modules.Player.Classer)
local DataStore2 = require(ServerScriptService.Modules.DataStore2)
local Network = require(ReplicatedStorage.Common.Network)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local store = require(ReplicatedStorage.Common.Store)
local StoreUtility = require(ReplicatedStorage.Common.StoreUtility)

local classer = Classer.new()
local playerDataStore = {}
local perksFolder = ReplicatedStorage.Common.PlayerClass.Perks

Classer.mainClasser = classer

local baseRewardTokens = 15
local defaultDailyData = {
	lastClaim = nil,
	streak = 0,
}
local perks = {}

local PlayerService = {}

-- Sets up the player's cash, kills, and materials.
function PlayerService.setupPlayerStats(player: Player)
	classer:setup(player)

	if not playerDataStore[player.Name] then
		playerDataStore[player.Name] = {
			Cash = 750,
			Kills = 0,
			Materials = 10,
			Tokens = 0,
			DailyData = {
				lastClaim = nil,
				streak = 0,
			},
		}

		-- Gamepass
		if MarketplaceService:UserOwnsGamePassAsync(player.UserId, 117434328) then
			playerDataStore[player.Name].Cash += 750
		end

		-- Group perks
		if player:IsInGroup(10705478) then
			playerDataStore[player.Name].Materials += 20
			playerDataStore[player.Name].Cash += 250
		end
	end

	-- Load datastores
	playerDataStore[player.Name].DataStores = {
		Kills = DataStore2("Kills", player),
		Materials = DataStore2("Materials", player),
		Tokens = DataStore2("Tokens", player),
		Daily = DataStore2("Daily", player),
	}

	-- Updating client
	player:SetAttribute("Cash", playerDataStore[player.Name].Cash)
	player:SetAttribute("Kills", playerDataStore[player.Name].DataStores.Kills:Get(0))
	player:SetAttribute(
		"Materials",
		math.floor(playerDataStore[player.Name].DataStores.Materials:Get(playerDataStore[player.Name].Materials))
	)
	player:SetAttribute("Tokens", playerDataStore[player.Name].DataStores.Tokens:Get(0))
	playerDataStore[player.Name].DailyData = playerDataStore[player.Name].DataStores.Daily:Get(defaultDailyData)

	-- Datastore updated events

	playerDataStore[player.Name].DataStores.Kills:OnUpdate(function(kills)
		player:SetAttribute("Kills", kills)
		playerDataStore[player.Name].Kills = kills
	end)

	playerDataStore[player.Name].DataStores.Materials:OnUpdate(function(mats)
		player:SetAttribute("Materials", math.floor(mats))
		playerDataStore[player.Name].Materials = math.floor(mats)
	end)

	playerDataStore[player.Name].DataStores.Tokens:OnUpdate(function(tokens)
		player:SetAttribute("Tokens", tokens)
		playerDataStore[player.Name].Tokens = tokens
	end)

	playerDataStore[player.Name].DataStores.Daily:OnUpdate(function(dailyData)
		playerDataStore[player.Name].DailyData = dailyData
	end)
end

-- Caches the player's cash, kills, and materials when leaving the game. Takes the state and sets it as the player's profile data.
function PlayerService.onPlayerRemoving(player: Player)
	playerDataStore[player.Name] = {
		Cash = player:GetAttribute("Cash"),
		Kills = player:GetAttribute("Kills"),
		Materials = player:GetAttribute("Materials"),
		Tokens = player:GetAttribute("Tokens"),
	}

	local playerClass = StoreUtility.waitForValue("playerClass", player.UserId)
	if playerClass then
		local className = playerClass.className
		local level = playerClass.level
		local experience = playerClass.experience

		local profile = classer:getProfile(player)
		profile.Data[className] = {
			Level = level,
			Experience = experience,
		}

		profile:Release()
		store:dispatch({
			type = "CLEANUP_PLAYER",
			userId = player.UserId,
		})
	else
		error(`Failed to get playerClass data to save for {player.Name}`)
	end
end

function PlayerService.playerMeetsPerkRequirements(profile: { any }, perkName: string, className: string)
	local perkpoints = profile.perkpoints
	local playerperks = profile.perks
	if table.find(playerperks, perkName) then
		return
	end
	if perkpoints <= 0 then
		return
	end
	if perks[className][perkName].Requirements then
		for _, requirement in perks[className][perkName].Requirements do
			if table.find(playerperks, requirement) == nil then
				warn(`{perkName} requires {requirement} to be purchased.`)
				return
			end
		end
	end
	return true
end

function PlayerService.incrementStat(player: Player, stat: string, amount: number)
	local playerData = playerDataStore[player.Name]
	if not playerData then
		return
	end

	playerData[stat] += amount
	player:SetAttribute(stat, playerData[stat])
end

function PlayerService.init()
	for _, perk in pairs(perksFolder:GetChildren()) do
		local perkData = require(perk)
		perks[perk.Name] = perkData
	end

	Players.PlayerAdded:Connect(function(player)
		PlayerService.setupPlayerStats(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		PlayerService.onPlayerRemoving(player)
	end)

	Network.bindFunction(Network.RemoteFunctions.InitialStateSync, function()
		return store:getState().playerClass
	end, Network.t.instanceOf("Player"))

	Network.connectEvent(Network.RemoteEvents.DailyEvent, function(player: Player, eventType: string)
		if eventType == "getDailyData" then
			local lastClaim = playerDataStore[player.Name].DailyData.lastClaim
			local newData

			if lastClaim and os.time() - lastClaim >= 172800 then -- After 2 days, reset daily reward
				newData = {
					lastClaim = nil,
					streak = 0,
				}
			elseif lastClaim and os.time() - lastClaim < 172800 then -- If it's been less than 2 days, keep the streak
				newData = playerDataStore[player.Name].DailyData
			else -- If it's the first time claiming the daily reward
				newData = defaultDailyData
			end

			local newReward = baseRewardTokens * (newData.streak + 1)
			playerDataStore[player.Name].DataStores.Daily:Set(newData)
			playerDataStore[player.Name].DailyData.reward =
				math.clamp(newReward, baseRewardTokens, baseRewardTokens * 7)
			Network.fireClient(
				Network.RemoteEvents.DailyEvent,
				player,
				"newData",
				playerDataStore[player.Name].DailyData
			)
		elseif eventType == "claimDailyReward" then
			local lastClaim = playerDataStore[player.Name].DailyData.lastClaim
			local streak = playerDataStore[player.Name].DailyData.streak

			if lastClaim and os.time() - lastClaim < 86400 then
				return
			end
			lastClaim = os.time()
			streak += 1

			playerDataStore[player.Name].DataStores.Daily:Set({
				lastClaim = lastClaim,
				streak = streak,
			})

			local newData = {
				lastClaim = lastClaim,
				streak = streak,
				reward = math.clamp(baseRewardTokens * streak, baseRewardTokens, baseRewardTokens * 7),
			}

			local tokenStore = playerDataStore[player.Name].DataStores.Tokens
			tokenStore:Increment(math.clamp(baseRewardTokens * streak, baseRewardTokens, baseRewardTokens * 7))
			print(`{player.DisplayName} claimed {baseRewardTokens * streak} tokens.`)
			Network.fireClient(Network.RemoteEvents.DailyEvent, player, "newData", newData)
		end
	end, Network.t.instanceOf("Player"), Network.t.string, Network.t.any)

	Network.connectEvent(Network.RemoteEvents.PlayerClassEvent, function(player: Player, eventType: string, params: any)
		if eventType == "SpendPerkPoint" then
			local playerclassState = store:getState().playerClass
			local profile = playerclassState[player.UserId]
			if not profile then
				return
			end

			local className = profile.className
			local perkName = params.perkName
			if not perks[className] or not perks[className][perkName] then
				return
			end

			if not PlayerService.playerMeetsPerkRequirements(profile, perkName, className) then
				return
			end

			if perks[className][perkName].PerkFunction then
				perks[className][perkName].PerkFunction(player)
			end

			store:dispatch({
				type = "SPEND_PERK_POINT",
				userId = player.UserId,
				perkName = perkName,
			})
			Network.fireClient(Network.RemoteEvents.PlayerClassEvent, player, "SpendPerkPoint")
		elseif eventType == "ResetPerks" then
			store:dispatch({
				type = "RESET_PERKS",
				userId = player.UserId,
			})

			if player.Character then
				player.Character.Humanoid.Health = 0
			end
			Network.fireClient(Network.RemoteEvents.PlayerClassEvent, player, "ResetPerks")
		elseif eventType == "ChangeClass" then
			local playerclassState = store:getState().playerClass
			local profile = playerclassState[player.UserId]
			if not profile then
				return
			end

			local className = params.className
			if not classer:hasClass(player, className) then
				Notifier.NotificationEvent(player, `You don't have the {className} class.`)
				return
			end

			local classProfile = classer:getProfile(player)
			classProfile.Data[profile.className] = {
				Level = profile.level,
				Experience = profile.experience,
			}

			classer:saveClassData(player)
			Notifier.NotificationEvent(player, `Saved {profile.className} class data.`)
			classer:setClass(player, className)

			if player.Character then
				player.Character.Humanoid.Health = 0
			end
			Network.fireClient(Network.RemoteEvents.PlayerClassEvent, player, "ChangeClass")
		end
	end, Network.t.instanceOf("Player"), Network.t.string, Network.t.any)
end

return PlayerService
