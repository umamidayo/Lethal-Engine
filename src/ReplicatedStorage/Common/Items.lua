export type ItemInfo = {
	Name: string,
	MaxQuantity: number,
	Ingredients: { string },
	BuildRequired: string,
	Tags: { string },
}

local module = {

	-- Tools

	["Build Shovel"] = {
		Name = "Build Shovel",

		MaxQuantity = 1,

		Ingredients = {
			["Rock"] = 2,
			["Stick"] = 3,
		},

		Tags = { "Tools" },
	},

	["Repair Hammer"] = {
		Name = "Repair Hammer",

		MaxQuantity = 1,

		Ingredients = {
			["Rock"] = 2,
			["Stick"] = 2,
		},

		BuildRequired = "Workbench",

		Tags = { "Tools" },
	},

	["Cooking Pot"] = {
		Name = "Cooking Pot",

		MaxQuantity = 1,

		Ingredients = {
			["Metal"] = 4,
		},

		BuildRequired = "Workbench",

		Tags = { "Tools", "NoTool" },
	},

	["MK18"] = {
		Name = "MK18",

		MaxQuantity = 1,

		Ingredients = {
			["Gun Metal"] = 4,
			["Gunpowder"] = 2,
		},

		BuildRequired = "Workbench",

		Tags = { "Tools" },
	},

	["Wiring Tool"] = {
		Name = "Wiring Tool",

		MaxQuantity = 1,

		Ingredients = {
			["Plastic"] = 1,
			["Metal"] = 1,
		},

		BuildRequired = "Workbench",

		Tags = { "Tools" },
	},

	["Kodachi"] = {
		Name = "Kodachi",

		MaxQuantity = 1,

		Ingredients = {
			["Metal"] = 4,
			["Hide Glue"] = 1,
			["Stick"] = 2,
		},

		BuildRequired = "Workbench",

		Tags = { "Tools" },
	},

	-- Rations

	["Empty Bottle"] = {
		Name = "Empty Bottle",

		MaxQuantity = 99,

		Ingredients = {
			["Plastic"] = 2,
		},

		Tags = { "Tools" },
	},

	["Cooked Meat"] = {
		Name = "Cooked Meat",

		MaxQuantity = 99,

		Ingredients = {
			["Raw Meat"] = 1,
		},

		BuildRequired = "Campfire",

		Tags = { "Rations" },
	},

	["Blueberry Pie"] = {
		Name = "Blueberry Pie",

		MaxQuantity = 99,

		Ingredients = {
			["Blueberries"] = 2,
			["Aluminium Container"] = 1,
			["Sugar"] = 1,
		},

		BuildRequired = "Campfire",

		Tags = { "Rations" },
	},

	["Blueberry Snack"] = {
		Name = "Blueberry Snack",

		MaxQuantity = 99,

		Ingredients = {
			["Blueberries"] = 1,
		},

		Tags = { "Rations" },
	},

	["Water Bottle"] = {
		Name = "Water Bottle",

		MaxQuantity = 99,

		Ingredients = {
			["Dirty Water Bottle"] = 1,
		},

		BuildRequired = "Campfire",

		Tags = { "Rations" },
	},

	["Energy Drink"] = {
		Name = "Energy Drink",

		MaxQuantity = 99,

		Ingredients = {
			["Metal"] = 1,
			["Water Bottle"] = 1,
			["Sugar"] = 1,
			["Blueberries"] = 1,
		},

		BuildRequired = "Campfire",

		Tags = { "Rations" },
	},

	-- Medical

	["Bandage"] = {
		Name = "Bandage",

		MaxQuantity = 99,

		Ingredients = {
			["Cloth"] = 2,
		},

		Tags = { "Medical" },
	},

	["Medkit"] = {
		Name = "Medkit",

		MaxQuantity = 99,

		Ingredients = {
			["Cloth"] = 4,
			["Hide Glue"] = 1,
		},

		BuildRequired = "Workbench",

		Tags = { "Medical" },
	},

	-- Materials

	["Hide Glue"] = {
		Name = "Hide Glue",

		MaxQuantity = 99,

		Ingredients = {
			["Leather"] = 1,
			["Rock"] = 1,
		},

		BuildRequired = "Campfire",

		Tags = { "Materials", "NoTool" },
	},

	["Aluminium Container"] = {
		Name = "Aluminium Container",

		MaxQuantity = 99,

		Ingredients = {
			["Metal"] = 2,
		},

		BuildRequired = "Workbench",

		Tags = { "Materials", "NoTool" },
	},

	["Sugar"] = {
		Name = "Sugar",

		MaxQuantity = 99,

		Ingredients = {
			["Blueberries"] = 1,
			["Water Bottle"] = 1,
		},

		BuildRequired = "Campfire",

		Tags = { "Materials", "NoTool" },
	},

	["Gun Metal"] = {
		Name = "Gun Metal",

		MaxQuantity = 99,

		Ingredients = {
			["Metal"] = 3,
		},

		BuildRequired = "Campfire",

		Tags = { "Materials", "NoTool" },
	},

	["Charcoal"] = {
		Name = "Charcoal",

		MaxQuantity = 99,

		Ingredients = {
			["Stick"] = 2,
		},

		BuildRequired = "Campfire",

		Tags = { "Materials", "NoTool" },
	},

	["Sulfur"] = {
		Name = "Sulfur",

		MaxQuantity = 99,

		Ingredients = {
			["Stick"] = 2,
			["Dirty Water Bottle"] = 1,
		},

		BuildRequired = "Campfire",

		Tags = { "Materials", "NoTool" },
	},

	["Gunpowder"] = {
		Name = "Gunpowder",

		MaxQuantity = 99,

		Ingredients = {
			["Charcoal"] = 1,
			["Sulfur"] = 1,
		},

		BuildRequired = "Campfire",

		Tags = { "Materials", "NoTool" },
	},
}

function module.GetItemInfo(Item: string)
	return module[Item]
end

return module
