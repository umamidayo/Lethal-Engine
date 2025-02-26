local module = {
	["Small Stomach"] = {
		Name = "Small Stomach",
		Description = `Hunger and thirst rates are reduced by <font color="rgb(150, 150, 210)">20%</font>.`,
		Tier = 1,
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("EnergyConservative") then
				character:SetAttribute("EnergyConservative", character:GetAttribute("EnergyConservative") + 20)
			else
				character:SetAttribute("EnergyConservative", 20)
			end
		end,
	},
	["Lucky Looter"] = {
		Name = "Lucky Looter",
		Description = `Resources have a <font color="rgb(150, 150, 210)">10%</font> chance of giving double the amount.`,
		Tier = 1,
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("Scavenger") then
				character:SetAttribute("Scavenger", character:GetAttribute("Scavenger") + 10)
			else
				character:SetAttribute("Scavenger", 10)
			end
		end,
	},
	["Strength Training"] = {
		Name = "Strength Training",
		Description = `Health is increased by <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 1,
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("BonusHealth") then
				character:SetAttribute("BonusHealth", character:GetAttribute("BonusHealth") + 0.10)
			else
				character:SetAttribute("BonusHealth", 1.10)
			end
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")
			if not humanoid then
				return
			end
			humanoid.MaxHealth = humanoid.MaxHealth * character:GetAttribute("BonusHealth")
		end,
	},
	["Aim training"] = {
		Name = "Aim training",
		Description = `Bullet damage is increased by <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 1,
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("DamageBonus") then
				character:SetAttribute("DamageBonus", character:GetAttribute("DamageBonus") + 10)
			else
				character:SetAttribute("DamageBonus", 10)
			end
		end,
	},
	["Escape Artist"] = {
		Name = "Escape Artist",
		Description = `Sprint speed is increased by <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 2,
		Requirements = { "Lucky Looter", "Strength Training" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("PerkWalkSpeed") then
				character:SetAttribute("PerkWalkSpeed", character:GetAttribute("PerkWalkSpeed") + 10)
			else
				character:SetAttribute("PerkWalkSpeed", 10)
			end
		end,
	},
	["Health Freak"] = {
		Name = "Health Freak",
		Description = `Health is increased by another <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 2,
		Requirements = { "Strength Training" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("BonusHealth") then
				character:SetAttribute("BonusHealth", character:GetAttribute("BonusHealth") + 0.10)
			else
				character:SetAttribute("BonusHealth", 1.10)
			end
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")
			if not humanoid then
				return
			end
			humanoid.MaxHealth = humanoid.MaxHealth * character:GetAttribute("BonusHealth")
		end,
	},
	["Analyze weakspots"] = {
		Name = "Analyze weakspots",
		Description = `Melee damage is increased by <font color="rgb(150, 150, 210)">25%</font>.`,
		Tier = 2,
		Requirements = { "Aim training" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("MeleeDamageBonus") then
				character:SetAttribute("MeleeDamageBonus", character:GetAttribute("MeleeDamageBonus") + 25)
			else
				character:SetAttribute("MeleeDamageBonus", 25)
			end
		end,
	},
	-- ["Cold resistance"] = {
	--     Name = "Cold resistance",
	--     Description = `Cold temperature toleration increased by <font color="rgb(150, 150, 210)">15%</font>. Cooling rate becomes slower when close to freezing.`,
	--     Tier = 2,
	--     Requirements = {"Small Stomach", "Strength Training"},
	--     PerkFunction = function(player: Player)
	--         local character = player.Character
	--         if not character then return end
	--         if character:GetAttribute("ColdResistance") then
	--             character:SetAttribute("ColdResistance", character:GetAttribute("ColdResistance") + 15)
	--         else
	--             character:SetAttribute("ColdResistance", 15)
	--         end
	--     end,
	-- },
	["Perfect running form"] = {
		Name = "Perfect running form",
		Description = `Sprint speed is increased by another <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 3,
		Requirements = { "Escape Artist", "Health Freak" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("PerkWalkSpeed") then
				character:SetAttribute("PerkWalkSpeed", character:GetAttribute("PerkWalkSpeed") + 10)
			else
				character:SetAttribute("PerkWalkSpeed", 10)
			end
		end,
	},
	["Genetic modifications"] = {
		Name = "Genetic modifications",
		Description = `Health is increased by another <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 3,
		Requirements = { "Health Freak" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("BonusHealth") then
				character:SetAttribute("BonusHealth", character:GetAttribute("BonusHealth") + 0.10)
			else
				character:SetAttribute("BonusHealth", 1.10)
			end
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")
			if not humanoid then
				return
			end
			humanoid.MaxHealth = humanoid.MaxHealth * character:GetAttribute("BonusHealth")
		end,
	},
	["Armor piercing bullets"] = {
		Name = "Armor piercing bullets",
		Description = `Bullet damage is increased by another <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 3,
		Requirements = { "Analyze weakspots" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("DamageBonus") then
				character:SetAttribute("DamageBonus", character:GetAttribute("DamageBonus") + 10)
			else
				character:SetAttribute("DamageBonus", 10)
			end
		end,
	},
	["Rabbit's foot"] = {
		Name = "Rabbit's foot",
		Description = `Gain another <font color="rgb(150, 150, 210)">10%</font> chance of resources giving double the amount.`,
		Tier = 3,
		Requirements = { "Escape Artist" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("Scavenger") then
				character:SetAttribute("Scavenger", character:GetAttribute("Scavenger") + 10)
			else
				character:SetAttribute("Scavenger", 10)
			end
		end,
	},
	["Tired of eating"] = {
		Name = "Tired of eating",
		Description = `Hunger and thirst rates are reduced by <font color="rgb(150, 150, 210)">20%</font>.`,
		Tier = 3,
		Requirements = { "Small Stomach" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("EnergyConservative") then
				character:SetAttribute("EnergyConservative", character:GetAttribute("EnergyConservative") + 20)
			else
				character:SetAttribute("EnergyConservative", 20)
			end
		end,
	},
	["Actual Supermutant"] = {
		Name = "Actual Supermutant",
		Description = `Health is increased by another <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 4,
		Requirements = { "Genetic modifications" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("BonusHealth") then
				character:SetAttribute("BonusHealth", character:GetAttribute("BonusHealth") + 0.10)
			else
				character:SetAttribute("BonusHealth", 1.10)
			end
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")
			if not humanoid then
				return
			end
			humanoid.MaxHealth = humanoid.MaxHealth * character:GetAttribute("BonusHealth")
		end,
	},
	["Slice and dice"] = {
		Name = "Slice and dice",
		Description = `Melee damage is increased by <font color="rgb(150, 150, 210)">25%</font>.`,
		Tier = 4,
		Requirements = { "Armor piercing bullets" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("MeleeDamageBonus") then
				character:SetAttribute("MeleeDamageBonus", character:GetAttribute("MeleeDamageBonus") + 25)
			else
				character:SetAttribute("MeleeDamageBonus", 25)
			end
		end,
	},
	-- ["Heat resistance"] = {
	--     Name = "Heat resistance",
	--     Description = `Heat temperature toleration increased by <font color="rgb(150, 150, 210)">15%</font>. Heating rate becomes slower when close to overheating.`,
	--     Tier = 4,
	--     Requirements = {"Cold resistance", "Genetic modifications"},
	--     PerkFunction = function(player: Player)
	--         local character = player.Character
	--         if not character then return end
	--         if character:GetAttribute("HeatResistance") then
	--             character:SetAttribute("HeatResistance", character:GetAttribute("HeatResistance") + 15)
	--         else
	--             character:SetAttribute("HeatResistance", 15)
	--         end
	--     end,
	-- },
	["Pain is for the weak"] = {
		Name = "Pain is for the weak",
		Description = `Damage taken is reduced by <font color="rgb(150, 150, 210)">25%</font>.`,
		Tier = 5,
		Requirements = { "Actual Supermutant", "Perfect running form" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("DamageResistance") then
				character:SetAttribute("DamageResistance", character:GetAttribute("DamageResistance") + 25)
			else
				character:SetAttribute("DamageResistance", 25)
			end
		end,
	},
	["Trigger Happy"] = {
		Name = "Trigger Happy",
		Description = `Bullet damage is increased by <font color="rgb(150, 150, 210)">25%</font>.`,
		Tier = 5,
		Requirements = { "Rabbit's foot", "Slice and dice" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("DamageBonus") then
				character:SetAttribute("DamageBonus", character:GetAttribute("DamageBonus") + 25)
			else
				character:SetAttribute("DamageBonus", 25)
			end
		end,
	},
	["Photosynthesis"] = {
		Name = "Photosynthesis",
		Description = `Completely remove the need to consume food.`,
		Tier = 5,
		Requirements = { "Tired of eating", "Genetic modifications" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			character:SetAttribute("EnergyConservative", 100)
		end,
	},
	["Double Ace"] = {
		Name = "Double Ace",
		Description = `Gain another <font color="rgb(150, 150, 210)">10%</font> chance of resources giving double the amount.`,
		Tier = 5,
		Requirements = { "Rabbit's foot", "Analyze weakspots" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("Scavenger") then
				character:SetAttribute("Scavenger", character:GetAttribute("Scavenger") + 10)
			else
				character:SetAttribute("Scavenger", 10)
			end
		end,
	},
}

return module
