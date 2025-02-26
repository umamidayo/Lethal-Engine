local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local Network = require(ReplicatedStorage.Common.Network)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)
local ToolUtility = require(ServerScriptService.Modules.Tools.ToolUtility)

local ToolService = {}
local toolStates = {}

local function validateTool(player: Player, tool: Tool): boolean
	return tool and tool.Parent == player.Character
end

local function validateCharacter(player: Player): (Model?, Humanoid?)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		return
	end

	return character, humanoid
end

local function playToolSound(player: Player, tool: Tool, soundName: string)
	local sound = SoundService.Tools[tool.Name][soundName]:Clone()
	sound.Parent = player.Character.PrimaryPart
	sound:Play()
	Debris:AddItem(sound, 5)
end

local function handleToolStart(player: Player, toolParams: {}, stateData: {})
	local tool = toolParams.Tool
	if not validateTool(player, tool) then
		return
	end

	toolStates[player.UserId] = {
		StartTick = tick(),
		Tool = tool,
	}

	for key, value in stateData do
		toolStates[player.UserId][key] = value
	end
end

local function handleToolFinish(player: Player, finishCallback: (Player, any) -> ())
	local state = toolStates[player.UserId]
	if not state or tick() - state.StartTick < 2 then
		return
	end

	local character, humanoid = validateCharacter(player)
	if not character or not humanoid then
		return
	end

	finishCallback(player, state)

	if state.Tool then
		if state.ConvertTool then
			local conversionTool = ToolUtility.GetConversionTool(state.Tool.Name)
			if conversionTool then
				conversionTool.Parent = player.Backpack
				ToolUtility.ForceEquip(player, conversionTool)
			end
		end
		state.Tool:Destroy()
	end

	toolStates[player.UserId] = nil
end

local function eatStart(player: Player, toolParams: {})
	local tool = toolParams.Tool
	if not validateTool(player, tool) then
		return
	end

	handleToolStart(player, toolParams, {
		HealAmount = tool:GetAttribute("HealAmount") or 0,
		FoodAmount = tool:GetAttribute("FoodAmount") or 0,
		DrinkAmount = tool:GetAttribute("DrinkAmount") or 0,
		ConvertTool = true,
	})

	playToolSound(player, tool, "EatSound")
end

local function eatFinish(player: Player)
	handleToolFinish(player, function(player, state)
		local character, humanoid = validateCharacter(player)
		if not character or not humanoid then
			return
		end

		humanoid.Health += state.HealAmount

		Network.fireClient(Network.RemoteEvents.FoodEvent, player, "EatFinish", {
			FoodAmount = state.FoodAmount,
			DrinkAmount = state.DrinkAmount,
		})
	end)
end

local function healStart(player: Player, toolParams: {})
	local tool = toolParams.Tool
	if not validateTool(player, tool) then
		return
	end

	handleToolStart(player, toolParams, {
		HealAmount = tool:GetAttribute("HealAmount"),
	})

	playToolSound(player, tool, "HealSound")
end

local function healOtherStart(player: Player, toolParams: {})
	local tool = toolParams.Tool
	if not validateTool(player, tool) then
		return
	end

	handleToolStart(player, toolParams, {
		HealAmount = tool:GetAttribute("HealAmount"),
		OtherPlayer = toolParams.OtherPlayer,
	})

	playToolSound(player, tool, "HealSound")
end

local function healFinish(player: Player)
	handleToolFinish(player, function(player, state)
		local character, humanoid = validateCharacter(player)
		if not character or not humanoid then
			return
		end

		humanoid.Health += state.HealAmount
	end)
end

local function healOtherFinish(player: Player)
	handleToolFinish(player, function(player, state)
		local otherPlayer = state.OtherPlayer
		if not otherPlayer then
			return
		end

		local character = player.Character
		local otherCharacter, otherHumanoid = validateCharacter(otherPlayer)
		if not otherCharacter or not otherHumanoid then
			return
		end

		local bonusHealing = character:GetAttribute("HealingBonus") or 0
		local totalHealing = state.HealAmount + (state.HealAmount * bonusHealing)

		otherHumanoid.Health += totalHealing
		Notifier.NotificationEvent(
			otherPlayer,
			`You have been healed by {player.DisplayName}`,
			Color3.fromRGB(63, 180, 63)
		)
	end)
end

function ToolService.init()
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

return ToolService
