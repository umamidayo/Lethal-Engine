local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Network = require(ReplicatedStorage.Common.Network)
local VectorLib = require(ReplicatedStorage.Common.Libraries.VectorLib)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local Maid = require(ReplicatedStorage.Common.Libraries.Maid)

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local maid = Maid.new()
local Entities = ReplicatedStorage:WaitForChild("Entities")
local SelectHighlight: Highlight = Entities:WaitForChild("Highlights"):WaitForChild("WiremodHighlight")
local NotifierColors = {
	Removed = Color3.fromRGB(218, 97, 97),
	Added = Color3.fromRGB(136, 228, 136),
	Default = Color3.fromRGB(255, 255, 255),
}

local ModelA: Model, ModelB: Model

local module = {}

local function HasWireConnection()
	for _, Wire in ModelA:GetDescendants() do
		if Wire:IsA("RopeConstraint") then
			local Attachment0 = Wire.Attachment0
			local Attachment1 = Wire.Attachment1

			if not Attachment0 or not Attachment1 then
				continue
			end
			if not Attachment0.Parent or not Attachment1.Parent then
				continue
			end
			if not Attachment0.Parent.Parent or not Attachment1.Parent.Parent then
				continue
			end

			if Attachment0.Parent.Parent == ModelA and Attachment1.Parent.Parent == ModelB then
				return Wire
			elseif Attachment0.Parent.Parent == ModelB and Attachment1.Parent.Parent == ModelA then
				return Wire
			end
		end
	end

	for _, Wire in ModelB:GetDescendants() do
		if Wire:IsA("RopeConstraint") then
			local Attachment0 = Wire.Attachment0
			local Attachment1 = Wire.Attachment1

			if not Attachment0 or not Attachment1 then
				continue
			end
			if not Attachment0.Parent or not Attachment1.Parent then
				continue
			end
			if not Attachment0.Parent.Parent or not Attachment1.Parent.Parent then
				continue
			end

			if Attachment0.Parent.Parent == ModelA and Attachment1.Parent.Parent == ModelB then
				return Wire
			elseif Attachment0.Parent.Parent == ModelB and Attachment1.Parent.Parent == ModelA then
				return Wire
			end
		end
	end
end

function module.Equip(Tool: Tool)
	local elapsed = 0

	local HeartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.05 then
			return
		end
		elapsed = 0

		if not Mouse.Target then
			SelectHighlight.Adornee = nil
			return
		end

		if LocalPlayer:DistanceFromCharacter(Mouse.Hit.Position) > 10 then
			SelectHighlight.Adornee = nil
			return
		end

		local Model = Mouse.Target:FindFirstAncestorWhichIsA("Model")

		if not Model or not Model:HasTag("WiremodObject") then
			SelectHighlight.Adornee = nil
			return
		end

		SelectHighlight.Adornee = Model
	end)

	local ClickConnection = Tool.Activated:Connect(function()
		if not Mouse.Target then
			return
		end

		if not ModelA then
			local Model = Mouse.Target:FindFirstAncestorWhichIsA("Model")
			if not Model or Model.Parent ~= workspace.Buildables.Player then
				return
			end

			if not Model:HasTag("WiremodObject") then
				return Notifier.new("Must select a wireable object", NotifierColors.Removed)
			end

			if LocalPlayer:DistanceFromCharacter(Mouse.Hit.Position) > 10 then
				return Notifier.new("Too far away", NotifierColors.Removed)
			end

			ModelA = Model
			Notifier.new("Select a new wireable object to configure a connection", NotifierColors.Default)
			return
		elseif not ModelB then
			local Model = Mouse.Target:FindFirstAncestorWhichIsA("Model")
			if not Model or Model.Parent ~= workspace.Buildables.Player then
				return
			end

			if not Model:HasTag("WiremodObject") then
				return Notifier.new("Must select a wireable object", NotifierColors.Removed)
			end

			if LocalPlayer:DistanceFromCharacter(Mouse.Hit.Position) > 10 then
				return Notifier.new("Too far away", NotifierColors.Removed)
			end

			if not VectorLib.inRange(ModelA.WorldPivot.Position, Model.WorldPivot.Position, 60) then
				return Notifier.new("Length is too long", NotifierColors.Removed)
			end

			ModelB = Model

			if ModelA == ModelB then
				ModelA = nil
				ModelB = nil
				Notifier.new("Cannot wire the same object", NotifierColors.Removed)
				return
			else
				local Wire = HasWireConnection()

				if Wire then
					Network.fireServer(Network.RemoteEvents.RemoveWireConnection, Wire)
				else
					Network.fireServer(Network.RemoteEvents.AddWireConnection, ModelA, ModelB)
				end

				ModelA = nil
				ModelB = nil
			end
		end
	end)

	maid:GiveTask(ClickConnection)
	maid:GiveTask(HeartbeatConnection)
end

function module.Unequip()
	if ModelA then
		Notifier.new("Cancelled wire configuration")
		ModelA = nil
		ModelB = nil
	end

	SelectHighlight.Adornee = nil

	maid:DoCleaning()
end

return module
