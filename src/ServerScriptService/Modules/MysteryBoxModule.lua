local module = {}

local storage = game.ServerStorage.Tools

module.Weapons = {
	["Double Barrel"] = {
		["Chance"] = 10,
	},
	
	["Ray Gun"] = {
		["Chance"] = 3,
	},
	
	["M40A5"] = {
		["Chance"] = 6,
	},
	
	["Minigun"] = {
		["Chance"] = 1,
	},
	
	["Magnum Revolver"] = {
		["Chance"] = 8,
	},
	
	["M240"] = {
		["Chance"] = 10,
	},
	
	["LAR-15"] = {
		["Chance"] = 20,
	},
	
	["AK-47"] = {
		["Chance"] = 35,
	},
	
	["AS VAL"] = {
		["Chance"] = 50,
	},
	
	["Kar98K"] = {
		["Chance"] = 75,
	},
	
	["M870"] = {
		["Chance"] = 80,
	},
}

module.Food = {
	["Canned Food"] = {
		["Chance"] = 80,
	},
	
	["Dirty Water Bottle"] = {
		["Chance"] = 40,
	},
	
	["Water Bottle"] = {
		["Chance"] = 25,
	},
	
	["Empty Bottle"] = {
		["Chance"] = 60,
	},
	
	["Rotten Meat"] = {
		["Chance"] = 60
	},
	
	["Cooked Meat"] = {
		["Chance"] = 25,
	},
	
	["Medkit"] = {
		["Chance"] = 5,
	},
	
	["Bandage"] = {
		["Chance"] = 10,
	},
}

function module.GetRandomWeapon()
	local chance = math.random(1, 100)
	local weapons = {}
	local weapon = nil
	
	for itemName,data in module.Weapons do
		for i = 1, data.Chance do
			table.insert(weapons, itemName)
		end
	end
	
	weapon = weapons[math.random(1, #weapons)]
	
	return storage:FindFirstChild(weapon):Clone()
end

function module.GetRandomFood()
	local chance = math.random(1, 100)
	local foods = {}
	local food = nil
	
	for itemName,data in module.Food do
		for i = 1, data.Chance do
			table.insert(foods, itemName)
		end
	end
	
	food = foods[math.random(1, #foods)]
	
	return storage:FindFirstChild(food):Clone()
end

return module
