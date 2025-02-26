local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterLib = require(ReplicatedStorage.Common.Libraries.CharacterLibrary)
local Network = require(ReplicatedStorage.Common.Network)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local WireLib = require(ReplicatedStorage.Common.Libraries.Wiremod.Wire)
local Wiremod = require(ReplicatedStorage.Common.Libraries.Wiremod.Wiremod)

local ToolLib = ReplicatedStorage.Common.ToolLib

local NotifierColors = {
	Removed = Color3.fromRGB(218, 97, 97),
	Added = Color3.fromRGB(136, 228, 136),
	Default = Color3.fromRGB(255, 255, 255),
}

local function validateWireConnection(player: Player, modelA: Model, modelB: Model): (boolean, string?)
	if not modelA or not modelB then
		return false, "Invalid models"
	end

	if modelA.Parent ~= workspace.Buildables.Player or modelB.Parent ~= workspace.Buildables.Player then
		return false, "Models must be player buildables"
	end

	local tool = CharacterLib.GetEquippedTool(player)
	if not tool or not ToolLib:FindFirstChild(tool.Name) then
		return false, "Must have valid tool equipped"
	end

	local objectA = Wiremod.GetObjectFromModel(modelA)
	local objectB = Wiremod.GetObjectFromModel(modelB)
	if not objectA or not objectB then
		return false, "Invalid wiremod objects"
	end

	if objectA.ObjectType == objectB.ObjectType then
		return false, "Cannot wire to an object of the same type"
	end

	return true, nil, objectA, objectB
end

local module = {}

function module.init()
	Network.connectEvent(Network.RemoteEvents.AddWireConnection, function(player: Player, modelA: Model, modelB: Model)
		local isValid, errorMessage, objectA, objectB = validateWireConnection(player, modelA, modelB)
		if not isValid then
			if errorMessage then
				Notifier.NotificationEvent(player, errorMessage, NotifierColors.Removed)
			end
			return
		end

		local wireConstraint = WireLib.CreateWire(modelA, modelB)
		local wire = WireLib.new(wireConstraint, objectA, objectB)

		objectA:NewConnection(wire)
		objectB:NewConnection(wire)

		WireLib.PlayWiringSound(player.Character.PrimaryPart)
		Notifier.NotificationEvent(
			player,
			"Added new wire connection: " .. modelA.Name .. " + " .. modelB.Name,
			NotifierColors.Added
		)
	end, Network.t.instanceOf("Player"), Network.t.instanceIsA("Model"), Network.t.instanceIsA("Model"))

	Network.connectEvent(
		Network.RemoteEvents.RemoveWireConnection,
		function(player: Player, wireConstraint: RopeConstraint)
			if not wireConstraint then
				return
			end

			local wire = WireLib.GetObjectFromConstraint(wireConstraint)
			if not wire or not wire.ObjectA or not wire.ObjectB then
				return
			end

			local tool = CharacterLib.GetEquippedTool(player)
			if not tool or not ToolLib:FindFirstChild(tool.Name) then
				return
			end

			wire.ObjectA:RemoveConnection(wire)
			wire.ObjectB:RemoveConnection(wire)

			WireLib.PlayWiringSound(player.Character.PrimaryPart)
			Notifier.NotificationEvent(
				player,
				"Removed wire connection: " .. wire.ObjectA.Model.Name .. " + " .. wire.ObjectB.Model.Name,
				NotifierColors.Removed
			)
			wire:Destroy()
		end,
		Network.t.instanceOf("Player"),
		Network.t.instanceIsA("RopeAttachment")
	)
end

return module
