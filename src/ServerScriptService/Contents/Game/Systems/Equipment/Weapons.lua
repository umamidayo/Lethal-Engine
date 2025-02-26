local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Network = require(ReplicatedStorage.Common.Network)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local PurchaseModule = require(ServerScriptService.Modules.PurchaseModule)

local MAX_DISTANCE = 12
local COOLDOWN = 0.2
local debounces = {}

local function giveWeapon(player: Player, weaponName: string)
	if player.Backpack:FindFirstChild(weaponName) then
		Notifier.NotificationEvent(player, `You already have the {weaponName}`)
		return false
	end

	local weapon = ServerStorage.Tools:FindFirstChild(weaponName)
	if not weapon then
		return false
	end

	local newWeapon = weapon:Clone()
	newWeapon.Parent = player.Backpack
	return true
end

local function handleWeaponPurchase(player: Player, weaponName: string, cost: number)
	if debounces[player] and (tick() - debounces[player]) < COOLDOWN then
		return
	end
	debounces[player] = tick()

	if not PurchaseModule.MakePurchase(player, weaponName, cost) then
		return
	end

	if player.Backpack:FindFirstChild(weaponName) then
		player.Backpack:FindFirstChild(weaponName):Destroy()
	end

	giveWeapon(player, weaponName)
end

local module = {}

function module.init()
	local weaponsFolder = workspace.WeaponGivers
	local billboardTemplate = ReplicatedStorage.Entities.Billboards.EquipmentGui

	for _, weapon in weaponsFolder:GetChildren() do
		if RunService:IsStudio() then
			weapon:SetAttribute("Cost", 0)
		end

		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = MAX_DISTANCE
		clickDetector.Parent = weapon

		local gui = billboardTemplate:Clone()
		gui.TextLabel.Text = `{weapon.Name} (${weapon:GetAttribute("Cost")})`
		gui.Parent = weapon

		clickDetector.MouseClick:Connect(function(player)
			if (player.Character.PrimaryPart.Position - weapon.WorldPivot.Position).Magnitude > MAX_DISTANCE then
				return
			end

			handleWeaponPurchase(player, weapon.Name, weapon:GetAttribute("Cost"))
		end)
	end

	Network.connectEvent(Network.RemoteEvents.Purchase, function(player: Player, itemName: string)
		local weapon = weaponsFolder:FindFirstChild(itemName)
		if not weapon then
			return
		end

		handleWeaponPurchase(player, weapon.Name, weapon:GetAttribute("Cost"))
	end)
end

return module
