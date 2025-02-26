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

local HTTP = game:GetService("HttpService")

local logger = {
	url = "https://in.logtail.com",
	token = "Bearer K5GWUecKKyg3BTpYpAzU5qfR",
}

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service
	
	service.Events.CommandRan:Connect(function(plr, data)
		if game.PrivateServerId ~= "" then return end
		
		local msg = data.Message
		local cmd = data.Matched
		local args = data.Args
		
		local plevel = data.PlayerData.Level
		
		if plevel >= 100 then
			local log = {
				message = plr.DisplayName .. " (" .. plr.Name ..") used command: " .. cmd,
				arguments = table.concat(args, " ")
			}
			
			HTTP:RequestAsync({
				Url = logger.url,
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json",
					["Authorization"] = logger.token
				},
				Body = HTTP:JSONEncode(log)
			})
		end
	end)
end
