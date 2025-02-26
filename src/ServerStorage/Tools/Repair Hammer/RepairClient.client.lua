local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Network"))

local animation = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("HammerSwing")
local animator: Animator, animtrack: AnimationTrack

local player = game.Players.LocalPlayer
local character = player.Character
local mouse = player:GetMouse()
local tool = script.Parent

local holding = false
local equipped = false
local playing = false

local function repair()
	if playing or not equipped then return end

	if not animator then
		animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")
		animtrack = animator:LoadAnimation(animation)
	end

	animtrack:Play()
	playing = true
	task.wait(0.47)

	if mouse.Target and player:DistanceFromCharacter(mouse.Target.Position) <= 10 then
		local model = mouse.Target:FindFirstAncestorWhichIsA("Model")
		if not model then return end
		local payload = {
			eventType = "Repair",
			model = model,
			hitPos = mouse.Hit.Position,
		}
		Network.fireServer(Network.RemoteEvents.BuildEvent, payload)
	end

	task.wait(0.23)
	playing = false

	if holding then
		repair()
	end
end

tool.Activated:Connect(function()
	holding = true
	repair()
end)

tool.Deactivated:Connect(function()
	holding = false
end)

tool.Equipped:Connect(function()
	equipped = true
end)

tool.Unequipped:Connect(function()
	equipped = false
	holding = false
	playing = false
end)