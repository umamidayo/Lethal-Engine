local module = {
	priority = 1,
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local Teams = game:GetService("Teams")

local store = require(ReplicatedStorage.Common.Store)
local perksFolder = ReplicatedStorage.Common.PlayerClass.Perks
local PurchaseModule = require(ServerScriptService.Modules.PurchaseModule)
local PainSounds = SoundService.CharacterSounds.PainSounds:GetChildren()
local Network = require(ReplicatedStorage.Common.Network)
local RoundState = require(ReplicatedStorage.Common.States.Game.RoundState)

local roundState = RoundState.state

local perks = {}

for _, perk in pairs(perksFolder:GetChildren()) do
	local perkData = require(perk)
	perks[perk.Name] = perkData
end

local function giveSpectate(player: Player)
	if player.Team == Teams.Survivor or player.Team == Teams.Spawn then
		return
	end
	local gui = ReplicatedStorage.UI.SpectatorGui:Clone()
	gui.Parent = player:WaitForChild("PlayerGui")
	gui.Spectator_Client.Disabled = false
end

local function onCharacterAdded(player: Player, character: Model)
	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	character:WaitForChild("HumanoidRootPart")
	character:WaitForChild("Health").Enabled = false
	character:PivotTo(CFrame.new(workspace.SpawnLocation.Position + Vector3.new(0, 4, 0)))
	player.Character:SetAttribute("Protection", 0)
	player.Team = Teams.Spawn

	local storeState = store:getState().playerClass
	local playerState = storeState[player.UserId]
	if not playerState then
		repeat
			storeState = store:getState().playerClass
			playerState = storeState[player.UserId]
			task.wait(0.1)
		until playerState
	end

	local className = playerState.className
	local playerperks = playerState.perks or {}

	for _, perk in playerperks do
		if perks[className] and perks[className][perk] then
			if perks[className][perk].PerkFunction then
				perks[className][perk].PerkFunction(player)
			end
		end
	end

	-- giveDevTools(player)

	humanoid.Died:Connect(function()
		if player.Team == Teams.Survivor then
			player.Team = Teams.Dead
		end

		if character and character:FindFirstChild("HumanoidRootPart") then
			local pain = PainSounds[math.random(1, #PainSounds)]:Clone()
			pain.Parent = character.HumanoidRootPart
			pain:Destroy()
		end

		if humanoid then
			humanoid:UnequipTools()
		end

		player.Backpack:ClearAllChildren()

		task.wait(8)

		-- If the game just ended or round ended or they're just sitting in spawn
		local intermission = roundState.intermission
		if intermission or player.Team == Teams.Spawn then
			player:LoadCharacter()
		else
			giveSpectate(player)
		end
	end)
end

local function onPlayerAdded(player: Player)
	player:LoadCharacter()
	player.Character:WaitForChild("Humanoid")
	player.Character:WaitForChild("HumanoidRootPart")
	player.Character:PivotTo(CFrame.new(workspace.SpawnLocation.Position + Vector3.new(0, 4, 0)))
	player.Character:SetAttribute("Protection", 0)

	local intermission = roundState.intermission
	if not intermission then
		if player.Character then
			player.Character:Destroy()
		end

		player.Backpack:ClearAllChildren()
		player.Team = Teams.Dead
		giveSpectate(player)
	end
end

function module.init()
	Players.PlayerAdded:Connect(function(player)
		ReplicatedStorage.RemotesLegacy.VisualUpdate:FireClient(player, "Update", PurchaseModule.purchased[player.Name])

		player.CharacterAdded:Connect(function(character)
			onCharacterAdded(player, character)
		end)

		onPlayerAdded(player)
	end)

	Network.connectEvent(Network.RemoteEvents.BodyTempEvent, function(player: Player, eventType: string)
		if eventType == "Damage" then
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid:TakeDamage(5)
				end
			end
		end
	end, Network.t.instanceOf("Player"), Network.t.instanceOf("string"))

	Network.connectEvent(Network.RemoteEvents.FoodEvent, function(player: Player, eventType: string)
		if eventType == "Malnutrition" then
			local character = player.Character
			if not character then
				return
			end
			local Humanoid = character:FindFirstChildWhichIsA("Humanoid")
			if not Humanoid then
				return
			end
			Humanoid:TakeDamage(1)
		end
	end, Network.t.instanceOf("Player"), Network.t.string)
end

return module
