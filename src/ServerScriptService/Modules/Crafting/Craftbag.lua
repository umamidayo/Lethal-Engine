local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Store = require(ReplicatedStorage.Common.Store)
local StoreUtility = require(ReplicatedStorage.Common.StoreUtility)

local Craftbag = {}

function Craftbag.IncrementQuantity(Player: Player, Name: string, Quantity: number)
	local materials = StoreUtility.waitForValue("inventory", Player.UserId, "materials")
	local currentAmount = materials[Name] or 0
	Store:dispatch({
		type = "setMaterials",
		userId = Player.UserId,
		materials = {
			[Name] = math.clamp(currentAmount + Quantity, 0, 99)
		}
	})
end

function Craftbag.GetQuantity(Player: Player, materialName: string)
	local materials = StoreUtility.waitForValue("inventory", Player.UserId, "materials")
	return materials[materialName] or 0
end

function Craftbag.removeFromInventory(player: Player, itemName: string, quantity: number)
	local items = {}
	for _, tool in player.Backpack:GetChildren() do
		if tool.Name == itemName then
			table.insert(items, tool)
		end
	end

	if player.Character then
		local tool = player.Character:FindFirstChild(itemName)
		if tool then
			table.insert(items, tool)
		end
	end

	for i = 1, math.min(#items, quantity) do
		items[i]:Destroy()
	end
end

function Craftbag.GetQuantityFromInventory(Player: Player, Name: string)
	local quantity = 0
	for _, tool in Player.Backpack:GetChildren() do
		if tool.Name == Name then
			quantity += 1
		end
	end

	if Player.Character then
		local tool = Player.Character:FindFirstChild(Name)
		if tool then
			quantity += 1
		end
	end

	return quantity
end

function Craftbag.GetCraftbag(Player: Player)
	return StoreUtility.waitForValue("inventory", Player.UserId, "materials")
end

return Craftbag
