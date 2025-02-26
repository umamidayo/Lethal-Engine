local module = {}

function module.init()
	local Debris = game:GetService("Debris")
	local SoundService = game:GetService("SoundService")
	local TweenService = game:GetService("TweenService")

	local player = game.Players.LocalPlayer
	local camera = workspace.CurrentCamera
	local character = player.Character or player.CharacterAdded:Wait()

	local deathTweenInfo

	character:WaitForChild("Humanoid").Died:Connect(function()
		SoundService:WaitForChild("DaySound"):WaitForChild("Death"):Play()
		
		if player.Character and player.Character:FindFirstChild("Head") then
			local headCFrame: CFrame = character.Head.CFrame
			
			player.CameraMinZoomDistance = 10
			repeat task.wait() until player:DistanceFromCharacter(camera.CFrame.Position) > 6
			player.CameraMinZoomDistance = 0
			camera.CameraType = Enum.CameraType.Scriptable
			
			deathTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			TweenService:Create(camera, deathTweenInfo, {
				CFrame = CFrame.new(headCFrame.Position + (headCFrame.UpVector * 5) + (headCFrame.LookVector * -10), headCFrame.Position)
			}):Play()
			
			task.wait(0.5)
			
			deathTweenInfo = TweenInfo.new(5.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			TweenService:Create(camera, deathTweenInfo, {
				CFrame = CFrame.new(headCFrame.Position + (headCFrame.UpVector * 30) + (headCFrame.LookVector * -50), headCFrame.Position)
			}):Play()
		end
	end)
end

return module
