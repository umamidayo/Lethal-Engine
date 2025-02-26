local Players = game:GetService(`Players`)

local NpcModule = {
	properties = {
		npcName = `Dayo`,
		title = `Missions Officer`,
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

NpcModule.dialogs.missions = {
	`Sorry, we ain't got any missions available. You gotta come back later.`,
	`Yo, we ain't got missions yet. Just kill some zeds and level up.`,
	`How many times do I gotta tell you, dawg... Come back later!`,
	`If you really want stuff to do, check your journal when you get to the surface. You'll see a list of things you can get rewarded for, aight?`,
	`Dawg... I'm telling you one last time. Come. Back. Later.`,
	`...`,
	`(Ignores you)`,
	`...`,
	`Aight dude, I'm kicking you out the game. Clearly you ain't got anything better to do.`,
}

NpcModule.dialogs.intro = {
	`Yo, what'chu need?`,
	`Waddup?`,
	`Come here often?`,
	`How ya doing?`,
}

NpcModule.dialogs.chat = {
	`Aight, but I ain't much of a talker.`,
	`I'm pretty much in charge of the {nameColor}Last Resort{font}, thanks to the team here.`,
	`Yeah, we used to hang out at a place called The Open Space. It was pretty chill. Lots of weird folks, but I brought all of the good people here.`,
	`Before the outbreak, I separated from the Air Force. I spent a lot of time training and eventually deployed to Afghanistan. This place ain't much different from there.`,
	"One thing I regret, is not spending enough time with my family and friends. Who knew that the world would end up like this?",
	"The best we can do is move forward and work together. Let's hope for the best, big dawg.",
}

NpcModule.dialogs.exit = {
	`Aight, peace.`,
	`See ya.`,
	`Take care.`,
	`Good luck.`,
}

NpcModule.choices.intro = {
	Shop = {
		Text = `Missions`,
		LayoutOrder = 1,
		Action = function()
			if NpcModule.npcObject.dialogIndices.missions == #NpcModule.dialogs.missions then
				task.delay(4, function()
					Players.LocalPlayer:Kick(`We ain't got missions, dawg. - Dayo (Missions Officer)`)
				end)
			end
			NpcModule.npcObject.event:Fire(`missions`)
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
