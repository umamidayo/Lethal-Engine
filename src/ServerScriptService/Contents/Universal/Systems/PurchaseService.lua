local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ReplicatedStorage.Common.Network)
local productFunctions = require(ServerScriptService.Modules.Products.ProductFunctions)

local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")

local PurchaseService = {}

type ReceiptInfo = {
	PurchaseId: number | string,
	PlayerId: number,
	ProductId: number,
	PlaceIdWherePurchased: number,
	CurrenySpent: number,
	CurrencyType: Enum.CurrencyType,
}

function PurchaseService.processReceipt(receiptInfo: ReceiptInfo)
	local playerProductKey = `{receiptInfo.PlayerId}_{receiptInfo.PurchaseId}`
	local purchased = false
	local success, result, errMsg, isPurchaseRecorded

	success, errMsg = pcall(function()
		purchased = purchaseHistoryStore:GetAsync(playerProductKey)
	end)

	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		error(`Datastore error: {errMsg}`)
	end

	playerProductKey = `{receiptInfo.PlayerId}_{receiptInfo.PurchaseId}`

	success, errMsg = nil, nil

	success, isPurchaseRecorded = pcall(function()
		return purchaseHistoryStore:UpdateAsync(playerProductKey, function(alreadyPurchased)
			if alreadyPurchased then
				print(`Already purchased.`)
				return true
			end

			local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
			if not player then
				print(`Player not found.`)
				return nil
			end

			task.spawn(function()
				success, result = pcall(function()
					return productFunctions[receiptInfo.ProductId](receiptInfo, player)
				end)

				if not success or not result then
					if not RunService:IsStudio() then
						error(
							`Error processing product purchase: {result} | {receiptInfo.ProductId} | {receiptInfo.PlayerId} | {receiptInfo.PurchaseId} | {receiptInfo.PlaceIdWherePurchased} | {receiptInfo.CurrenySpent} | {receiptInfo.CurrencyType}`
						)
						return nil
					end
				end
			end)

			return true
		end)
	end)

	if not success then
		error(`Failed to process receipt due to datastore error.`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	elseif isPurchaseRecorded == nil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

function PurchaseService.init()
	Network.connectEvent(Network.RemoteEvents.StoreEvent, function(player: Player, eventType: string, productId: number)
		if eventType == "Purchase" then
			productFunctions[productId](player)
			Network.fireClient(Network.RemoteEvents.StoreEvent, player, "PurchaseSuccess", productId)
		end
	end, Network.t.instanceOf("Player"), Network.t.string, Network.t.number)

	MarketplaceService.ProcessReceipt = PurchaseService.processReceipt
end

return PurchaseService
