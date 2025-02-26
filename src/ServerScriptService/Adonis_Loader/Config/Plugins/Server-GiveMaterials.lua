--[[
	SERVER PLUGINS' NAMES MUST START WITH "Server:" OR "Server-"
	CLIENT PLUGINS' NAMES MUST START WITH "Client:" OR "Client-"

	Plugins have full access to the server/client tables and most variables.

	You can use the MakePluginEvent to use the script instead of setting up an event.
	PlayerChatted will get chats from the custom chat and nil players.
	PlayerJoined will fire after the player finishes initial loading
	CharacterAdded will also fire after the player is loaded, it does not use the CharacterAdded event.

	service.Events.PlayerChatted(function(plr, msg)
		print(msg..' from '..plr.Name..' Example Plugin')
	end)

	service.Events.PlayerAdded(function(p)
		print(p.Name..' Joined! Example Plugin')
	end)

	service.Events.CharacterAdded(function(p)
		server.RunCommand('name',plr.Name,'BobTest Example Plugin')
	end)

--]]

local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Notifier = ReplicatedStorage.RemotesLegacy.Notifier

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service

	server.Commands.GiveMaterials = {
		Prefix = server.Settings.Prefix, -- Prefix to use for command
		Commands = { "givematerials" }, -- Commands
		Args = { "amount" }, -- Command arguments
		Description = "Gives materials to you.", -- Command Description
		Hidden = false, -- Is it hidden from the command list?
		Fun = false, -- Is it fun?
		AdminLevel = "Testers", -- Admin level; If using settings.CustomRanks set this to the custom rank name (eg. "Baristas")
		Function = function(plr: Player, args) -- Function to run for command
			local TestConfig = require(ServerScriptService.Contents.Universal.Systems.TestConfig)
			if not TestConfig.isTestBuild then
				Notifier:FireClient(plr, `Must be in the test build.`, Color3.fromRGB(255, 92, 95))
				return
			end

			if not TestConfig.isTester(plr) then
				Notifier:FireClient(plr, `Testers only.`, Color3.fromRGB(255, 92, 95))
				return
			end

			if not args[1] or tonumber(args[1]) == nil then
				Notifier:FireClient(plr, `Invalid amount.`, Color3.fromRGB(255, 92, 95))
				return
			end

			local PlayerService = require(ServerScriptService.Contents.Universal.Systems.PlayerService)
			PlayerService.incrementStat(plr, "Materials", tonumber(args[1]))
		end,
	}
end
