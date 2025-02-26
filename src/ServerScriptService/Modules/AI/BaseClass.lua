local module = {}
module.__index = module

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Common.Libraries.Maid)

function module.new(character: Model, useCharacterModel: boolean?)
	local self = setmetatable({}, module)
	self.maid = Maid.new()
	self.Character = useCharacterModel and character or character:Clone()
	self.Humanoid = self.Character:WaitForChild("Humanoid") :: Humanoid
	self.agentParams = {
		AgentRadius = 1.1,
		AgentHeight = 2,
		AgentCanJump = true,
		AgentCanClimb = true,
		WaypointSpacing = 6,
		Costs = {},
	}
	self.Path = PathfindingService:CreatePath(self.agentParams)
	self.Waypoints = nil
	self.Destination = nil
	self.Pathfinding = false

	self.maid:GiveTask(self.Humanoid.Died:Connect(function()
		self.maid:DoCleaning()
		setmetatable(self, nil)
	end))

	self.maid:GiveTask(self.Character.Destroying:Connect(function()
		self.maid:DoCleaning()
		setmetatable(self, nil)
	end))

	return self
end

function module:Destroy()
	if self.Character then
		self.Character:Destroy()
	end
	self.maid:DoCleaning()
	setmetatable(self, nil)
end

return module
