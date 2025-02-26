local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local VisualUpdateEvent = ReplicatedStorage:WaitForChild("RemotesLegacy"):WaitForChild("VisualUpdate")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("WorkbenchGui")
-- local prompt = ReplicatedStorage:WaitForChild("Entities"):WaitForChild("WorkbenchPrompt"):Clone()
local ItemLabel = gui.Frame.ItemLabel
local CategoryLabel = gui.Frame.CategoryLabel
local index = 1

local weapons: { Model }, equipment: { Model }, workbenches: { Model }, items: { Model } = {}, {}, {}, {}

local module = {}

-- Updates all of the tables with CollectionService
local function updateItems()
	items = {}

	weapons = workspace:WaitForChild("WeaponGivers"):GetChildren()

	for i, v in weapons do
		if v:GetAttribute("Title") == nil then
			v:SetAttribute("Title", v.Name)
		end

		if v:GetAttribute("Category") == nil then
			v:SetAttribute("Category", "Weapon")
		end

		table.insert(items, v)
	end

	equipment = CollectionService:GetTagged("Equipment")

	for _, v in equipment do
		local model = v:FindFirstChildWhichIsA("Model")
		if not model then
			continue
		end

		if v:GetAttribute("Category") == nil then
			v:SetAttribute("Category", model.Name)
		end

		table.insert(items, v)
	end

	table.sort(items, function(a, b)
		return a.Name < b.Name
	end)

	if items[index]:GetAttribute("Purchased") then
		ItemLabel.Text = items[index]:GetAttribute("Title")
	else
		ItemLabel.Text = items[index]:GetAttribute("Title") .. " ($" .. items[index]:GetAttribute("Cost") .. ")"
	end

	CategoryLabel.Text = items[index]:GetAttribute("Category")
end

-- Increments the index and updates the workbench UI
local function nextIndex()
	index = index % #items + 1

	if items[index]:GetAttribute("Purchased") then
		ItemLabel.Text = items[index]:GetAttribute("Title")
	else
		ItemLabel.Text = items[index]:GetAttribute("Title") .. " ($" .. items[index]:GetAttribute("Cost") .. ")"
	end

	CategoryLabel.Text = items[index]:GetAttribute("Category")
end

-- Decrements the index and updates the workbench UI
local function previousIndex()
	if index > 1 then
		index -= 1
	else
		index = #items
	end

	if items[index]:GetAttribute("Purchased") then
		ItemLabel.Text = items[index]:GetAttribute("Title")
	else
		ItemLabel.Text = items[index]:GetAttribute("Title") .. " ($" .. items[index]:GetAttribute("Cost") .. ")"
	end

	CategoryLabel.Text = items[index]:GetAttribute("Category")
end

-- Updates the workbenches table with CollectionService's instance events
local function updateWorkbenches()
	workbenches = CollectionService:GetTagged("Workbench")
	updateItems()
end

function module.init()
	updateItems()

	gui.Frame.Next.MouseButton1Click:Connect(function()
		nextIndex()
	end)

	gui.Frame.Previous.MouseButton1Click:Connect(function()
		previousIndex()
	end)

	gui.Frame.Build.MouseButton1Click:Connect(function()
		game:WaitForChild("ReplicatedStorage")
			:WaitForChild("RemotesLegacy")
			:WaitForChild("Purchase")
			:FireServer(items[index]:GetAttribute("Title"))
	end)

	-- prompt.Triggered:Connect(function()
	-- 	player.PlayerGui.CraftGui.Enabled = true
	-- end)

	VisualUpdateEvent.OnClientEvent:Connect(function()
		ItemLabel.Text = items[index]:GetAttribute("Title")
	end)

	CollectionService:GetInstanceAddedSignal("Workbench"):Connect(function()
		updateWorkbenches()
	end)

	CollectionService:GetInstanceRemovedSignal("Workbench"):Connect(function()
		updateWorkbenches()
	end)

	Scheduler.AddToScheduler("Interval_0.1", "WorkbenchUI", function()
		if #workbenches <= 0 then
			updateWorkbenches()
		end

		for _, workbench in workbenches do
			if not workbench:FindFirstChild("GuiPart") then
				continue
			end

			if player:DistanceFromCharacter(workbench.WorldPivot.Position) > 12 then
				if gui.Adornee == workbench.GuiPart then
					gui.Adornee = nil
					-- if prompt then
					-- 	prompt.Parent = nil
					-- end
				end
				continue
			end

			if gui.Adornee ~= workbench.GuiPart then
				gui.Adornee = workbench.GuiPart
				-- if not prompt then
				-- 	prompt = script.ProximityPrompt:Clone()
				-- end
				-- prompt.Parent = workbench.PrimaryPart
			end
		end
	end)
end

return module
