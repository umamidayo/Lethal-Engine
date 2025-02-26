
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToolLib = ReplicatedStorage:WaitForChild("Common"):WaitForChild("ToolLib")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")

local Controller = nil
local Tools = {}

local function cleanup()
	if Controller and Controller.Unequip then
		Controller.Unequip()
	end

	Controller = nil
end

local function onToolEquipped(Tool: Tool)
	local toolFolder = ToolLib:FindFirstChild(Tool.Name)
	if not toolFolder then
		return
	end

	Controller = require(toolFolder:WaitForChild("ToolController"))
	Controller.Equip(Tool)
end

local function setupCharacter()
	Character.ChildAdded:Connect(function(Tool)
		if Tool:IsA("Tool") then
			cleanup()
			onToolEquipped(Tool)
		end
	end)

	Character.ChildRemoved:Connect(function(Tool)
		if Tool:IsA("Tool") then
			cleanup()
		end
	end)

	Humanoid.Died:Connect(function()
		cleanup()
	end)

	Character.Destroying:Connect(function()
		cleanup()
	end)
end

setupCharacter()

print("Tools initialized")

return Tools
