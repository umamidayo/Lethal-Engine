local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local folderWhitelist: { Folder | Instance } =
	{ workspace.Buildables, workspace.Buildables.Player, workspace.Buildables.Server }
local hovergui: BillboardGui = ReplicatedStorage.Entities:WaitForChild("Billboards"):WaitForChild("HoverGui")
local player: Player = Players.LocalPlayer
local mouse: Mouse = player:GetMouse()

local module = {}

local function GetModel()
	if mouse.Target == nil then
		return
	end
	if not mouse.Target:IsA("BasePart") then
		return
	end
	if player:DistanceFromCharacter(mouse.Target.Position) > 20 then
		return
	end

	local model = mouse.Target:FindFirstAncestorWhichIsA("Model") or mouse.Target:FindFirstAncestorWhichIsA("Workspace")
	if not table.find(folderWhitelist, model.Parent) then
		return
	end

	return model
end

function module.init()
	local build: Model = nil

	Scheduler.AddToScheduler("Interval_0.1", "BuildInfo", function()
		build = GetModel()

		if build and build:GetAttribute("Owner") then
			hovergui.Frame.BuildLabel.Text = string.upper(build.Name)
			hovergui.Frame.OwnerLabel.Text = string.upper("Owned by: " .. build:GetAttribute("Owner"))

			local maxHealth

			if build:GetAttribute("MaxHealth") then
				maxHealth = build:GetAttribute("MaxHealth")
			else
				maxHealth = build:GetAttribute("Health")
			end

			if build:HasTag("WiremodObject") and build:GetAttribute("Energy") then
				hovergui.Frame.WiremodLabel.Text = string.upper(
					"Energy: " .. math.floor(build:GetAttribute("Energy")) .. "/" .. build:GetAttribute("MaxEnergy")
				)
				hovergui.Frame.WiremodLabel.Visible = true
			else
				hovergui.Frame.WiremodLabel.Visible = false
			end

			hovergui.Frame.HealthLabel.Text =
				string.upper("HP: " .. math.floor(build:GetAttribute("Health")) .. "/" .. maxHealth)
			hovergui.Adornee = build
			hovergui.Parent = workspace
			hovergui.Enabled = true
		else
			hovergui.Parent = nil
			hovergui.Adornee = nil
			hovergui.Enabled = false
		end
	end)
end

return module
