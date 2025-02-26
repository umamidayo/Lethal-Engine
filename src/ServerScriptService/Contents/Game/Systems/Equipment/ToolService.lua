local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local Network = require(ReplicatedStorage.Common.Network)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local ToolUtility = require(ServerScriptService.Modules.Tools.ToolUtility)

local ToolStore = {}
local module = {}

local function validateToolState(player: Player, toolState: table, minTime: number): (boolean, Model?, Humanoid?)
	if not toolState or tick() - toolState.HealStartTick < minTime then
		return false
	end

	local character = player.Character
	if not character then
		return false
	end

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		return false
	end

	return true, character, humanoid
end

local function playToolSound(character: Model, toolName: string, soundName: string)
	local sound = SoundService.Tools[toolName][soundName]:Clone()
	sound.Parent = character.PrimaryPart
	sound:Play()
	Debris:AddItem(sound, 5)
end

local function validateToolParams(player: Player, toolParams: table): Tool?
	local tool = toolParams.Tool
	if not tool or tool.Parent ~= player.Character then
		return nil
	end
	return tool
end

local function eatStart(player: Player, toolParams: {})
	local tool = validateToolParams(player, toolParams)
	if not tool then
		return
	end

	ToolStore[player.UserId] = {
		HealStartTick = tick(),
		Tool = tool,
		HealAmount = tool:GetAttribute("HealAmount") or 0,
		FoodAmount = tool:GetAttribute("FoodAmount") or 0,
		DrinkAmount = tool:GetAttribute("DrinkAmount") or 0,
	}

	playToolSound(player.Character, tool.Name, "EatSound")
end

local function eatFinish(player: Player)
	local toolState = ToolStore[player.UserId]
	local success, _, humanoid = validateToolState(player, toolState, 2)
	if not success then
		return
	end

	humanoid.Health += toolState.HealAmount

	Network.fireClient(Network.RemoteEvents.FoodEvent, player, "EatFinish", {
		FoodAmount = toolState.FoodAmount,
		DrinkAmount = toolState.DrinkAmount,
	})

	if toolState.Tool then
		local conversionTool = ToolUtility.GetConversionTool(toolState.Tool.Name)
		if conversionTool then
			conversionTool.Parent = player.Backpack
			ToolUtility.ForceEquip(player, conversionTool)
		end
		toolState.Tool:Destroy()
	end

	ToolStore[player.UserId] = nil
end

local function healStart(player: Player, toolParams: {})
	local tool = validateToolParams(player, toolParams)
	if not tool then
		return
	end

	ToolStore[player.UserId] = {
		HealStartTick = tick(),
		Tool = tool,
		HealAmount = tool:GetAttribute("HealAmount"),
	}

	playToolSound(player.Character, tool.Name, "HealSound")
end

local function healOtherStart(player: Player, toolParams: {})
	local tool = validateToolParams(player, toolParams)
	if not tool then
		return
	end

	ToolStore[player.UserId] = {
		HealStartTick = tick(),
		Tool = tool,
		HealAmount = tool:GetAttribute("HealAmount"),
		OtherPlayer = toolParams.OtherPlayer,
	}

	playToolSound(player.Character, tool.Name, "HealSound")
end

local function healFinish(player: Player)
	local toolState = ToolStore[player.UserId]
	local success, _, humanoid = validateToolState(player, toolState, 2)
	if not success then
		return
	end

	humanoid.Health += toolState.HealAmount

	if toolState.Tool then
		toolState.Tool:Destroy()
	end
	ToolStore[player.UserId] = nil
end

local function healOtherFinish(player: Player)
	local toolState = ToolStore[player.UserId]
	local success, character = validateToolState(player, toolState, 2)
	if not success then
		return
	end

	local otherPlayer = toolState.OtherPlayer
	if not otherPlayer or not otherPlayer.Character then
		return
	end

	local otherHumanoid = otherPlayer.Character:FindFirstChildWhichIsA("Humanoid")
	if not otherHumanoid then
		return
	end

	local bonusHealing = character:GetAttribute("HealingBonus") or 0
	local totalHealing = toolState.HealAmount * (1 + bonusHealing)
	otherHumanoid.Health += totalHealing

	Notifier.NotificationEvent(otherPlayer, `You have been healed by {player.DisplayName}`, Color3.fromRGB(63, 180, 63))

	if toolState.Tool then
		toolState.Tool:Destroy()
	end
	ToolStore[player.UserId] = nil
end

function module.init()
	Network.connectEvent(Network.RemoteEvents.ToolEvent, function(player: Player, eventType: string, toolParams: {})
		local handlers = {
			HealStart = healStart,
			HealOtherStart = healOtherStart,
			HealFinish = healFinish,
			HealOtherFinish = healOtherFinish,
			EatStart = eatStart,
			EatFinish = eatFinish,
		}

		local handler = handlers[eventType]
		if handler then
			handler(player, toolParams)
		end
	end, Network.t.instanceOf("Player"), Network.t.string, Network.t.any)
end

return module
