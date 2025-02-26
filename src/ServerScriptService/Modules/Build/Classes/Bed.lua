local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)
local BuildClass = require(ServerScriptService.Modules.Build.Classes.BuildClass)
local Instancer = require(ReplicatedStorage.Common.Libraries.Instancer)
local Maid = require(ReplicatedStorage.Common.Libraries.Maid)
local module = {}
module.__index = module
setmetatable(module, BuildClass)

function module.new(model: Model, player: Player)
	local self = BuildClass.new(model, player)
	setmetatable(self, module)
	self.occupantMaid = Maid.new()
	self.seat = self.model.LayingSeat :: Seat
	self.proximityprompt = Instancer.ProximityPrompt({
		maxActivationDistance = 7,
		actionText = "Sleep (Heal)",
		requiresLineOfSight = false,
		holdDuration = 0.5,
		parent = self.seat,
	})
	self.playerSitting = nil
	self.occupant = nil
	self.character = nil

	self.maid:GiveTask(self.seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if self.seat.Occupant then
			self:occupy(self.seat.Occupant)
		else
			self:unoccupy()
		end
	end))

	self.maid:GiveTask(self.model.Destroying:Connect(function()
		Scheduler.RemoveFromScheduler("Interval_0.5", self.model)
	end))

	self.maid:GiveTask(self.proximityprompt.Triggered:Connect(function(playerWhoTriggered)
		if
			self.occupant
			or not playerWhoTriggered.Character
			or not playerWhoTriggered.Character.Humanoid
			or playerWhoTriggered.Character.Humanoid.Health <= 0
		then
			return
		end

		if playerWhoTriggered.Character:GetAttribute("Laying") then
			return
		end
		self:occupy(playerWhoTriggered.Character.Humanoid)
	end))

	return self
end

function module:occupy(occupant: Humanoid)
	self.proximityprompt.Enabled = false
	self.model:SetAttribute("InUse", true)
	if occupant then
		occupant:UnequipTools()
		self.seat:Sit(occupant)
		self.occupant = occupant
		self.character = self.occupant.Parent
		self.character:SetAttribute("Laying", true)
		self.playerSitting = Players:GetPlayerFromCharacter(self.character)

		self.occupantMaid:GiveTask(self.character:GetPropertyChangedSignal("Parent"):Connect(function()
			if not self.character or not self.character.Parent then
				self:unoccupy()
			end
		end))

		self.occupantMaid:GiveTask(occupant.Died:Connect(function()
			self:unoccupy()
		end))
	end
end

function module:unoccupy()
	if self.proximityprompt then
		self.proximityprompt.Enabled = true
	end

	if self.model then
		self.model:SetAttribute("InUse", false)
	end

	if self.character then
		self.character:SetAttribute("Laying", false)
	end

	task.wait(0.2)

	if self.character then
		self.character:PivotTo(self.seat.CFrame + Vector3.new(0, 3, 0))
	end

	self.occupant = nil
	self.character = nil
	self.occupantMaid:DoCleaning()
end

return module
