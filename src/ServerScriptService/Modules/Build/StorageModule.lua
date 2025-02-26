local StorageModule = {
	Storages = {},
	StoragePermissions = {}
}

function StorageModule.Create(storage: Model, player: Player)
	StorageModule.Storages[storage] = {}
	StorageModule.StoragePermissions[storage] = {player.Name}
end

function StorageModule.DepositItem(storage: Model, item: Tool)
	if StorageModule.Storages[storage][item.Name] then
		StorageModule.Storages[storage][item.Name] += 1
	else
		StorageModule.Storages[storage][item.Name] = 1
	end
	
	item:Destroy()
end

function StorageModule.WithdrawItem(storage: Model, itemName: string)
	if StorageModule.Storages[storage][itemName] then
		StorageModule.Storages[storage][itemName] -= 1
		
		if StorageModule.Storages[storage][itemName] == 0 then
			StorageModule.Storages[storage][itemName] = nil
		end
	end
	
	local item = game.ServerStorage.Tools:FindFirstChild(itemName)
	
	if item then
		return item:Clone()
	end
end

function StorageModule.CleanUp(storage: Model)
	StorageModule.Storages[storage] = nil
	StorageModule.StoragePermissions[storage] = nil
end

return StorageModule
