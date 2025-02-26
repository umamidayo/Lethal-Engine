local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundState = require(ReplicatedStorage.Common.States.Game.RoundState)

local roundState = RoundState.state

local highestRound = 0
local highestRoundBoard = workspace.HighestRound
local highestRoundPlayersBoard = workspace.HighestRoundPlayers

local module = {}

function module.updateHighestRoundBoard()
	if roundState.round <= highestRound then
		return
	end

	highestRound = roundState.round

	highestRoundBoard.Part.SurfaceGui.Frame.Count.Text = roundState.round

	for i, v in highestRoundPlayersBoard.Part.SurfaceGui.Frame:GetChildren() do
		if v:IsA("TextLabel") and v.Name ~= "Title" then
			v:Destroy()
		end
	end

	for i, player in Players:GetPlayers() do
		local nameSample = highestRoundPlayersBoard.SampleFolder.PlayerName:Clone()
		nameSample.Text = player.Name
		nameSample.Parent = highestRoundPlayersBoard.Part.SurfaceGui.Frame
	end
end

return module
