local ReplicatedStorage = game:WaitForChild("ReplicatedStorage")
local SharedUI = ReplicatedStorage:WaitForChild("UI")
local RunService = game:GetService("RunService")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")

local Tool = script.Parent
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid: Humanoid = character:WaitForChild("Humanoid")

local StorageGui = SharedUI:WaitForChild("Building"):WaitForChild("BuildGui")
local BuildModule = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("BuildTool"))
local BuildGui = nil
local shiftlocked = false

local function shiftLock(active) --Toggle shift.lock function
	local hum = player.Character:WaitForChild("Humanoid")
	local root = player.Character:WaitForChild("HumanoidRootPart")
	
	if active == nil then
		shiftlocked = not shiftlocked
		
		if shiftlocked then
			hum.AutoRotate = false

			RunService:BindToRenderStep("ShiftLock", Enum.RenderPriority.Character.Value, function()
				UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
				local _, y = workspace.CurrentCamera.CFrame.Rotation:ToEulerAnglesYXZ()
				root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0)
			end) 
		else
			hum.AutoRotate = true
			RunService:UnbindFromRenderStep("ShiftLock")
			UIS.MouseBehavior = Enum.MouseBehavior.Default
		end
	else
		if active then
			hum.AutoRotate = false
			RunService:BindToRenderStep("ShiftLock", Enum.RenderPriority.Character.Value, function()
				UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
				local _, y = workspace.CurrentCamera.CFrame.Rotation:ToEulerAnglesYXZ()
				root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0)
			end) 
		else
			hum.AutoRotate = true
			RunService:UnbindFromRenderStep("ShiftLock")
			UIS.MouseBehavior = Enum.MouseBehavior.Default
		end
	end
end

humanoid.Died:Connect(function()
	humanoid.AutoRotate = true
	RunService:UnbindFromRenderStep("ShiftLock")
	UIS.MouseBehavior = Enum.MouseBehavior.Default
end)

player.CharacterRemoving:Connect(function(character)
	humanoid.AutoRotate = true
	RunService:UnbindFromRenderStep("ShiftLock")
	UIS.MouseBehavior = Enum.MouseBehavior.Default
end)

Tool.Equipped:Once(function()
	BuildModule.Initialize(player, Tool)
end)

Tool.Equipped:Connect(function()
	if shiftlocked then
		shiftLock(shiftlocked)
	end
	
	if BuildModule.GhostModel and BuildModule.Mode == 1 then
		BuildModule.GhostModel.Parent = workspace
	end
	
	if BuildGui then
		BuildGui.Enabled = true
	else
		BuildGui = StorageGui:Clone()
		BuildGui.Parent = player:WaitForChild("PlayerGui")
	end
end)

Tool.Unequipped:Connect(function()
	shiftLock(false)
	
	if BuildModule.GhostModel then
		BuildModule.GhostModel.Parent = nil
	end
	
	if BuildGui then
		BuildGui.Enabled = false
	end
end)

UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if not BuildGui then return end
	if not BuildGui.Enabled then return end
	
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.LeftControl then
			shiftLock()
		end
	end
end)