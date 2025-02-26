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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Notifier = game:GetService("ReplicatedStorage").RemotesLegacy.Notifier

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service

	server.Commands.SetRound = {
		Prefix = server.Settings.Prefix, -- Prefix to use for command
		Commands = { "setround" }, -- Commands
		Args = { "round" }, -- Command arguments
		Description = "Sets the round to the specified round.", -- Command Description
		Hidden = false, -- Is it hidden from the command list?
		Fun = false, -- Is it fun?
		AdminLevel = "Testers", -- Admin level; If using settings.CustomRanks set this to the custom rank name (eg. "Baristas")
		Function = function(plr: Player, args) -- Function to run for command
			if not RunService:IsStudio() then
				if game.PlaceId == 11614561669 then
					Notifier:FireClient(plr, `Must be in the test build.`, Color3.fromRGB(255, 92, 95))
					return
				end
			end

			if not plr:IsInGroup(10705478) or plr:GetRankInGroup(10705478) < 20 then
				Notifier:FireClient(plr, `Testers only.`, Color3.fromRGB(255, 92, 95))
				return
			end

			if not args[1] then
				Notifier:FireClient(plr, `Must specify a round.`, Color3.fromRGB(255, 92, 95))
				return
			end

			local RoundState = require(ReplicatedStorage.Common.States.Game.RoundState)
			local RoundService = require(ServerScriptService.Contents.Game.Systems.Zombies.RoundService)
			local ZombieService = require(ServerScriptService.Contents.Game.Systems.Zombies.ZombieService)

			local roundState = RoundState.state

			local round = tonumber(args[1]) or 1
			round = math.clamp(round - 1, 1, 999999)
			roundState.round = round
			if not roundState.roundStartTick then
				roundState.roundStartTick = tick()
			end
			RoundService.updateClient()
			RoundService.intermission()
			ZombieService.clearZombies()
		end,
	}
end
