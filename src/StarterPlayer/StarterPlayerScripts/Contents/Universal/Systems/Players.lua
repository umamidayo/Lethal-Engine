local module = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local StoreUtility = require(ReplicatedStorage.Common.StoreUtility)
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local PlayerTagSample: BillboardGui = ReplicatedStorage.Entities:WaitForChild("Billboards"):WaitForChild("PlayerTag")
local PlayerHighlight: Highlight = ReplicatedStorage.Entities:WaitForChild("Highlights"):WaitForChild("PlayerHighlight")

local LocalPlayer = Players.LocalPlayer
local PlayertagsEnabled = LocalPlayer:GetAttribute("ShowPlayerTags") or true

-- {Player.UserId | number}
local Friends: { number } = {}

-- PlayerTags

local function formatNumber(n): number?
	n = tostring(n)
	return (n:reverse():gsub("...", "%0,", math.floor((#n - 1) / 3)):reverse()) :: number
end

local function addPlayerTag(player: Player)
	if not player.Character then
		return
	end
	if not player.Character:FindFirstChild("Torso") then
		return
	end
	if player.Character.Torso:FindFirstChild("PlayerTag") then
		return
	end

	local playerTag = PlayerTagSample:Clone()
	playerTag.Parent = player.Character.Torso
	playerTag.Adornee = player.Character.Torso
	local Icons = playerTag.Frame.Icons

	if player.HasVerifiedBadge then
		Icons.VerifiedBadge.Visible = true
	end

	if player.MembershipType == Enum.MembershipType.Premium then
		Icons.Premium.Visible = true
	end

	if player:IsInGroup(10705478) then
		Icons.GroupMember.Visible = true
		if player:GetRankInGroup(10705478) >= 249 then
			Icons.Creator.Visible = true
		end
	end

	if player:IsInGroup(1200769) then
		Icons.RobloxAdmin.Visible = true
	end

	playerTag.Frame.DisplayName.Text = player.DisplayName
	playerTag.Frame.Title.Text = player:GetAttribute("Title") or "Survivor"
	local Kills = player:GetAttribute("Kills") or 0
	playerTag.Frame.Level.Text = formatNumber(Kills) .. " Kills"
	return playerTag
end

local function updatePlayerTags()
	for _, player in Players:GetPlayers() do
		if not player.Character then
			continue
		end
		if not player.Character:FindFirstChild("Torso") then
			continue
		end
		local playerTag: BillboardGui = player.Character.Torso:FindFirstChild("PlayerTag") or addPlayerTag(player)
		if not playerTag then
			continue
		end

		local playerClass = StoreUtility.getValue("playerClass", player.UserId)
		if not playerClass then
			continue
		end

		playerClass.level = playerClass.level or 1
		playerClass.className = playerClass.className or "Loading..."
		playerClass.experience = playerClass.experience or 0
		playerClass.requiredExperience = playerClass.requiredExperience or 20
		local title = player:GetAttribute("Title") or "Loading..."

		if PlayertagsEnabled and not playerTag.Enabled then
			playerTag.Enabled = true
			playerTag.Frame.Title.Text = `{title} {playerClass.className}`
			playerTag.Frame.Level.Text = `Level {formatNumber(playerClass.level)}`
			if playerClass.level >= 10 then
				playerTag.Frame.Exp.Visible = false
				continue
			end
			playerTag.Frame.Exp.Fill.Size =
				UDim2.new(playerClass.experience / playerClass.requiredExperience, 0, 0.85, 0)
			playerTag.Frame.Exp.Text.Text =
				`{formatNumber(playerClass.experience)} / {formatNumber(playerClass.requiredExperience)} EXP`
		elseif not PlayertagsEnabled and playerTag.Enabled then
			playerTag.Enabled = false
		else
			playerTag.Frame.Title.Text = `{title} {playerClass.className}`
			playerTag.Frame.Level.Text = `Level {formatNumber(playerClass.level)}`
			if playerClass.level >= 10 then
				playerTag.Frame.Exp.Visible = false
				continue
			end
			playerTag.Frame.Exp.Fill.Size =
				UDim2.new(playerClass.experience / playerClass.requiredExperience, 0, 0.85, 0)
			playerTag.Frame.Exp.Text.Text =
				`{formatNumber(playerClass.experience)} / {formatNumber(playerClass.requiredExperience)} EXP`
		end
	end
end

-- RunService / Player Highlighter

local function updatePlayerHighlights()
	for _, player in Players:GetPlayers() do
		if player == LocalPlayer then
			continue
		end

		if player.Team == Teams.Spawn or player.Team == Teams.Admin then
			continue
		end

		if not player.Character or player.Character.Parent ~= workspace then
			continue
		end

		if player.Character.Parent == workspace.Characters or player.Character.Parent == workspace.Friends then
			continue
		end

		if Friends[player.UserId] == nil then
			if LocalPlayer:IsFriendsWith(player.UserId) then
				Friends[player.UserId] = true
			else
				Friends[player.UserId] = false
			end
		end

		if Friends[player.UserId] then
			player.Character.Parent = workspace.Friends
		else
			player.Character.Parent = workspace.Characters
		end
	end
end

local function autoFixPlayerHighlight()
	PlayerHighlight.Adornee = nil
	task.wait()
	PlayerHighlight.Adornee = workspace.Characters
	print(script.Name .. ": Auto fixing player highlights")
end

function module.init()
	LocalPlayer.CharacterAdded:Connect(function()
		autoFixPlayerHighlight()
	end)

	LocalPlayer:GetAttributeChangedSignal("ShowPlayerTags"):Connect(function()
		PlayertagsEnabled = LocalPlayer:GetAttribute("ShowPlayerTags")
	end)

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			addPlayerTag(player)
		end)
	end)

	Scheduler.AddToScheduler("Interval_0.1", "PlayerHighlight", function()
		updatePlayerHighlights()
		updatePlayerTags()
	end)
end

return module
