local module = {}

function module.init()
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local LegController = require(ReplicatedStorage.Common.LegController)
	local CharacterTable = {}

	local function OnCharacterAdded(Character : Model)
		if table.find(CharacterTable, Character.Name) then return end
		CharacterTable[Character.Name] = {}
		task.spawn(function()
			CharacterTable[Character.Name].LegController = LegController.new(Character, {
				ikEnabled = true,
				ikExclude = {},
				maxIkVelocity = 1.5,

				onStates = {
					Enum.HumanoidStateType.Running
				},
				activationVelocity = 1.5,
				maxRootAngle = 25,
				maxAngle = 32.5,
				interploationSpeed = {
					highVelocityPoint = 2.5, --Anything less than this will interpolation slowly
					Speed = 0.1,
				}
			})
		end)

		Character.Destroying:Connect(function()
			if CharacterTable[Character.Name].LegController then CharacterTable[Character.Name].LegController:Destroy() end
			CharacterTable[Character.Name] = nil
		end)
	end

	Players.PlayerAdded:Connect(function(Player)
		Player.CharacterAdded:Connect(OnCharacterAdded)
	end)

	Players.LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

	if Players.LocalPlayer.Character then
		OnCharacterAdded(Players.LocalPlayer.Character)
	end

	for _, Player in pairs(Players:GetPlayers()) do
		if (Player ~= Players.LocalPlayer) then
			OnCharacterAdded(Player.Character)
			Player.CharacterAdded:Connect(OnCharacterAdded)
		end
	end
end

return module