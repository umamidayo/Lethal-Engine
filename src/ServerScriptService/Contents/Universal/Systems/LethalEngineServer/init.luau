local ServerScriptService = game:GetService("ServerScriptService")

local LethalEngineServerPath = ServerScriptService.Contents.Universal.Systems.LethalEngineServer

local StanceHandler = require(LethalEngineServerPath.StanceHandler)

local LethalEngineServer = {}

function LethalEngineServer.init()
	StanceHandler.init()
end

return LethalEngineServer
