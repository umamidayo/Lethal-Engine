local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local Storage_Event = ReplicatedStorage:WaitForChild("RemotesLegacy"):WaitForChild("Storage_Event")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("StorageGui")
local itemSample = ReplicatedStorage:WaitForChild("UI"):WaitForChild("ItemSample")
local playerSample = ReplicatedStorage:WaitForChild("UI"):WaitForChild("PlayerSample")
local main = gui:WaitForChild("Main")
local storageList = main:WaitForChild("Storage"):WaitForChild("Contents")
local backpackList = main:WaitForChild("Backpack"):WaitForChild("Contents")
local permissionsList = gui:WaitForChild("Permissions"):WaitForChild("Contents")

local CurrentStorage: Model = nil

type Item = {
	itemName: number,
}

local module = {}

local function DepositItem(item: Tool)
	if not item.CanBeDropped then
		Notifier.new("You can't store this item")
		return
	end

	Storage_Event:FireServer(CurrentStorage, "Deposit", item)
end

local function WithdrawItem(itemName: string)
	Storage_Event:FireServer(CurrentStorage, "Withdraw", itemName)
end

local function ChangePermissions(otherPlayer: Player)
	if CurrentStorage:GetAttribute("Owner") ~= player.Name then
		Notifier.new("You don't own this storage")
		return
	end

	if player == otherPlayer then
		Notifier.new("You can't remove your own access to your storage, silly")
		return
	end

	Storage_Event:FireServer(CurrentStorage, "Permissions", otherPlayer)
end

local function updateStorageList(StorageItems)
	for _, v in storageList:GetChildren() do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	if StorageItems then
		for i, v in StorageItems do
			local newButton = itemSample:Clone()
			newButton.ItemName.Text = i
			newButton.Quantity.Text = v .. "x"
			newButton.Parent = storageList

			newButton.MouseButton1Click:Connect(function()
				WithdrawItem(i)
			end)
		end
	end
end

local function updateBackpackList()
	for _, v in backpackList:GetChildren() do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	local items = {}

	for i, v in player.Backpack:GetChildren() do
		if items[v.Name] == nil then
			items[v.Name] = 1
		else
			items[v.Name] += 1
		end
	end

	for i, v in items do
		local newButton = itemSample:Clone()
		newButton.ItemName.Text = i
		newButton.Quantity.Text = v .. "x"
		newButton.Parent = backpackList

		newButton.MouseButton1Click:Connect(function()
			DepositItem(player.Backpack:FindFirstChild(i))
		end)
	end
end

local function updatePermissionsList(StoragePermissions)
	for _, v in permissionsList:GetChildren() do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for _, v: Player in game.Players:GetPlayers() do
		local newButton = playerSample:Clone()
		newButton.Text = v.DisplayName
		if table.find(StoragePermissions, v.Name) then
			newButton.BackgroundColor3 = Color3.fromRGB(105, 180, 88)
		else
			newButton.BackgroundColor3 = Color3.fromRGB(180, 83, 83)
		end
		newButton.Parent = permissionsList

		newButton.MouseButton1Click:Connect(function()
			ChangePermissions(v)
		end)
	end
end

function module.init()
	Storage_Event.OnClientEvent:Connect(
		function(Action: string, Storage: Model, StorageItems: { Item }, StoragePermissions: { Player })
			if Action == "Open" then
				CurrentStorage = Storage
				updatePermissionsList(StoragePermissions)
				updateStorageList(StorageItems)
				updateBackpackList()
				gui.Enabled = true
			elseif Action == "Update" then
				if gui.Enabled == false then
					return
				end
				if player:DistanceFromCharacter(Storage.WorldPivot.Position) > 8 then
					return
				end
				if CurrentStorage ~= Storage then
					return
				end
				updateStorageList(StorageItems)
				updateBackpackList()
			elseif Action == "Permissions" then
				if not table.find(StoragePermissions, player.Name) then
					gui.Enabled = false
					return
				end

				updatePermissionsList(StoragePermissions)
			end
		end
	)

	main.CloseButton.MouseButton1Click:Connect(function()
		gui.Enabled = false
	end)

	Scheduler.AddToScheduler("Interval_0.1", "StorageUI", function()
		if not CurrentStorage then
			return
		end
		if player:DistanceFromCharacter(CurrentStorage.WorldPivot.Position) <= 8 then
			return
		end
		CurrentStorage = nil
		gui.Enabled = false
	end)
end

return module
