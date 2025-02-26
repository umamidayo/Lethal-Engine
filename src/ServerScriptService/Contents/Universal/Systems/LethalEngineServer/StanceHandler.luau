local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LethalEngineShared = ReplicatedStorage.LethalEngine

local QuickNet = require(LethalEngineShared.Utility.QuickNet)
local Stances = require(LethalEngineShared.Config.Stances)
local Spring = require(LethalEngineShared.Utility.Spring)

local StanceEvent: RemoteFunction = QuickNet.getSignal("Stances", "RemoteFunction")

local playerJointSprings = {}

local StanceHandler = {}

function StanceHandler.animateStance(player: Player, stance: string)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		return
	end

	local stanceConfig = Stances[stance]
	if not stanceConfig then
		return
	end

	for jointName, jointCframe in stanceConfig.Joints do
		local joint: Motor6D = character:FindFirstChild(jointName, true)
		if not joint then
			continue
		end

		local spring = playerJointSprings[player][jointName]
		if not spring then
			continue
		end

		spring:Reset(joint.C1)
		spring:SetTarget(jointCframe)
		spring:Hook(function(cframe)
			joint.C1 = cframe
		end)
	end
end

function StanceHandler.setupPlayer(player: Player)
	local character = player.Character or player.CharacterAdded:Wait()

	playerJointSprings[player] = {}
	local joints = Stances.Standing.Joints
	for jointName, _ in joints do
		local joint: Motor6D = character:FindFirstChild(jointName, true)
		if not joint then
			continue
		end

		playerJointSprings[player][jointName] = Spring.new({
			initial = joint.C1,
			speed = 15,
			damping = 1.5,
			threshold = 0.01,
		})
	end
end

function StanceHandler.init()
	StanceEvent.OnServerInvoke = function(player, stance: string)
		StanceHandler.animateStance(player, stance)
		return true
	end

	for _, player in Players:GetPlayers() do
		StanceHandler.setupPlayer(player)
	end

	Players.PlayerAdded:Connect(function(player)
		StanceHandler.setupPlayer(player)

		player.CharacterAdded:Connect(function()
			StanceHandler.setupPlayer(player)
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		for _, spring in playerJointSprings[player] do
			if spring.Destroy then
				spring:Destroy()
			end
		end

		playerJointSprings[player] = nil
	end)
end

return StanceHandler
