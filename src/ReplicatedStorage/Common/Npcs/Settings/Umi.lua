local NpcModule = {
	properties = {
		npcName = `Umi`,
		title = `Equipment Officer`,
		canAggro = false,
		canRoam = false,
		canTalk = true,
	},

	dialogs = {},
	choices = {},
}

NpcModule.dialogs.intro = {
	`Hi! How can I help you?`,
	`What can I do for you?`,
	`Are you here for some equipment?`,
	`Good to see you again! What can I help you with?`,
}

NpcModule.dialogs.chat = {
	`I don't mind a chat, but anything more than that and we'll have an issue.`,
	`Right before the outbreak, my family bought a lake house. We split up during the outbreak, but I hope they're in a safe place.`,
	`As a kid, I imagined dressing up and pretending I was a princess, but now I'm killing zeds. Kind of a big contrast, but it's alright.`,
	`I came to the Last Resort with Ash, Dayo, and Tristan. Three years ago, I met them at a hangout spot in the city. It was a huge open space and there were tons of games to play.`,
	`That's enough chatter, there's work to be done.`,
}

NpcModule.dialogs.exit = {
	`Peace.`,
	`See you again soon.`,
	`Looking forward to seeing you again.`,
	`Goodbye.`,
}

NpcModule.dialogs.perks = {
	"Don't forget, you can always change your class during operations.",
	"There's always time for a good change.",
	"I'm curious to see what you'll choose.",
	"Bored of your tactics? No problem, let's switch things up.",
}

NpcModule.choices.intro = {
	Perks = {
		Text = `Edit Class`,
		LayoutOrder = 2,
		Action = function()
			NpcModule.npcObject.event:Fire(`perks`)
		end,
	},
	Chat = {
		Text = `Chat`,
		LayoutOrder = 2,
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
