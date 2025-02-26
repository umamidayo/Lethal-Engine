local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WireLib = require(script.Parent.Wire)
local Maid = require(ReplicatedStorage.Common.Libraries.Maid)
local module = {}
module.__index = module

module.Objects = {}

--[[
    The base class of all Wiremod objects except for the Wire.
]]
export type WiremodObject = {
	Owner: string,
	Model: Model,
	ObjectType: string,
	Connections: { WireLib.WireObject },
}

function module.new(ownerName: string, model: Model)
	local Object = {}
	setmetatable(Object, module)

	Object.Owner = ownerName
	Object.Model = model
	Object.ObjectType = nil
	Object.Connections = {}
	Object.maid = Maid.new()
	Object.maid:GiveTask(Object.Model.Destroying:Connect(function()
		Object:ClearConnections()
		Object:Destroy()
	end))

	table.insert(module.Objects, Object)

	return Object
end

function module:NewConnection(connection: WireLib.WireObject)
	table.insert(self.Connections, connection)
end

function module:RemoveConnection(connection: WireLib.WireObject)
	local index = table.find(self.Connections, connection)
	if not index then
		return warn(script.Name .. " - Couldn't find wire from removal")
	else
		table.remove(self.Connections, index)
	end

	task.delay(0.1, function()
		if self.ObjectType == "Consumer" and self.IsPowered then
			if self:IsPowered() then
				self.buildObject:disable()
			end
		end
	end)
end

function module:ClearConnections()
	for _, Wire in self.Connections do
		if Wire.ObjectA and Wire.ObjectA.Connections then
			if table.find(Wire.ObjectA.Connections, Wire) then
				Wire.ObjectA:RemoveConnection(Wire)
			end
		end

		if Wire.ObjectB and Wire.ObjectB.Connections then
			if table.find(Wire.ObjectB.Connections, Wire) then
				Wire.ObjectB:RemoveConnection(Wire)
			end
		end

		Wire:Destroy()
	end
end

function module.GetModelsFromWire(Wire: RopeConstraint)
	local ModelA = Wire.Attachment0:FindFirstAncestorWhichIsA("Model")
	local ModelB = Wire.Attachment1:FindFirstAncestorWhichIsA("Model")
	return ModelA, ModelB
end

function module.GetObjectFromModel(Model: Model)
	for _, Object in module.Objects do
		if Object.Model == Model then
			return Object
		end
	end
end

-- NOTE: With the exception of Wire instances, this will clean up all Wiremod objects.
function module:Destroy()
	if self.Stop then
		self:Stop()
	end

	-- Remove from global wiremod objects table
	local index = table.find(module.Objects, self)
	if index then
		table.remove(module.Objects, index)
	end

	self.maid:DoCleaning()

	-- Remove from wiremod metatable
	setmetatable(self, nil)
end

return module
