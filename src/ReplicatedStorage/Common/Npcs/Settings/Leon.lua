local NpcModule = {
	properties = {
		npcName = `Leon`,
		title = `Tactics Officer`,
		canAggro = false,
		canRoam = false,
		canTalk = true,
	},

	dialogs = {},
	choices = {},
}

local nameColor = `<font color="rgb(48, 100, 230)">`
local objectiveColor = `<font color="rgb(232, 189, 35)">`
local font = `</font>`

NpcModule.dialogs.intro = {
	`Welcome to the {nameColor}Last Resort{font}, survivor. Is there anything that I can assist you with?`,
	`Hello, there. Are you looking for some {objectiveColor}guidance{font}?`,
	`What's your inquiry?`,
	`Yes, mate?`,
}

NpcModule.dialogs.help = {
	`If you're looking to {objectiveColor}fight the infected{font}, I suggest you head down the hall and talk to {nameColor}Tristan{font}.`,
	`There's {objectiveColor}missions{font} available if you talk to {nameColor}Dayo{font}. He'll get you situated with the tasks at hand.`,
	`Need some {objectiveColor}materials{font}? {nameColor}Ash{font} has you covered. Be sure to bring some cash with you.`,
}

NpcModule.dialogs.chat = {
	`Yeah, sure. I can chat for a bit. Have you heard about the weather? No? Well, best get to the surface.`,
	`I enjoy a good conversation, but there's work to be done.`,
	`The world's ending, but here you are, spending precious time with me.`,
	`Can you get a hint? Go away please.`,
	`...`,
}

NpcModule.dialogs.exit = {
	`See you later, survivor.`,
	`Get going, survivor`,
	`Be safe out there.`,
	`Goodbye.`,
}

NpcModule.dialogs.daily = {
	"I hope you've been regularly checking. Let's find out.",
	"It's free stuff, why wouldn't anyone claim free stuff?",
	"Glad you're keeping things in check, survivor.",
	"How many days is it this time?",
	"I bet $5 you'll forget to check these tomorrow.",
}

NpcModule.choices.intro = {
	Help = {
		Text = `Help`,
		LayoutOrder = 1,
		Action = function()
			NpcModule.npcObject.event:Fire(`help`)
		end,
	},
	Daily = {
		Text = `Check Daily Reward`,
		LayoutOrder = 2,
		Action = function()
			NpcModule.npcObject.event:Fire(`daily`)
		end,
	},
	Chat = {
		Text = `Chat`,
		LayoutOrder = 3,
		Action = function()
			NpcModule.npcObject.event:Fire(`chat`)
		end,
	},
	Exit = {
		Text = `Exit`,
		LayoutOrder = 10,
		Action = function()
			NpcModule.npcObject.event:Fire(`exit`)
		end,
	},
}

function NpcModule.setNpcObject(npc)
	NpcModule.npcObject = npc
end

return NpcModule
