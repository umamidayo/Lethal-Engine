local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Common.Network)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)

local NpcModule = {
	properties = {
		npcName = "Tristan",
		title = "Operations Officer",
		canAggro = false,
		canRoam = false,
		canTalk = true,
	},

	dialogs = {},
	choices = {},
}

NpcModule.dialogs.intro = {
	"Are you ready to fight?",
	"It's dangerous out there. Are you prepared?",
	"You got everything you need?",
	"What would you like to do?",
}

NpcModule.dialogs.chat = {
	"The zeds are pretty tough later on. Make sure you're prepared for anything that comes at you.",
	"Survival is key, but safety is paramount. There's plenty of zeds, but only one of you.",
	"Want some advice? Make sure you have a source of food and water. You don't want to be caught starving during a fight.",
	"My favorite starting weapon is the AS-VAL. It'll blow right through their heads.",
	"Ash? Yeah, he's a real sweet guy. We go way back, before the outbreak. Saved me a couple of times. I'm glad we were able to escape from the big cities together.",
	"I used to work with Dayo at a small club in the city. The people there were miserable, but Dayo always brought a good laugh now and then.",
}

NpcModule.dialogs.exit = {
	"I'll be here.",
	"Take your time.",
	"See you soon",
	"Let me know when you're ready.",
}

NpcModule.dialogs.randomgame = {
	"You sure you want to join a random group of survivors?",
}

NpcModule.dialogs.privategame = {
	"This will start a new game with everyone in your server. Are you sure?",
}

NpcModule.dialogs.play = {
	"Alright, what's the SITREP?",
	"No problem, what's the plan?",
	"Ready as you are. What's the move?",
}

NpcModule.dialogs.serverlist = {
	"Alright, lemme pull up our current operations...",
	"Got it, just give me a second to check the intel...",
	"No problem, let's see what's on the radar...",
	"Sure thing, standby while I transmit the data to your ATAK...",
	"Loud and clear, please wait while I radio in the information...",
	"Roger that, making contact with the other units now...",
}

NpcModule.choices.play = {
	ServerList = {
		Text = "View server list",
		LayoutOrder = 1,
		Action = function()
			NpcModule.npcObject.event:Fire("serverlist")
		end,
	},
	RandomGame = {
		Text = "Join a random game",
		LayoutOrder = 2,
		Action = function()
			NpcModule.npcObject.event:Fire("randomgame")
		end,
	},
	PrivateGame = {
		Text = "Start a private game",
		LayoutOrder = 3,
		Action = function()
			NpcModule.npcObject.event:Fire("privategame")
		end,
	},
}

NpcModule.choices.intro = {
	Play = {
		Text = "Play the game",
		LayoutOrder = 2,
		Action = function()
			NpcModule.npcObject.event:Fire("play")
		end,
	},
	Chat = {
		Text = "Chat",
		LayoutOrder = 2,
		Action = function()
			NpcModule.npcObject.event:Fire("chat")
		end,
	},
	Exit = {
		Text = "Exit",
		LayoutOrder = 10,
		Action = function()
			NpcModule.npcObject.event:Fire("exit")
		end,
	},
}

NpcModule.choices.randomgame = {
	Yes = {
		Text = "Yes",
		LayoutOrder = 1,
		Action = function()
			Network.fireServer(Network.RemoteEvents.TeleportEvent, "RandomServer")
			NpcModule.npcObject.event:Fire("exit")
		end,
	},
	No = {
		Text = "No",
		LayoutOrder = 2,
		Action = function()
			NpcModule.npcObject.event:Fire("exit")
		end,
	},
}

NpcModule.choices.privategame = {
	Yes = {
		Text = "Yes",
		LayoutOrder = 1,
		Action = function()
			Network.fireServer(Network.RemoteEvents.TeleportEvent, "PrivateServer")
			NpcModule.npcObject.event:Fire("exit")
		end,
	},
	No = {
		Text = "No",
		LayoutOrder = 2,
		Action = function()
			NpcModule.npcObject.event:Fire("exit")
		end,
	},
}

function NpcModule.setNpcObject(npc)
	NpcModule.npcObject = npc
end

return NpcModule
