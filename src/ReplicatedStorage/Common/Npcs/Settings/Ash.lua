local NpcModule = {
	properties = {
		npcName = `Ash`,
		title = `Logistics Officer`,
		canAggro = false,
		canRoam = false,
		canTalk = true,
	},

	dialogs = {},
	choices = {},
}

NpcModule.dialogs.intro = {
	`Hello there, survivor.`,
	`Here to buy some building materials?`,
	`Need some more materials? I've got plenty for sale.`,
	`Welcome to the logistics depot.`,
}

NpcModule.dialogs.chat = {
	`I sell all sorts of materials for a fair price. If you're looking for something specific, just let me know.`,
	`Hey now, can't you see I have a business to run? If you're not buying, then go start killing zeds.`,
	`Are they still yapping about me? Dayo and Tristan. We were a team during the start of the outbreak, but we're glad to be part of a larger group now.`,
	`I lost a good friend before I came to the Last Resort. His name was Ely and he was a silly, reckless guy. One of the best zed slayers I've seen.`,
	`I see now, you're trying to haggle with me. I'm not going to lower my prices, so don't even ask.`,
	`Well, I have more than just building materials. I also have some cosmetics for sale from my own supply line. I call it, 'Ashes Wings'. Pretty cool, huh?`,
}

NpcModule.dialogs.exit = {
	`I hope you have a wonderful day.`,
	`Goodbye, now.`,
	`I'll be seeing you shortly`,
	`Another time, then.`,
}

NpcModule.dialogs.shop = {
	`Splendid, can't wait to show you what's in store.`,
	`I'm sure you'll find something you like.`,
	`I have a wide selection of materials for you to choose from.`,
	`Nice, let's hear those pockets jingle!`,
}

NpcModule.choices.intro = {
	Shop = {
		Text = `Shop`,
		LayoutOrder = 1,
		Action = function()
			NpcModule.npcObject.event:Fire(`shop`)
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
