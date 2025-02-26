local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")

local PurchaseModule = require(ServerScriptService.Modules.PurchaseModule)

local notifier = ReplicatedStorage.RemotesLegacy.Notifier
local weaponsFolder = workspace.WeaponGivers
local visualupdate = ReplicatedStorage.RemotesLegacy.VisualUpdate

local billboardgui = ReplicatedStorage.Entities.Billboards.EquipmentGui
local cooldown = 0.2

local debounce = {}
local module = {}

local function giveWeapon(player, weaponName)
	local weapon = ServerStorage.Tools:FindFirstChild(weaponName)

	if weapon then
		local newWeapon = weapon:Clone()
		newWeapon.Parent = player.Backpack
	end
end

function module.init()
	for _, weapon in weaponsFolder:GetChildren() do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = weapon

		if RunService:IsStudio() then
			weapon:SetAttribute("Cost", 0)
		end

		local gui = billboardgui:Clone()
		gui.TextLabel.Text = weapon.Name .. " ($" .. weapon:GetAttribute("Cost") .. ")"
		gui.Parent = weapon
		gui.Enabled = true

		clickDetector.MouseClick:Connect(function(player)
			if
				(player.Character.PrimaryPart.Position - clickDetector.Parent.WorldPivot.Position).Magnitude
				> clickDetector.MaxActivationDistance
			then
				return
			end
			if debounce[player] ~= nil and (tick() - debounce[player]) < cooldown then
				return
			end
			debounce[player] = tick()

			local purchased = PurchaseModule.MakePurchase(player, weapon.Name, weapon:GetAttribute("Cost"))

			if purchased then
				visualupdate:FireClient(player, gui.TextLabel, weapon.Name)
			else
				return
			end

			if player.Backpack:FindFirstChild(weapon.Name) then
				player.Backpack:FindFirstChild(weapon.Name):Destroy()
			end

			giveWeapon(player, weapon.Name)
		end)
	end

	ReplicatedStorage.RemotesLegacy.Purchase.OnServerEvent:Connect(function(player, itemName: string)
		if debounce[player] ~= nil and (tick() - debounce[player]) < cooldown then
			return
		end
		debounce[player] = tick()

		local weapon = workspace.WeaponGivers:FindFirstChild(itemName)

		if weapon then
			local purchased = PurchaseModule.MakePurchase(player, weapon.Name, weapon:GetAttribute("Cost"))

			if purchased then
				visualupdate:FireClient(player, weapon:FindFirstChildOfClass("BillboardGui").TextLabel, weapon.Name)
			else
				return
			end

			if player.Backpack:FindFirstChild(weapon.Name) then
				notifier:FireClient(player, "You already have the " .. weapon.Name)
				return
			end

			giveWeapon(player, weapon.Name)
		end
	end)
end

return module
