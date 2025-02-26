local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LethalEngineShared = ReplicatedStorage:WaitForChild("LethalEngine")

local QuickNet = require(LethalEngineShared.Utility.QuickNet)
local Movement = require(LethalEngineShared.Movement)
local Keybinds = require(LethalEngineShared.Keybinds)

local LocalPlayer = Players.LocalPlayer

local LethalEngineClient = {}

function LethalEngineClient.onCharacterAdded(character: Model)
	Movement.connectCharacter(character)
end

function LethalEngineClient.init()
	QuickNet.init()
	Keybinds.init()

	if LocalPlayer.Character then
		LethalEngineClient.onCharacterAdded(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(LethalEngineClient.onCharacterAdded)
end

return LethalEngineClient
