local module = {}

local RobuxIcon = "rbxassetid://16287898746"
local RobuxIconColor = Color3.fromRGB(255, 215, 120)
local RobuxBackgroundColor = Color3.fromRGB(44, 77, 77)

local TokenIcon = "rbxassetid://16289490517"
local TokenIconColor = Color3.fromRGB(177, 71, 73)
local TokenBackgroundColor = Color3.fromRGB(54, 57, 97)

local redFontStart = `<font color="rgb(225, 100, 100)">`
local goldFontStart = `<font color="rgb(255, 223, 125)">`
local blueFontStart = `<font color="rgb(125, 223, 255)">`

local fontEnd = `</font>`

module.gamepasses = {
	[117434328] = {
		Name = "A Small Loan of a Million Dollars",
		Description = `{redFontStart}Only works in servers you haven't joined yet!{fontEnd} Start each game with {goldFontStart}$750{fontEnd} more cash. Stacks with the group membership bonus: $1750 altogether.`,
		Icon = RobuxIcon,
		IconColor = RobuxIconColor,
		BackgroundColor = RobuxBackgroundColor,
		Cost = 300,
	},

	[252800553] = {
		Name = "I'm Hungie For Some Matties!",
		Description = `{redFontStart}Rejoin for the gamepass to take effect!{fontEnd} Collecting building materials will yield {blueFontStart}25%{fontEnd} more resources.`,
		Icon = RobuxIcon,
		IconColor = RobuxIconColor,
		BackgroundColor = RobuxBackgroundColor,
		Cost = 150,
	},

	[255878424] = {
		Name = "Master's Degree In Architecture",
		Description = `{redFontStart}Rejoin for the gamepass to take effect!{fontEnd} Increase build limit from {blueFontStart}50{fontEnd} to {blueFontStart}500{fontEnd} units. Stacks with group membership bonus: 600 altogether.`,
		Icon = RobuxIcon,
		IconColor = RobuxIconColor,
		BackgroundColor = RobuxBackgroundColor,
		Cost = 500,
	},
}

module.tokens = {
	[1750167033] = {
		Name = "1,000 Tokens",
		Description = `Get {goldFontStart}1,000{fontEnd} tokens to spend in the store.`,
		Icon = RobuxIcon,
		IconColor = RobuxIconColor,
		BackgroundColor = RobuxBackgroundColor,
		Cost = 375,
		LayoutOrder = 1,
	},
	[1750167295] = {
		Name = "2,200 Tokens",
		Description = `Get {goldFontStart}2,200{fontEnd} tokens to spend in the store. Receive {goldFontStart}20%{fontEnd} more tokens than the 1,000 token pack.`,
		Icon = RobuxIcon,
		IconColor = RobuxIconColor,
		BackgroundColor = RobuxBackgroundColor,
		Cost = 750,
		LayoutOrder = 2,
	},
	[1750167362] = {
		Name = "5,500 Tokens",
		Description = `Get {goldFontStart}5,500{fontEnd} tokens to spend in the store.  Receive {goldFontStart}50%{fontEnd} more tokens than the 2,200 token pack.`,
		Icon = RobuxIcon,
		IconColor = RobuxIconColor,
		BackgroundColor = RobuxBackgroundColor,
		Cost = 1125,
		LayoutOrder = 3,
	},
	[1750167926] = {
		Name = "15,125 Tokens",
		Description = `Get {goldFontStart}15,125{fontEnd} tokens to spend in the store. Receive {goldFontStart}75%{fontEnd} more tokens than the 5,500 token pack.`,
		Icon = RobuxIcon,
		IconColor = RobuxIconColor,
		BackgroundColor = RobuxBackgroundColor,
		Cost = 1500,
		LayoutOrder = 4,
	},
}

module.classes = {
	["Doctor"] = {
		Name = "Doctor",
		Description = `Heals and buffs teammates, keeping them alive longer.`,
		Icon = TokenIcon,
		InfoIcon = "rbxassetid://16292552529",
		IconColor = TokenIconColor,
		BackgroundColor = TokenBackgroundColor,
		Cost = 1000,
	},

	["Engineer"] = {
		Name = "Engineer",
		Description = `Uses wide-area technological damage to deal with unrelenting hordes.`,
		Icon = TokenIcon,
		InfoIcon = "rbxassetid://129874184719813",
		IconColor = TokenIconColor,
		BackgroundColor = TokenBackgroundColor,
		Cost = 1600,
	},
}

module.special = {
	["Blood Moon"] = {
		Name = "Blood Moon",
		Description = `Activates a blood moon, doubling the zombie kill XP and difficulty. Lasts for 10 minutes.`,
		Icon = TokenIcon,
		InfoIcon = "rbxassetid://16292509120",
		IconColor = TokenIconColor,
		BackgroundColor = TokenBackgroundColor,
		Cost = 400,
	},
}

module.items = {
	["99 Sticks"] = {
		Name = "99 Sticks",
		Description = `Gives you a full stack of sticks.`,
		Icon = TokenIcon,
		InfoIcon = "rbxassetid://15614005732",
		IconColor = TokenIconColor,
		BackgroundColor = TokenBackgroundColor,
		Cost = 200,
	},
	["99 Rocks"] = {
		Name = "99 Rocks",
		Description = `Gives you a full stack of rocks.`,
		Icon = TokenIcon,
		InfoIcon = "rbxassetid://15614005732",
		IconColor = TokenIconColor,
		BackgroundColor = TokenBackgroundColor,
		Cost = 200,
	},
	["99 Cloth"] = {
		Name = "99 Cloth",
		Description = `Gives you a full stack of cloth.`,
		Icon = TokenIcon,
		InfoIcon = "rbxassetid://15614005732",
		IconColor = TokenIconColor,
		BackgroundColor = TokenBackgroundColor,
		Cost = 200,
	},
	["99 Metal"] = {
		Name = "99 Metal",
		Description = `Gives you a full stack of metal.`,
		Icon = TokenIcon,
		InfoIcon = "rbxassetid://15614005732",
		IconColor = TokenIconColor,
		BackgroundColor = TokenBackgroundColor,
		Cost = 200,
	},
	["99 Plastic"] = {
		Name = "99 Plastic",
		Description = `Gives you a full stack of plastic.`,
		Icon = TokenIcon,
		InfoIcon = "rbxassetid://15614005732",
		IconColor = TokenIconColor,
		BackgroundColor = TokenBackgroundColor,
		Cost = 200,
	},
	["500 Building Materials"] = {
		Name = "500 Building Materials",
		Description = `Gives you 500 building materials.`,
		Icon = TokenIcon,
		InfoIcon = "rbxassetid://15614005732",
		IconColor = TokenIconColor,
		BackgroundColor = TokenBackgroundColor,
		Cost = 200,
		LayoutOrder = -1,
	},
}
return module
