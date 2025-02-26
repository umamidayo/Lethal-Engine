local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type NpcProperties = {
	npcName: string,
	canAggro: boolean,
	canRoam: boolean,
	canTalk: boolean,
}

local LocalPlayer = Players.LocalPlayer
local Signal = require(ReplicatedStorage.Common.Libraries.Signal)
local Animations = require(ReplicatedStorage.Common.Shared.Universal.Animations)
local DialogController = require(ReplicatedStorage.Client.Controllers.DialogController)
local ServerList = require(LocalPlayer.PlayerScripts.Contents.Lobby.Interface.ServerList)

local Components = ReplicatedStorage.UI
local NpcTag = Components.NpcTag

local PlayerGui = LocalPlayer.PlayerGui or LocalPlayer:WaitForChild("PlayerGui")
local StoreGui: ScreenGui = PlayerGui:WaitForChild("StoreGui")
local PerksGui: ScreenGui = PlayerGui:WaitForChild("PlayerClassGui")
local DailyGui: ScreenGui = PlayerGui:WaitForChild("DailyGui")

local NpcClass = {
	Npcs = {},
}
NpcClass.__index = NpcClass

function NpcClass.new(npc: Model, npcModule)
	local npcProperties: NpcProperties = npcModule.properties
	local npcDialogs = npcModule.dialogs
	local choices = npcModule.choices

	local self = setmetatable({}, NpcClass)
	self.character = npc
	self.npcName = npcProperties.npcName
	self.title = npcProperties.title
	self.canAggro = npcProperties.canAggro
	self.canRoam = npcProperties.canRoam
	self.canTalk = npcProperties.canTalk
	self.npcModule = npcModule
	self.dialogs = nil
	self.choices = nil
	self.dialogIndices = {}
	self.state = "idle"
	self.animations = Animations.new(npc)
	self.talking = false
	self.event = Signal.new()
	self.cancelThread = nil

	local npcTag = NpcTag:Clone()
	npcTag.Frame.DisplayName.Text = self.npcName
	npcTag.Frame.Title.Text = self.title
	npcTag.Parent = self.character.Head
	npcTag.Enabled = true

	if self.canTalk and npcDialogs then
		self.dialogs = npcDialogs
		self.choices = choices
		for dialogType, _ in self.dialogs do
			self.dialogIndices[dialogType] = 1
		end

		self:togglePrompt()
	end

	self.animations:loadAnimations("idle")
	self.animations:loadAnimations({ "wave", "point" }, Enum.AnimationPriority.Action)
	self.animations:playAnimation("idle")

	self:connectEvent()

	NpcClass.Npcs[self.npcName] = self

	return self
end

function NpcClass:destroy()
	self.animations:destroy()
	if self.character then
		self.character:Destroy()
	end
	setmetatable(self, nil)
end

function NpcClass:cycleIndex(dialogType: string)
	local dialogCount = #self.dialogs[dialogType]
	self.dialogIndices[dialogType] = (self.dialogIndices[dialogType] % dialogCount) + 1
end

function NpcClass:connectEvent()
	self.event:Connect(function(eventType: string)
		local dialogTime = 0
		if self.dialogs[eventType] then
			dialogTime = self:updateDialog(eventType)
		end

		self.cancelThread = task.delay(dialogTime, function()
			if eventType == "shop" then
				StoreGui.Enabled = true
				self.talking = false
			elseif eventType == "serverlist" then
				ServerList.updateServerList(0.2)
				self.talking = false
			elseif eventType == "perks" then
				PerksGui.Enabled = true
				self.talking = false
			elseif eventType == "daily" then
				DailyGui.Enabled = true
				self.talking = false
			end
		end)
	end)
end

function NpcClass:updateDialog(dialogType: string)
	local dialog, dialogIndex =
		DialogController.getOrderedDialog(self.dialogIndices[dialogType], self.dialogs[dialogType])
	self.dialogIndices[dialogType] = dialogIndex
	local dialogTime = DialogController.updateDialog(dialog, self.choices[dialogType])
	return dialogTime
end

function NpcClass:setDialog(dialogType: string)
	local dialog, dialogIndex =
		DialogController.getOrderedDialog(self.dialogIndices[dialogType], self.dialogs[dialogType])
	self.dialogIndices[dialogType] = dialogIndex
	DialogController.openDialog(self, self.npcName, dialog, self.choices[dialogType])
end

function NpcClass:togglePrompt()
	self.npcModule.setNpcObject(self)

	if not self.prompt then
		local prompt = Instance.new("ProximityPrompt")
		prompt.RequiresLineOfSight = false
		prompt.MaxActivationDistance = 8
		prompt.ActionText = `Talk to {self.npcName}`
		prompt.HoldDuration = 0.5
		prompt.KeyboardKeyCode = Enum.KeyCode.F
		prompt.Parent = self.character.PrimaryPart
		self.prompt = prompt
	end

	self.prompt.Triggered:Connect(function(player)
		self.talking = true
		self.prompt.Enabled = false
		self.animations:stopAnimation("idle")
		local waveTrack = self.animations:playAnimation("wave")
		if waveTrack then
			waveTrack.Stopped:Once(function()
				self.animations:playAnimation("idle")
			end)
		end

		self:setDialog("intro")

		local distance
		while self.talking and task.wait(0.1) do
			distance = player:DistanceFromCharacter(self.character.PrimaryPart.Position)
			if distance > 8 then
				break
			end
		end

		DialogController.toggle(false)
		self.prompt.Enabled = true
		self.talking = false
		if self.cancelThread then
			task.cancel(self.cancelThread)
		end
	end)
end

return NpcClass
