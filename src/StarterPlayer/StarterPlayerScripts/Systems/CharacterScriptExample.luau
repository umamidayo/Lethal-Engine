-- Example of how a character system works.

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local CharacterExample = {}

function CharacterExample.onCharacterAdded(character: Model)
	print("CharacterExample.onCharacterAdded", character)
end

function CharacterExample.init()
	if LocalPlayer.Character then
		CharacterExample.onCharacterAdded(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(CharacterExample.onCharacterAdded)
end

return CharacterExample
