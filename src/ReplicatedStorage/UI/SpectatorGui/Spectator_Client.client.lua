--disable
local UIS = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Custom
camera.FieldOfView = 70

local target: Player = nil

local survivors: {Player} = {}
local index = 1

function populateList()
	survivors = {}

	for i,v in ipairs(game.Players:GetPlayers()) do
		if v.Team == game.Teams.Survivor or v.Team == game.Teams.Spawn then
			if v.Character then
				table.insert(survivors, v)
			end
		end
	end
	
	if #survivors == 0 then
		for i,v in ipairs(game.Players:GetPlayers()) do
			if v.Character then
				table.insert(survivors, v)
			end
		end
	end
end

function updateCamera()
	camera.CameraType = Enum.CameraType.Custom
	if target then
		camera.CameraSubject = target.Character.Humanoid
	else
		camera.CameraSubject = workspace.SpawnLocation
	end
end

function nextTarget()
	populateList()
	
	index = index % #survivors + 1
	target = survivors[index]
	
	if target then
		script.Parent.Frame.PlayerName.Text = target.DisplayName
	end
	
	updateCamera()
end

function previousTarget()
	populateList()

	if index > 1 then
		index -= 1
	else
		index = #survivors
	end
	
	target = survivors[index]
	
	if target then
		script.Parent.Frame.PlayerName.Text = target.DisplayName
	end
	
	updateCamera()
end

script.Parent.Frame.Next.MouseButton1Click:Connect(function()
	nextTarget()
end)

script.Parent.Frame.Previous.MouseButton1Click:Connect(function()
	previousTarget()
end)

UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.A then
			previousTarget()
		elseif input.KeyCode == Enum.KeyCode.D then
			nextTarget()
		end
	elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
		if input.KeyCode == Enum.KeyCode.DPadLeft then
			previousTarget()
		elseif input.KeyCode == Enum.KeyCode.DPadRight then
			nextTarget()
		end
	end
end)

nextTarget()