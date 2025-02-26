local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local LethalEngine = {}

function LethalEngine.setupCharacter(character: Model)
	-- TODO: Setup character controls
end

function LethalEngine.init()
	if LocalPlayer.Character then
		LethalEngine.setupCharacter(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(LethalEngine.setupCharacter)
end

return LethalEngine
