local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LethalEngineShared = ReplicatedStorage:WaitForChild("LethalEngine")

local ClientState = require(LethalEngineShared.States.ClientState)
local Keybinds = require(LethalEngineShared.Keybinds)
local QuickNet = require(LethalEngineShared.Utility.QuickNet)
local Stances = require(LethalEngineShared.Config.Stances)
local Spring = require(LethalEngineShared.Utility.Spring)

local StanceEvent: RemoteFunction = QuickNet.getSignal("Stances", "RemoteFunction")

local offsetSpring = nil

local Movement = {}

local function setWalkSpeed(humanoid: Humanoid, speed: number)
	humanoid.WalkSpeed = speed
end

local function setCameraOffset(humanoid: Humanoid, offset: Vector3)
	offsetSpring:Reset(humanoid.CameraOffset)
	offsetSpring:SetTarget(offset)
	offsetSpring:Hook(function(vector3)
		humanoid.CameraOffset = vector3
	end)
end

local function setStance(newStance: string)
	return ClientState:setValue("Movement", "Stance", newStance)
end

local function setupCameraOffsetSpring(humanoid: Humanoid)
	if offsetSpring then
		offsetSpring:Destroy()
	end

	offsetSpring = Spring.new({
		initial = humanoid.CameraOffset,
		speed = 15,
		damping = 1.5,
		threshold = 0.01,
	})
end

local function updateHumanoid(humanoid: Humanoid)
	local stance = ClientState:getValue("Movement", "Stance")
	local stanceConfig = Stances[stance]
	if not stanceConfig then
		return
	end

	local sprinting = ClientState:getValue("Movement", "Sprinting")
	local walkSpeed = sprinting and stanceConfig.SprintSpeed or stanceConfig.Walkspeed

	setWalkSpeed(humanoid, walkSpeed)
	setCameraOffset(humanoid, stanceConfig.CameraOffset)
end

local function invokeStanceEvent()
	local stance = ClientState:getValue("Movement", "Stance")
	return StanceEvent:InvokeServer(stance)
end

function Movement.connectCharacter(character: Model)
	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	setWalkSpeed(humanoid, Stances.Standing.Walkspeed)
	setupCameraOffsetSpring(humanoid)

	humanoid.Changed:Connect(function(property)
		if property == "Sit" then
			ClientState:setValue("Movement", "Sitting", humanoid.Sit)
		end
	end)

	Keybinds.bind(Enum.KeyCode.LeftShift, "Sprint", {
		began = function()
			local stance = ClientState:getValue("Movement", "Stance")
			if stance == "Prone" then
				return
			end

			setStance("Standing")

			local success = invokeStanceEvent()
			if success then
				ClientState:setValue("Movement", "Sprinting", true)
				updateHumanoid(humanoid)
			end
		end,
		ended = function()
			local stance = ClientState:getValue("Movement", "Stance")
			if stance ~= "Prone" then
				ClientState:setValue("Movement", "Sprinting", false)
				updateHumanoid(humanoid)
			end
		end,
	})

	Keybinds.bind(Enum.KeyCode.C, "StanceDown", {
		began = function()
			local stance = ClientState:getValue("Movement", "Stance")
			setStance(stance == "Standing" and "Crouching" or "Prone")

			local success = invokeStanceEvent()
			if success then
				updateHumanoid(humanoid)
			end
		end,
	})

	Keybinds.bind(Enum.KeyCode.X, "StanceUp", {
		began = function()
			local stance = ClientState:getValue("Movement", "Stance")
			setStance(stance == "Prone" and "Crouching" or "Standing")

			local success = invokeStanceEvent()
			if success then
				updateHumanoid(humanoid)
			end
		end,
	})
end

return Movement
