local module = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local GearFolder: Folder = workspace:WaitForChild("GearFolder")
local RemotesLegacy: Folder = ReplicatedStorage:WaitForChild("RemotesLegacy")

local VisualUpdate: RemoteEvent = RemotesLegacy:WaitForChild("VisualUpdate")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Billboards: Folder = ReplicatedStorage.Entities:WaitForChild("Billboards")

local MotionSensorParams = OverlapParams.new()
MotionSensorParams.FilterType = Enum.RaycastFilterType.Include

local lastAlerted: { [Model]: number } = {}
local SpawnPoints: { Model } = {}
local LocalMarkers: { Model } = {}
local GlobalMarkers: { Model } = {}
local MotionSensors: { Model } = {}

local function updateCollection(tagName: string)
	return CollectionService:GetTagged(tagName)
end

local BuildFunctions = {
	["SATCOM Radio"] = function()
		SpawnPoints = updateCollection("SpawnPoint")
	end,
	["Local Marker"] = function()
		LocalMarkers = updateCollection("LocalMarker")
	end,
	["Global Marker"] = function()
		GlobalMarkers = updateCollection("GlobalMarker")
	end,
	["Motion Sensor"] = function()
		task.wait(3)
		MotionSensors = updateCollection("MotionSensor")
	end,
}

local function onPlayerJoin()
	SpawnPoints = updateCollection("SpawnPoint")
	LocalMarkers = updateCollection("LocalMarker")
	GlobalMarkers = updateCollection("GlobalMarker")
	MotionSensors = updateCollection("MotionSensor")
end

local function onBuildAdded(build: Model)
	if BuildFunctions[build.Name] == nil then
		return
	end
	BuildFunctions[build.Name]()
end

local function onBuildRemoved(build: Model)
	if BuildFunctions[build.Name] == nil then
		return
	end
	BuildFunctions[build.Name]()
end

local function showBillboard(collection, guiName: string, owner: string?)
	if #collection == 0 then
		return
	end

	for _, item in collection do
		if owner and item:GetAttribute("Owner") ~= owner then
			continue
		end

		local gui = item:FindFirstChild(guiName)
		if not gui then
			gui = Billboards[guiName]:Clone()
			gui.Parent = item
		end

		local magnitude = (item.WorldPivot.Position - camera.CFrame.Position).Magnitude
		gui.Enabled = magnitude > 35
	end
end

local function ShowSpawnPoint()
	showBillboard(SpawnPoints, "SpawnPointGui", player.Name)
end

local function ShowLocalMarkers()
	showBillboard(LocalMarkers, "LocalMarkerGui", player.Name)
end

local function ShowGlobalMarkers()
	if #GlobalMarkers == 0 then
		return
	end

	for _, marker in GlobalMarkers do
		local gui = marker:FindFirstChild("GlobalMarkerGui")
		if not gui then
			local Light = marker:FindFirstChild("Light")
			if not Light then
				continue
			end

			gui = Billboards.GlobalMarkerGui:Clone()
			gui.Frame.TextLabel.Text = string.upper(marker:GetAttribute("Owner"))
			gui.Frame.ImageLabel.ImageColor3 = Light.Color
			gui.Frame.TextLabel.TextColor3 = Light.Color
			gui.Parent = marker
		end

		local magnitude = (marker.WorldPivot.Position - camera.CFrame.Position).Magnitude
		gui.Enabled = magnitude > 35
	end
end

local function UpdateMotionSensors()
	if #MotionSensors == 0 then
		return
	end

	MotionSensorParams.FilterDescendantsInstances = { workspace.Zombies }

	for i, sensor in MotionSensors do
		if not sensor or sensor.PrimaryPart == nil then
			table.remove(MotionSensors, i)
			continue
		end

		local parts = workspace:GetPartBoundsInRadius(sensor.PrimaryPart.Position, 40, MotionSensorParams)
		if #parts == 0 then
			continue
		end

		if lastAlerted[sensor] == nil or tick() - lastAlerted[sensor] > 5 then
			lastAlerted[sensor] = tick()
			local lightpart = sensor:FindFirstChild("LightPart")

			if lightpart then
				sensor.LightPart.MotionAlert:Play()
				sensor.LightPart.Color = Color3.fromRGB(255, 88, 88)
				sensor.LightPart.PointLight.Color = Color3.fromRGB(255, 88, 88)

				task.delay(5, function()
					sensor.LightPart.Color = Color3.fromRGB(172, 131, 77)
					sensor.LightPart.PointLight.Color = Color3.fromRGB(172, 131, 77)
				end)
			end
		end

		for _, part in parts do
			local model = part:FindFirstAncestorWhichIsA("Model")
			if not model then
				continue
			end

			model.Parent = workspace.MotionSensorZombies
		end
	end
end

local function onItemPurchased(textLabel: TextLabel, itemName: string)
	if not itemName then
		return
	end

	if textLabel ~= "Update" then
		if itemName == "M67" then
			return
		end
		textLabel.Text = itemName
		textLabel:FindFirstAncestorWhichIsA("Model"):SetAttribute("Purchased", true)
		return
	end

	for _, item in itemName do
		for _, weapon in workspace:WaitForChild("WeaponGivers"):GetChildren() do
			if weapon.Name == item then
				weapon.BillboardGui.TextLabel.Text = item
				weapon:SetAttribute("Purchased", true)
			end
		end

		for _, helmet in GearFolder:WaitForChild("Headgear"):GetChildren() do
			if helmet:GetAttribute("Title") == item then
				helmet.BillboardGui.TextLabel.Text = item
				helmet:SetAttribute("Purchased", true)
			end
		end

		for _, vest in GearFolder:WaitForChild("PlateCarriers"):GetChildren() do
			if vest:GetAttribute("Title") == item then
				vest.BillboardGui.TextLabel.Text = item
				vest:SetAttribute("Purchased", true)
			end
		end
	end
end

function module.init()
	Scheduler.AddToScheduler("Interval_0.1", "WorldUI", function()
		ShowSpawnPoint()
		ShowLocalMarkers()
		ShowGlobalMarkers()
		UpdateMotionSensors()
	end)

	workspace.Buildables.Player.ChildAdded:Connect(onBuildAdded)
	workspace.Buildables.Player.ChildRemoved:Connect(onBuildRemoved)

	CollectionService:GetInstanceAddedSignal("MotionSensor"):Connect(function()
		MotionSensors = CollectionService:GetTagged("MotionSensor")
	end)

	CollectionService:GetInstanceRemovedSignal("MotionSensor"):Connect(function()
		MotionSensors = CollectionService:GetTagged("MotionSensor")
	end)

	VisualUpdate.OnClientEvent:Connect(function(textLabel, itemName)
		onItemPurchased(textLabel, itemName)
	end)

	onPlayerJoin()
end

return module
