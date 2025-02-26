local ServerScriptService = game:GetService("ServerScriptService")
local module = {}

module.purchased = {}
module.CashStore = {}
module.consumableItems = { "M67" }

local DS2 = require(ServerScriptService.Modules.DataStore2)

function module.MakePurchase(player: Player, itemName: string, cost: number)
	if table.find(module.consumableItems, itemName) then
		if player.Backpack:FindFirstChild(itemName) then
			return true
		end

		if player:GetAttribute("Cash") >= cost then
			player:SetAttribute("Cash", player:GetAttribute("Cash") - cost)
			print(script.Name .. " - " .. player.Name .. " purchased " .. itemName)
			return true
		end
	end

	local account = nil

	for i, v in pairs(module.purchased) do
		if i == player.Name then
			account = v
			break
		end
	end

	if account == nil then
		module.purchased[player.Name] = {}
	end

	if module.CashStore[player.Name] == nil then
		module.CashStore[player.Name] = DS2("Cash", player)
	end

	for i, v in pairs(module.purchased[player.Name]) do
		if v == itemName then
			return true
		end
	end

	if player:GetAttribute("Cash") >= cost then
		player:SetAttribute("Cash", player:GetAttribute("Cash") - cost)
		table.insert(module.purchased[player.Name], itemName)
		print(script.Name .. " - " .. player.Name .. " purchased " .. itemName)
		return true
	end
end

return module
