local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SatchelManager = {}

function SatchelManager.init()
	ReplicatedStorage.RemotesLegacy.DropTool.OnServerEvent:Connect(function(player, tool: Tool)
		if not player or not tool then
			return
		end

		if tool.Parent == player.Backpack then
			tool.Handle.CanCollide = true
			tool.Parent = workspace
			task.wait()
			local Character = player.Character
			if Character then
				tool:MoveTo(Character.PrimaryPart.Position + (Character.PrimaryPart.CFrame.LookVector * 5))
			end
		end
	end)
end

return SatchelManager
