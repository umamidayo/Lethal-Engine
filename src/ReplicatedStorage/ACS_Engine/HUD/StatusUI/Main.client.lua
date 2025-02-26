repeat task.wait() until game.Players.LocalPlayer.Character

local player = game.Players.LocalPlayer
local interactionmouse = script.Parent.InteractionMouse
local mouse = player:GetMouse()
mouse.TargetFilter = workspace.CurrentCamera
local elapsed = 0

game:GetService("RunService").Heartbeat:Connect(function(dt)
	elapsed += dt
	if elapsed < 0.1 then return end
	elapsed = 0

	if mouse.Target then
		local model = mouse.Target:FindFirstAncestorWhichIsA("Model")

		if model then
			local playera = game.Players:GetPlayerFromCharacter(model)

			if playera and player:DistanceFromCharacter(model.WorldPivot.Position) <= 100 then
				interactionmouse.Fundo.Username.Text = playera.DisplayName
				interactionmouse.Fundo.Visible = true
			else
				interactionmouse.Fundo.Visible = false
			end
		else
			interactionmouse.Fundo.Visible = false
		end
	else
		interactionmouse.Fundo.Visible = false
	end
end)

local function onMouseMove()
	local positionX = mouse.X
	local positionY = mouse.Y
	interactionmouse.Position = UDim2.new(0,positionX,0,positionY)
end

mouse.Move:Connect(onMouseMove)