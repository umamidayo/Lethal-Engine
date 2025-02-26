local ServerStorage = game:GetService("ServerStorage")
local module = {}

local toolConversions = {
	["Water Bottle"] = "Empty Bottle",
}

function module.GetConversionTool(toolName: string)
	if not toolConversions[toolName] then
		return
	end

	local conversionToolName = toolConversions[toolName]

	local conversionTool = ServerStorage.Tools:FindFirstChild(conversionToolName)

	if conversionTool then
		return conversionTool:Clone()
	end
end

function module.ForceEquip(player: Player, tool: Tool)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character.Humanoid
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	humanoid:EquipTool(tool)
end

return module
