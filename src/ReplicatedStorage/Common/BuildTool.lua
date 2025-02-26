local module = {}

local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local CS = game:GetService("CollectionService")
local ReplicatedStorage = game:WaitForChild("ReplicatedStorage")
local RemotesLegacy = ReplicatedStorage:WaitForChild("RemotesLegacy")
local SharedUI = ReplicatedStorage:WaitForChild("UI")
local BuildingUI = SharedUI:WaitForChild("Building")
local Buildables = ReplicatedStorage:WaitForChild("Entities"):WaitForChild("Buildables")
local Animations = ReplicatedStorage:WaitForChild("Animations")
local BuildingEvents = RemotesLegacy:WaitForChild("Building")
local Network = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Network"))
local Build_Event = BuildingEvents.Build
local Destroy_Event = BuildingEvents.Deconstruct

local ShovelSound = SoundService:WaitForChild("Building"):WaitForChild("ShovelSound")
local ShovelUseAnim = Animations.ShovelUseAnim
local animTrack = nil

local Selection = nil
local CanBuild = false
module.Mode = 1
module.GhostModel = nil :: Model
module.BoundBox = nil :: BasePart
local Debounce = tick()

local connection

local Structures = {}
local NonStructures = {}

CS:GetInstanceAddedSignal("Structure"):Connect(function()
	Structures = CS:GetTagged("Structure")
end)

CS:GetInstanceRemovedSignal("Structure"):Connect(function()
	Structures = CS:GetTagged("Structure")
end)

CS:GetInstanceAddedSignal("NonStructure"):Connect(function()
	NonStructures = CS:GetTagged("NonStructure")
end)

CS:GetInstanceRemovedSignal("NonStructure"):Connect(function()
	NonStructures = CS:GetTagged("NonStructure")
end)

function MakeConnections(player: Player, tool: Tool)
	local PlayerGui: PlayerGui = player:WaitForChild("PlayerGui")
	local BuildGui: ScreenGui = PlayerGui:WaitForChild("BuildGui")
	local MainFrame: Frame = BuildGui:WaitForChild("MainFrame")
	local MenuFrame: Frame = MainFrame:WaitForChild("MenuFrame")
	local BuildFrame: Frame = MainFrame:WaitForChild("BuildFrame")
	local SearchFrame: Frame = MainFrame:WaitForChild("SearchFrame")
	local FilterFrame: Frame = MainFrame:WaitForChild("FilterFrame")
	local ContentsFrame: Frame = MenuFrame:WaitForChild("Contents")
	local Mouse = player:GetMouse()
	
	Mouse.Button1Up:Connect(function()
		if not BuildGui.Enabled then return end
		if tick() - Debounce < 1 then return end
		Debounce = tick()
		
		if module.Mode == 1 then
			if CanBuild == false then return end
			if Selection == nil then return end
			
			local newShovelSound = ShovelSound:Clone()
			newShovelSound.Parent = player.Character.PrimaryPart
			newShovelSound:Destroy()
			animTrack = player.Character.Humanoid.Animator:LoadAnimation(ShovelUseAnim)
			animTrack:Play()
			
			local payload = {
				eventType = "Build",
				model = Selection,
				cframe = module.GhostModel.WorldPivot
			}
			Network.fireServer(Network.RemoteEvents.BuildEvent, payload)
		elseif module.Mode == 2 then
			local newShovelSound = ShovelSound:Clone()
			newShovelSound.Parent = player.Character.PrimaryPart
			newShovelSound:Destroy()
			animTrack = player.Character.Humanoid.Animator:LoadAnimation(ShovelUseAnim)
			animTrack:Play()
			
			local payload = {
				eventType = "Destroy",
				model = Mouse.Target:FindFirstAncestorWhichIsA("Model"),
			}
			Network.fireServer(Network.RemoteEvents.BuildEvent, payload)
		end
	end)
	
	UIS.TouchTapInWorld:Connect(function(position: Vector2, processedByUI: boolean)
		if processedByUI then return end
		if not BuildGui.Enabled then return end
		if tick() - Debounce < 1 then return end
		Debounce = tick()
		
		if module.Mode == 1 then
			if not CanBuild then return end
			if not Selection then return end
			
			local newSound = ShovelSound:Clone()
			newSound.Parent = player.Character.PrimaryPart
			newSound:Destroy()
			
			animTrack = player.Character.Humanoid.Animator:LoadAnimation(ShovelUseAnim)
			animTrack:Play()
			
			Build_Event:FireServer(Selection, module.GhostModel.WorldPivot.Position)
		elseif module.Mode == 2 then
			local newSound = ShovelSound:Clone()
			newSound.Parent = player.Character.PrimaryPart
			newSound:Destroy()
			
			animTrack = player.Character.Humanoid.Animator:LoadAnimation(ShovelUseAnim)
			animTrack:Play()
			
			local unitRay = workspace.CurrentCamera:ViewportPointToRay(position.X, position.Y)
			local rayResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 15)
			
			if rayResult then
				Destroy_Event:FireServer(rayResult.Instance)
			end
		end
	end)
	
	local function toggleMode(actionName: string, inputState: Enum.UserInputState, inputObj: InputObject)
		if inputState ~= Enum.UserInputState.Begin then return end
		if module.Mode == 2 then
			module.Mode = 1
			BuildFrame.Mode.Text = "Mode: Build [T]"

			if module.GhostModel then
				module.GhostModel.Parent = workspace
			end
		else
			module.Mode = 2
			BuildFrame.Mode.Text = "Mode: Destroy [T]"

			if module.GhostModel then
				module.GhostModel.Parent = nil
				CanBuild = false
				BuildFrame.Mode.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			end
		end
	end
	
	-- Build Mode / List
	
	BuildFrame.Mode.MouseButton1Click:Connect(function()
		toggleMode(nil, Enum.UserInputState.Begin, nil)
	end)
	
	local function toggleList(actionName: string, inputState: Enum.UserInputState, inputObj: InputObject)
		if inputState ~= Enum.UserInputState.Begin then return end
		if MenuFrame.Visible == false then
			MenuFrame.Visible = true
			SearchFrame.Visible = true
			FilterFrame.Visible = true
			BuildFrame.ToggleMenu.Text = "Hide List [R]"
		else
			MenuFrame.Visible = false
			SearchFrame.Visible = false
			FilterFrame.Visible = false
			BuildFrame.ToggleMenu.Text = "Show List [R]"
		end
	end
	
	BuildFrame.ToggleMenu.MouseButton1Click:Connect(function()
		toggleList(nil, Enum.UserInputState.Begin, nil)
	end)
	
	-- Search Frame
	
	SearchFrame.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		ContentsFrame.CanvasPosition = Vector2.new(0, 0)
		if SearchFrame.TextBox.Text == "" then
			for i,v in pairs(ContentsFrame:GetChildren()) do
				if v:IsA("TextButton") then
					v.Visible = true
				end
			end
		else
			for i,v in pairs(ContentsFrame:GetChildren()) do
				if v:IsA("TextButton") then
					if string.find(string.lower(v.Text), string.lower(SearchFrame.TextBox.Text)) then
						v.Visible = true
					else
						v.Visible = false
					end
				end
			end
		end
	end)
	
	-- Filtering
	
	local function clearBuildList()
		for i,v in pairs(ContentsFrame:GetChildren()) do
			if v:IsA("TextButton") then
				v.Visible = false
			end
		end
	end

	local function populateBuildList(filterType: string)
		local directory
		local contents = {}
		
		if filterType then
			directory = Buildables:FindFirstChild(filterType)
		end
		
		if not directory then
			for _,v in Buildables.Utility:GetChildren() do
				table.insert(contents, v)
			end
			
			for _,v in Buildables.Traps:GetChildren() do
				table.insert(contents, v)
			end
			
			for _,v in Buildables.Structure:GetChildren() do
				table.insert(contents, v)
			end

			for _,v in Buildables.Wiremod:GetChildren() do
				table.insert(contents, v)
			end
		else
			contents = directory:GetChildren()
		end
		
		for i,model: Model in contents do
			if not model:IsA("Model") then continue end
			local item: TextButton = ContentsFrame:FindFirstChild(model.Name)
			
			if item then
				item.Visible = true
			else
				item = BuildingUI.Item:Clone()
				item.Name = model.Name
				item.Text = model.Name .. ": " .. model:GetAttribute("Cost") .. " MATS"
				item.Parent = ContentsFrame

				item.MouseButton1Click:Connect(function()
					if Selection == model then return end

					if module.GhostModel then
						module.GhostModel:Destroy()
					end

					if connection then
						connection:Disconnect()
					end

					Selection = model

					CreateGhost(player, model)
					module.Mode = 1
					BuildFrame.Mode.Text = "Mode: Build [T]"
				end)
			end
		end
	end
	
	for i,button: TextButton in FilterFrame:GetChildren() do
		if button.ClassName ~= "TextButton" then continue end
		
		button.MouseButton1Click:Connect(function()
			clearBuildList()
			populateBuildList(button.Name)
		end)
	end
	
	-- Clear contents
	clearBuildList()
	
	-- Update contents frame and connection
	
	populateBuildList()
	
	tool.Equipped:Connect(function()
		CAS:BindAction("ToggleMode", toggleMode, false, Enum.KeyCode.T)
		CAS:BindAction("ToggleList", toggleList, false, Enum.KeyCode.R)
	end)
	
	tool.Unequipped:Connect(function()
		CAS:UnbindAction("ToggleList")
		CAS:UnbindAction("ToggleMode")
	end)
	
	player.Character.Humanoid.Died:Connect(function()
		if connection then
			connection:Disconnect()
		end
		
		if module.GhostModel then
			module.GhostModel:Destroy()
			module.GhostModel = nil
		end
		
		CAS:UnbindAction("ToggleList")
		CAS:UnbindAction("ToggleMode")
	end)
end

function CreateGhost(player, BuildModel)
	local PlayerGui = player:WaitForChild("PlayerGui")
	local BuildGui = PlayerGui:WaitForChild("BuildGui")
	local MainFrame = BuildGui:WaitForChild("MainFrame")
	local BuildFrame = MainFrame:WaitForChild("BuildFrame")
	
	local character = player.Character
	local rootpart = character:FindFirstChild("HumanoidRootPart")
	local mouse = player:GetMouse()
	local atPos = nil
	local toPos = nil
	
	local raycastResults
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true
	
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	
	module.GhostModel = BuildModel:Clone()
	local orientation: CFrame, boxSize: Vector3 = module.GhostModel:GetBoundingBox()
	local modelSize = module.GhostModel:GetExtentsSize()
	module.GhostModel.Parent = workspace
	
	for i,v in module.GhostModel:GetDescendants() do
		if not v:IsA("BasePart") then continue end
		v.CanCollide = false
		v.Transparency = 0.5
	end
	
	if module.BoundBox ~= nil then
		module.BoundBox:Destroy()
	end
	
	module.BoundBox = Instance.new("Part")
	module.BoundBox.Anchored = true
	module.BoundBox.Color = Color3.fromRGB(133, 255, 111)
	module.BoundBox.Material = Enum.Material.ForceField
	module.BoundBox.CanCollide = false
	module.BoundBox.Transparency = 1
	
	module.BoundBox.CFrame = orientation + Vector3.yAxis
	module.BoundBox.Size = modelSize
	module.BoundBox.Parent = module.GhostModel
	
	local partCountTolerance = 2

	if Buildables.Traps:FindFirstChild(module.GhostModel.Name) then
		partCountTolerance = 0
	elseif Buildables.Structure:FindFirstChild(module.GhostModel.Name) then
		partCountTolerance = 4
	end
	
	local function CanBuildHere(bool: boolean)
		CanBuild = bool
		
		if CanBuild then
			BuildFrame.Mode.BackgroundColor3 = Color3.fromRGB(43, 103, 39)
		else
			BuildFrame.Mode.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		end
	end
	
	local modelUnderneathRaycast: Model = nil
	
	connection = RunService.Heartbeat:Connect(function()
		if BuildGui.Enabled == false or module.GhostModel.Parent == nil then
			CanBuildHere(false)
			return
		end

		rayParams.FilterDescendantsInstances = {module.GhostModel, NonStructures, workspace.Landscape, workspace.Pings, workspace.DeadZombies, workspace.TrussParts, player.Character:GetDescendants(), workspace.Characters}
		raycastResults = workspace:Raycast(rootpart.Position + rootpart.CFrame.LookVector * 4 + Vector3.new(0, 1, 0), -Vector3.yAxis * 8, rayParams)
		
		if raycastResults then
			module.GhostModel:PivotTo(CFrame.new(raycastResults.Position))
			atPos = Vector3.new(module.GhostModel.WorldPivot.Position.X, raycastResults.Position.Y, module.GhostModel.WorldPivot.Position.Z)
			toPos = Vector3.new(rootpart.Position.X, raycastResults.Position.Y, rootpart.Position.Z)
			module.GhostModel:PivotTo(CFrame.lookAt(atPos, toPos))
			
			if BuildModel.Parent == Buildables.Structure then
				modelUnderneathRaycast = raycastResults.Instance:FindFirstAncestorWhichIsA("Model")
				if modelUnderneathRaycast and modelUnderneathRaycast:HasTag("Structure") then
					return CanBuildHere(false)
				end
			end
		else
			module.GhostModel:PivotTo(CFrame.new(rootpart.Position + rootpart.CFrame.LookVector * 4))
			atPos = Vector3.new(module.GhostModel.WorldPivot.Position.X, rootpart.Position.Y - 3, module.GhostModel.WorldPivot.Position.Z)
			toPos = Vector3.new(rootpart.Position.X, rootpart.Position.Y - 3, rootpart.Position.Z)
			module.GhostModel:PivotTo(CFrame.lookAt(atPos, toPos))
		end
		
		-- Get model details
		
		orientation, boxSize = module.GhostModel:GetBoundingBox()
		
		-- Raycast check
		
		local RaycastCheck = true
		
		raycastResults = workspace:Raycast(orientation.Position, -Vector3.yAxis * boxSize.Y, rayParams)
		
		if raycastResults then
			if raycastResults.Instance.Parent == workspace.Forcefields then
				RaycastCheck = false
			end
			
			if raycastResults.Distance > boxSize.Y then
				RaycastCheck = false
			end
		else
			RaycastCheck = false
		end
		
		if not RaycastCheck then
			return CanBuildHere(false)
		end
		
		-- Terrain check

		module.BoundBox.CFrame = orientation + Vector3.yAxis
		local parts = module.BoundBox:GetTouchingParts()
		local intersectingTerrain = false

		for i,part in parts do
			if part:IsA("Terrain") then
				intersectingTerrain = true
				break
			end
		end

		if intersectingTerrain then
			return CanBuildHere(false)
		end
		
		-- On WorldPivot
		
		raycastResults = workspace:Raycast(module.GhostModel.WorldPivot.Position + Vector3.new(0, 0.2, 0), Vector3.new(0, -3, 0), rayParams)

		if raycastResults then
			if raycastResults.Instance.Parent == workspace.Forcefields then
				RaycastCheck = false
			end
			
			if BuildModel.Parent == Buildables.Structure then
				modelUnderneathRaycast = raycastResults.Instance:FindFirstAncestorWhichIsA("Model")
				if modelUnderneathRaycast and modelUnderneathRaycast:HasTag("Structure") then
					return CanBuildHere(false)
				end
			end
		else
			RaycastCheck = false
		end
		
		if not RaycastCheck then
			return CanBuildHere(false)
		end
		
		-- Intersect check
		
		overlapParams.FilterDescendantsInstances = {module.GhostModel, workspace.Landscape, workspace.Pings, workspace.Buildables.Server, workspace.DeadZombies, workspace.Map, workspace.TrussParts}
		parts = workspace:GetPartBoundsInBox(orientation, boxSize, overlapParams)
		
		if #parts > partCountTolerance then
			return CanBuildHere(false)
		end
		
		-- Good
		
		CanBuildHere(true)
	end)
end

function module.Initialize(player: Player, tool: Tool)
	MakeConnections(player, tool)
end

return module
