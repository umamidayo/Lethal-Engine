local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Equipment = require(ReplicatedStorage.Common.Equipment)
local PurchaseModule = require(ServerScriptService.Modules.PurchaseModule)

local visualupdate = ReplicatedStorage.RemotesLegacy.VisualUpdate
local billboardgui = ReplicatedStorage.Entities.Billboards.EquipmentGui

local AllEquipment = CollectionService:GetTagged("Equipment")
local debounce = {}
local COOLDOWN = 0.2

local function handlePurchase(player: Player, equipment: Model)
	if debounce[player] and (tick() - debounce[player]) < COOLDOWN then
		return false
	end
	debounce[player] = tick()

	local purchased =
		PurchaseModule.MakePurchase(player, equipment:GetAttribute("Title"), equipment:GetAttribute("Cost"))

	if purchased then
		visualupdate:FireClient(
			player,
			equipment:FindFirstChildOfClass("BillboardGui").TextLabel,
			equipment:GetAttribute("Title")
		)
	end

	return purchased
end

local function getAttachType(equipment: Model)
	for attachPoint in Equipment.AttachPoints.R6 do
		if equipment:FindFirstChild(attachPoint) then
			return attachPoint
		end
	end
	return nil
end

local function setupEquipmentGui(equipment: Model, attachType: string?)
	local gui = billboardgui:Clone()
	gui.StudsOffset = Vector3.new(0, 2, 0)

	local text = equipment:GetAttribute("Title")
	if attachType == "Helmet" or attachType == "Vest" then
		text = text .. " +" .. equipment:GetAttribute("Protection")
	end
	text = text .. " ($" .. equipment:GetAttribute("Cost") .. ")"

	gui.TextLabel.Text = text
	gui.Enabled = true
	gui.Parent = equipment
end

local function handleEquipment(player: Player, equipment: Model, model: Model, attachType: string)
	if player.Character:FindFirstChild(model.Name) then
		Equipment.Unequip(attachType, player.Character)
		Equipment.RemoveProtection(player, attachType, equipment)
	else
		Equipment.Equip(model, player.Character, attachType)
		Equipment.AddProtection(player, attachType, equipment)
	end
end

local module = {}

function module.init()
	-- Setup equipment models
	for _, equipment in AllEquipment do
		local model = equipment:FindFirstChildOfClass("Model")
		if not model then
			continue
		end

		if model.Name == "Nods" then
			Equipment.ConfigureNVGs(model)
		end

		local attachType = getAttachType(equipment)
		if RunService:IsStudio() then
			equipment:SetAttribute("Cost", 0)
		end

		setupEquipmentGui(equipment, attachType)

		local clickdetector = Instance.new("ClickDetector")
		clickdetector.MaxActivationDistance = 12
		clickdetector.Parent = equipment

		clickdetector.MouseClick:Connect(function(player)
			if player:DistanceFromCharacter(equipment.WorldPivot.Position) > clickdetector.MaxActivationDistance then
				return
			end

			if not handlePurchase(player, equipment) then
				return
			end
			handleEquipment(player, equipment, model, attachType)
		end)
	end

	-- Handle remote purchases
	ReplicatedStorage.RemotesLegacy.Purchase.OnServerEvent:Connect(function(player, itemName: string)
		local equipment
		for _, model in AllEquipment do
			if model:GetAttribute("Title") == itemName then
				equipment = model
				break
			end
		end
		if not equipment then
			return
		end

		local model = equipment:FindFirstChildOfClass("Model")
		if not model then
			return
		end

		local attachType = getAttachType(equipment)
		if not handlePurchase(player, equipment) then
			return
		end
		handleEquipment(player, equipment, model, attachType)
	end)
end

return module
