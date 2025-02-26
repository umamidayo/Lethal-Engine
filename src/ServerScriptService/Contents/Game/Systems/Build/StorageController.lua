local module = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Storage_Event = ReplicatedStorage.RemotesLegacy.Storage_Event
local Notifier = ReplicatedStorage.RemotesLegacy.Notifier
local StorageModule = require(ServerScriptService.Modules.Build.StorageModule)
local debounce = {}

local function NotifyOwner(storage: Model, player: Player, message: string)
	local owner: Player = Players:FindFirstChild(storage:GetAttribute("Owner"))

	if owner and owner ~= player then
		Notifier:FireClient(owner, message)
	end
end

local function hasPermissions(player: Player, storage: Model)
	return table.find(StorageModule.StoragePermissions[storage], player.Name)
end

function module.init()
	Storage_Event.OnServerEvent:Connect(
		function(player, storage: Model, action: string, argument: Tool | string | Player)
			if not storage or not action or not argument or StorageModule.Storages[storage] == nil then
				return
			end
			if not storage:IsA("Model") or storage.Name ~= "Storage" then
				return
			end
			if player:DistanceFromCharacter(storage.WorldPivot.Position) > 8 then
				Notifier:FireClient(player, "You're too far")
				return
			end

			if action == "Deposit" then
				if debounce[player] ~= nil and tick() - debounce[player] < 0.1 then
					return
				end
				debounce[player] = tick()

				if not argument.CanBeDropped then
					return
				end
				if not hasPermissions(player, storage) then
					return
				end
				if argument.Parent == player.Backpack or argument.Parent == player.Character then
					StorageModule.DepositItem(storage, argument)
					storage.PrimaryPart.StorageSound.PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
					storage.PrimaryPart.StorageSound:Play()
					Storage_Event:FireAllClients("Update", storage, StorageModule.Storages[storage])
					NotifyOwner(
						storage,
						player,
						player.DisplayName .. " stored " .. argument.Name .. " into your storage"
					)
				end
			elseif action == "Withdraw" then
				if debounce[player] ~= nil and tick() - debounce[player] < 0.75 then
					return
				end
				debounce[player] = tick()

				if not hasPermissions(player, storage) then
					return
				end
				if StorageModule.Storages[storage][argument] then
					local item = StorageModule.WithdrawItem(storage, argument)
					storage.PrimaryPart.StorageSound.PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
					item.Parent = player.Backpack
					storage.PrimaryPart.StorageSound:Play()
					Storage_Event:FireAllClients("Update", storage, StorageModule.Storages[storage])
					NotifyOwner(storage, player, player.DisplayName .. " took " .. argument .. " from your storage")
				end
			elseif action == "Permissions" then
				if debounce[player] ~= nil and tick() - debounce[player] < 0.1 then
					return
				end
				debounce[player] = tick()

				local owner = Players:FindFirstChild(storage:GetAttribute("Owner"))
				if owner and owner == player and owner ~= argument then
					local index = hasPermissions(argument, storage)
					if index then
						table.remove(StorageModule.StoragePermissions[storage], index)
						Notifier:FireClient(player, "Removed storage access from " .. argument.DisplayName)
						Notifier:FireClient(argument, player.DisplayName .. " removed your access to their storage")
						Storage_Event:FireClient(
							argument,
							"Permissions",
							storage,
							StorageModule.Storages[storage],
							StorageModule.StoragePermissions[storage]
						)
					else
						table.insert(StorageModule.StoragePermissions[storage], argument.Name)
						Notifier:FireClient(player, "Gave storage access to " .. argument.DisplayName)
						Notifier:FireClient(argument, player.DisplayName .. " gave you access to their storage")
					end
					Storage_Event:FireClient(
						player,
						"Permissions",
						storage,
						StorageModule.Storages[storage],
						StorageModule.StoragePermissions[storage]
					)
				end
			end
		end
	)

	Players.PlayerRemoving:Connect(function(player)
		if debounce[player] ~= nil then
			debounce[player] = nil
		end
	end)
end

return module
