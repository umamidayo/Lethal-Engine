local Jobs = {
	[1] = {
		Name = "Crafting: Empty Bottle",
		Description = "Obtain 3 plastic and craft an empty bottle for storing water. Use the crafting menu to craft items.",
		Type = "Item",
		Item = "Empty Bottle",
		CashReward = math.random(50, 100),
		Completed = function(player: Player)
			return player.Backpack:FindFirstChild("Empty Bottle")
		end,
	},

	[2] = {
		Name = "Crafting: Build Shovel",
		Description = "Obtain 4 sticks and 1 metal and craft a build shovel for building a shelter. Use the crafting menu to craft items.",
		Type = "Item",
		Item = "Build Shovel",
		CashReward = math.random(60, 120),
		Completed = function(player: Player)
			return player.Backpack:FindFirstChild("Build Shovel")
		end,
	},

	[3] = {
		Name = "Cooking: Cooked Meat",
		Description = "Hunt a deer for raw meat and cook it with a cooking pot to make cooked meat. Must be near a campfire. Use the crafting menu to cook items.",
		Type = "Item",
		Item = "Cooked Meat",
		CashReward = math.random(100, 150),
		Completed = function(player: Player)
			return player.Backpack:FindFirstChild("Cooked Meat")
		end,
	},

	[4] = {
		Name = "Cooking: Water Bottle",
		Description = "Obtain dirty water from a water source and boil the water with a cooking pot to make clean water. Must be near a campfire. Use the crafting menu to cook items.",
		Type = "Item",
		Item = "Water Bottle",
		CashReward = math.random(120, 170),
		Completed = function(player: Player)
			return player.Backpack:FindFirstChild("Water Bottle")
		end,
	},
	
	[5] = {
		Name = "Foraging: Blueberries",
		Description = "Obtain a blueberry by finding and foraging a blueberry plant.",
		Type = "Item",
		Item = "Blueberries",
		CashReward = math.random(40, 80),
		Completed = function(player: Player)
			return player.Backpack:FindFirstChild("Blueberries")
		end,
	},
	
	[6] = {
		Name = "Weapons: M870",
		Description = "Obtain the M870 shotgun from a Workbench or a weapon crate. Use the user interface on the Workbench to get weapons. Weapon crates can be found all around the map.",
		Type = "Item",
		Item = "M870",
		CashReward = math.random(100, 250),
		Completed = function(player: Player)
			return player.Backpack:FindFirstChild("M870")
		end,
	},
	
	[7] = {
		Name = "Weapons: Ray Gun",
		Description = "Obtain the Ray Gun from a weapon crate. Weapon crates can be found all around the map.",
		Type = "Item",
		Item = "Ray Gun",
		CashReward = math.random(100, 250),
		Completed = function(player: Player)
			return player.Backpack:FindFirstChild("Ray Gun")
		end,
	},
	
	[8] = {
		Name = "Weapons: AK-47",
		Description = "Obtain the AK-47 from a weapon crate. Use the user interface on the Workbench to get weapons. Weapon crates can be found all around the map.",
		Type = "Item",
		Item = "AK-47",
		CashReward = math.random(100, 250),
		Completed = function(player: Player)
			return player.Backpack:FindFirstChild("AK-47")
		end,
	},
	
	[9] = {
		Name = "Weapons: M240",
		Description = "Obtain the M240 from a weapon crate. Use the user interface on the Workbench to get weapons. Weapon crates can be found all around the map.",
		Type = "Item",
		Item = "M240",
		CashReward = math.random(100, 250),
		Completed = function(player: Player)
			return player.Backpack:FindFirstChild("M240")
		end,
	},
	
	[10] = {
		Name = "Crafting: Medkit",
		Description = "Obtain the Hide Glue material by using the crafting menu. Obtain 4 Cloth by picking them up. Craft a Medkit using the materials obtained. Craft the Medkit from a Workbench.",
		Type = "Item",
		Item = "Medkit",
		CashReward = math.random(250, 300),
		Completed = function(player: Player)
			return player.Backpack:FindFirstChild("Medkit")
		end,
	},
	
	[11] = {
		Name = "Crafting: Repair Hammer",
		Description = "Obtain 6 rocks and 3 sticks. Craft a Repair Hammer using the materials obtained. Craft the Repair Hammer from a Workbench.",
		Type = "Item",
		Item = "Repair Hammer",
		CashReward = math.random(60, 100),
		Completed = function(player: Player)
			return player.Backpack:FindFirstChild("Repair Hammer")
		end,
	},
	
	[12] = {
		Name = "Weapons: Double Barrel",
		Description = "Obtain the Double Barrel from a weapon crate. Use the user interface on the Workbench to get weapons. Weapon crates can be found all around the map.",
		Type = "Item",
		Item = "Double Barrel",
		CashReward = math.random(100, 250),
		Completed = function(player: Player)
			return player.Backpack:FindFirstChild("Double Barrel")
		end,
	},
	
	[13] = {
		Name = "Weapons: Magnum Revolver",
		Description = "Obtain the Magnum Revolver from a weapon crate. Use the user interface on the Workbench to get weapons. Weapon crates can be found all around the map.",
		Type = "Item",
		Item = "Magnum Revolver",
		CashReward = math.random(100, 250),
		Completed = function(player: Player)
			return player.Backpack:FindFirstChild("Magnum Revolver")
		end,
	},
}

function Jobs.deepCopy(original)
	local copy = {}

	for k,v in pairs(original) do
		if type(v) == "table" then
			v = Jobs.deepCopy(v)
		end
		copy[k] = v
	end

	return copy
end

function Jobs.fixDuplicateJobs(jobs)
	local uniqueJobs = {}
	local duplicateJobs = {}
	
	for i,job in jobs do
		if not table.find(uniqueJobs, job) then
			table.insert(uniqueJobs, job)
		else
			table.insert(duplicateJobs, job)
		end
	end
	
	for i,job in duplicateJobs do
		repeat
			job = Jobs[math.random(1, #Jobs)]
			if not table.find(uniqueJobs, job) then
				table.insert(uniqueJobs, job)
				table.remove(duplicateJobs, i)
			end
			task.wait()
		until #duplicateJobs == 0
	end

	return uniqueJobs
end

return Jobs
