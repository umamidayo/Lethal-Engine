local module = {}
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local remotesLegacy = ReplicatedStorage.RemotesLegacy
local DataStore2 = require(ServerScriptService.Modules.DataStore2)
local classer = require(ServerScriptService.Modules.Player.Classer)
local Network = require(ReplicatedStorage.Common.Network)
local Products = require(ReplicatedStorage.Common.Products.Products)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local Weather = require(ServerScriptService.Contents.Universal.Systems.Weather)
local Craftbag = require(ServerScriptService.Modules.Crafting.Craftbag)
local TestConfig = require(ServerScriptService.Contents.Universal.Systems.TestConfig)

module[117434328] = function(receiptInfo, player)
	print(`{player.DisplayName} [{player.Name}] purchased the A Small Loan of a Million Dollars gamepass.`)
	Network.fireClient(Network.RemoteEvents.StoreEvent, player, "GamepassPurchase", 117434328)
end

module[252800553] = function(receiptInfo, player)
	print(`{player.DisplayName} [{player.Name}] purchased the I'm Hungie For Some Matties! gamepass.`)
	Network.fireClient(Network.RemoteEvents.StoreEvent, player, "GamepassPurchase", 252800553)
end

module[255878424] = function(receiptInfo, player)
	print(`{player.DisplayName} [{player.Name}] purchased the Master's Degree In Architecture gamepass.`)
	Network.fireClient(Network.RemoteEvents.StoreEvent, player, "GamepassPurchase", 255878424)
end

module[1750167033] = function(receiptInfo, player)
	print(`{player.DisplayName} [{player.Name}] purchased 1,000 Tokens.`)
	local TokenStore = DataStore2("Tokens", player)
	TokenStore:Increment(1000)
	Network.fireClient(Network.RemoteEvents.StoreEvent, player, "TokenPurchase", 1750167033)
end

module[1750167295] = function(receiptInfo, player)
	print(`{player.DisplayName} [{player.Name}] purchased 2,200 Tokens.`)
	local TokenStore = DataStore2("Tokens", player)
	TokenStore:Increment(2200)
	Network.fireClient(Network.RemoteEvents.StoreEvent, player, "TokenPurchase", 1750167295)
end

module[1750167362] = function(receiptInfo, player)
	print(`{player.DisplayName} [{player.Name}] purchased 5,500 Tokens.`)
	local TokenStore = DataStore2("Tokens", player)
	TokenStore:Increment(5500)
	Network.fireClient(Network.RemoteEvents.StoreEvent, player, "TokenPurchase", 1750167362)
end

module[1750167926] = function(receiptInfo, player)
	print(`{player.DisplayName} [{player.Name}] purchased 15,125 Tokens.`)
	local TokenStore = DataStore2("Tokens", player)
	TokenStore:Increment(15125)
	Network.fireClient(Network.RemoteEvents.StoreEvent, player, "TokenPurchase", 1750167926)
end

function module.hasTokens(player: Player, cost: number)
	if TestConfig.isTestBuild then
		return true
	end

	local TokenStore = DataStore2("Tokens", player)
	return TokenStore:Get(0) >= cost
end

function module.removeTokens(player: Player, cost: number)
	if TestConfig.isTestBuild then
		return
	end

	local TokenStore = DataStore2("Tokens", player)
	TokenStore:Increment(-cost)
end

module["Doctor"] = function(player: Player)
	local productInfo = Products.classes["Doctor"]
	if not productInfo then
		return
	end
	if classer.mainClasser:hasClass(player, "Doctor") then
		Notifier.NotificationEvent(player, `You already own the Doctor class`)
		return
	end
	if module.hasTokens(player, productInfo.Cost) then
		classer.mainClasser:addClass(player, "Doctor")
		module.removeTokens(player, productInfo.Cost)
		Network.fireClient(Network.RemoteEvents.StoreEvent, player, "ClassPurchase", "Doctor")
	end
end

module["Engineer"] = function(player: Player)
	local productInfo = Products.classes["Engineer"]
	if not productInfo then
		return
	end
	if classer.mainClasser:hasClass(player, "Engineer") then
		Notifier.NotificationEvent(player, `You already own the Engineer class`)
		return
	end
	if module.hasTokens(player, productInfo.Cost) then
		classer.mainClasser:addClass(player, "Engineer")
		module.removeTokens(player, productInfo.Cost)
		Network.fireClient(Network.RemoteEvents.StoreEvent, player, "ClassPurchase", "Engineer")
	end
end

module["Blood Moon"] = function(activator: Player)
	if Weather.currentWeather == "BloodMoon" then
		Notifier.NotificationEvent(activator, `The Blood Moon is already active!`)
		return
	end
	if Weather.lastBloodMoon then
		if tick() - Weather.lastBloodMoon < 60 * 30 then
			Notifier.NotificationEvent(
				activator,
				`The blood moon can only be activated once every 30 minutes!`,
				nil,
				10
			)
			Notifier.NotificationEvent(
				activator,
				`Blood Moon will availabile in: {math.floor(60 - (tick() - Weather.lastBloodMoon) / 30)} minutes`,
				nil,
				10
			)
			return
		end
	end
	local productInfo = Products.special["Blood Moon"]
	if not productInfo then
		return
	end
	if not module.hasTokens(activator, productInfo.Cost) then
		Notifier.NotificationEvent(activator, `You don't have enough tokens to activate the Blood Moon`)
		return
	end
	module.removeTokens(activator, productInfo.Cost)
	for _, player in Players:GetPlayers() do
		Notifier.NotificationEvent(
			player,
			`{activator.DisplayName} has activated the Blood Moon!`,
			Color3.fromRGB(189, 46, 46),
			10
		)
	end
	Weather.activateBloodMoon()
end

local function giveMaterial(player: Player, material: string, quantity: number)
	Craftbag.IncrementQuantity(player, material, quantity)
	Network.fireClient(Network.RemoteEvents.StoreEvent, player, "MaterialPurchase", material)
	remotesLegacy.CraftEvent:FireClient(player, "BagUpdate", Craftbag.GetCraftbag(player))
end

module["99 Sticks"] = function(player: Player)
	if not module.hasTokens(player, 200) then
		Notifier.NotificationEvent(player, `You don't have enough tokens to purchase 99 Sticks`)
		return
	end
	module.removeTokens(player, 200)
	giveMaterial(player, "Stick", 99)
end

module["99 Rocks"] = function(player: Player)
	if not module.hasTokens(player, 200) then
		Notifier.NotificationEvent(player, `You don't have enough tokens to purchase 99 Rocks`)
		return
	end
	module.removeTokens(player, 200)
	giveMaterial(player, "Rock", 99)
end

module["99 Cloth"] = function(player: Player)
	if not module.hasTokens(player, 200) then
		Notifier.NotificationEvent(player, `You don't have enough tokens to purchase 99 Cloth`)
		return
	end
	module.removeTokens(player, 200)
	giveMaterial(player, "Cloth", 99)
end

module["99 Metal"] = function(player: Player)
	if not module.hasTokens(player, 200) then
		Notifier.NotificationEvent(player, `You don't have enough tokens to purchase 99 Metal`)
		return
	end
	module.removeTokens(player, 200)
	giveMaterial(player, "Metal", 99)
end

module["99 Plastic"] = function(player: Player)
	if not module.hasTokens(player, 200) then
		Notifier.NotificationEvent(player, `You don't have enough tokens to purchase 99 Plastic`)
		return
	end
	module.removeTokens(player, 200)
	giveMaterial(player, "Plastic", 99)
end

module["500 Building Materials"] = function(player: Player)
	if not module.hasTokens(player, 200) then
		Notifier.NotificationEvent(player, `You don't have enough tokens to purchase 500 Building Materials`)
		return
	end
	local Materials = DataStore2("Materials", player)
	Materials:Increment(1000)
	module.removeTokens(player, 200)
	Network.fireClient(Network.RemoteEvents.StoreEvent, player, "MaterialPurchase", "BuildingMaterials")
end

return module
