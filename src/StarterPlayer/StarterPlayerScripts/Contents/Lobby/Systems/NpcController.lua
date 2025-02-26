local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NpcsFolder: Folder = ReplicatedStorage.Common.Npcs

local NpcClass = require(ReplicatedStorage.Common.Npcs.NpcClass)

local NpcController = {
	Npcs = {},
	NpcModules = {},
}

function NpcController:requireNpcModule(npcName)
	local npcModule = NpcsFolder:FindFirstChild(npcName, true)
	if npcModule and npcModule:IsA("ModuleScript") then
		self.NpcModules[npcName] = require(npcModule)
		return self.NpcModules[npcName]
	end
end

function NpcController.init()
	local taggedNpcs = CollectionService:GetTagged("NPC")
	for _, npc in taggedNpcs do
		local npcModule = NpcController:requireNpcModule(npc.Name)
		if not npcModule then
			warn(`No NPC module found for {npc.Name}`)
			continue
		else
			NpcController.Npcs[npc.Name] = NpcClass.new(npc, npcModule)
		end
	end
end

return NpcController
