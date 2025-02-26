local ReplicatedStorage = game:GetService("ReplicatedStorage")
local spawnAI_event = ReplicatedStorage:WaitForChild("RemotesLegacy"):WaitForChild("SpawnAI")
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local UserInputService = game:GetService("UserInputService")
local tool: Tool = script.Parent
local keyConnection: RBXScriptConnection
local mouse = game.Players.LocalPlayer:GetMouse()
local zombieTypes = {"Swarmer", "Crawler", "Stalker", "Hopper", "Predator", "Spitter", "Abomination"}
local zombieTypeIndex = 1

tool.Activated:Connect(function()
	spawnAI_event:FireServer(mouse.Hit.Position, zombieTypes[zombieTypeIndex])
end)

tool.Equipped:Connect(function()
	Notifier.new(`Zombie type: {zombieTypes[zombieTypeIndex]}`)
	Notifier.new("Press T to change the zombie type")

	keyConnection = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.T then
			zombieTypeIndex = zombieTypeIndex + 1
			if zombieTypeIndex > #zombieTypes then
				zombieTypeIndex = 1
			end
			Notifier.new(`Zombie type: {zombieTypes[zombieTypeIndex]}`)
		end
	end)
end)

tool.Unequipped:Connect(function()
	keyConnection:Disconnect()
end)