local module = {}

function module.init()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local camera = workspace.CurrentCamera
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local Z = 0
	local BOB_STRENGTH = 1.2
	local DAMP = character.Humanoid.WalkSpeed / BOB_STRENGTH
	local PI = 3.1415926
	local TICK = PI / 2
	local running = false
	local strafing = false
	if module.runConnection then
		module.runConnection:Disconnect()
	end

	character.Humanoid.Strafing:Connect(function(p1)
		strafing = p1
	end)

	character.Humanoid.Jumping:Connect(function()
		running = false
	end)

	character.Humanoid.Swimming:Connect(function()
		running = false
	end)

	character.Humanoid.Running:Connect(function(p2)
		if p2 > 0.1 then
			running = true
			return
		end
		running = false
	end)

	character.Humanoid.Died:Connect(function()
		running = false
		if module.runConnection then
			module.runConnection:Disconnect()
		end
	end)

	local function mix(p3, p4, p5)
		return p4 + (p3 - p4) * p5
	end

	module.runConnection = RunService.RenderStepped:Connect(function(deltaTime)
		if not character or character ~= localPlayer.Character or not character:FindFirstChild("Head") then
			module.runConnection:Disconnect()
			return
		end

		Z = 0

		if running == true and strafing == false then
			TICK = TICK + character.Humanoid.WalkSpeed / 102 * (30 * deltaTime)
		else
			if TICK > 0 and TICK < PI / 2 then
				TICK = mix(TICK, PI / 2, 0.9)
			end
			if PI / 2 < TICK and TICK < PI then
				TICK = mix(TICK, PI / 2, 0.9)
			end
			if PI < TICK and TICK < PI * 1.5 then
				TICK = mix(TICK, PI * 1.5, 0.9)
			end
			if PI * 1.5 < TICK and TICK < PI * 2 then
				TICK = mix(TICK, PI * 1.5, 0.9)
			end
		end
		if PI * 2 <= TICK then
			TICK = 0
		end
		camera.CFrame *= CFrame.new(math.cos(TICK) / DAMP, math.sin(TICK * 2) / (DAMP * 2), Z) * CFrame.Angles(
			0,
			0,
			math.sin(TICK - PI * 1.5) / (DAMP * 20)
		)
	end)

	-- while true do
	-- local step = RunService.RenderStepped:Wait()
	-- local fps = (camera.CFrame.p - character.Head.Position).Magnitude
	-- if fps < 0.52 then
	-- Z = 0
	-- else
	-- Z = 0
	-- end
	-- if running == true and strafing == false then
	-- TICK = TICK + character.Humanoid.WalkSpeed / 102 * (30*step)
	-- else
	-- if TICK > 0 and TICK < PI / 2 then
	-- TICK = mix(TICK, PI / 2, 0.9)
	-- end
	-- if PI / 2 < TICK and TICK < PI then
	-- TICK = mix(TICK, PI / 2, 0.9)
	-- end
	-- if PI < TICK and TICK < PI * 1.5 then
	-- TICK = mix(TICK, PI * 1.5, 0.9)
	-- end
	-- if PI * 1.5 < TICK and TICK < PI * 2 then
	-- TICK = mix(TICK, PI * 1.5, 0.9)
	-- end
	-- end
	-- if PI * 2 <= TICK then
	-- TICK = 0
	-- end
	-- camera.CFrame *= CFrame.new(math.cos(TICK) / DAMP, math.sin(TICK * 2) / (DAMP * 2), Z) * CFrame.Angles(0, 0, math.sin(TICK - PI * 1.5) / (DAMP * 20))
	-- end
end

return module
