local ServerScriptService = game:GetService("ServerScriptService")

export type NpcProperties = {
	npcName: string,
	canAggro: boolean,
	canRoam: boolean,
	canTalk: boolean,
}

local BaseClass = require(ServerScriptService.Modules.AI.BaseClass)

local NpcClass = {}
NpcClass.__index = NpcClass
setmetatable(NpcClass, BaseClass)

function NpcClass.new(character: Model, npcProperties: NpcProperties)
	local self = setmetatable(BaseClass.new(character, true), NpcClass)
	self.npcName = npcProperties.npcName
	self.canAggro = npcProperties.canAggro
	self.canRoam = npcProperties.canRoam
	self.canTalk = npcProperties.canTalk
	self.state = "Idle"

	return self
end

function NpcClass:setState(newState: string)
	self.state = newState
end

return NpcClass
