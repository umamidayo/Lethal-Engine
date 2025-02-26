local module = {
	["Masked up"] = {
		Name = "Masked up",
		Description = `Health is increased by <font color="rgb(150, 150, 210)">5%</font>.`,
		Tier = 1,
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("BonusHealth") then
				character:SetAttribute("BonusHealth", character:GetAttribute("BonusHealth") + 0.05)
			else
				character:SetAttribute("BonusHealth", 1.05)
			end
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")
			if not humanoid then
				return
			end
			humanoid.MaxHealth = humanoid.MaxHealth * character:GetAttribute("BonusHealth")
		end,
	},
	["Dissect"] = {
		Name = "Dissect",
		Description = `Melee damage is increased by <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 1,
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("MeleeDamageBonus") then
				character:SetAttribute("MeleeDamageBonus", character:GetAttribute("MeleeDamageBonus") + 10)
			else
				character:SetAttribute("MeleeDamageBonus", 10)
			end
		end,
	},
	["Emergency rush"] = {
		Name = "Emergency rush",
		Description = `Sprint speed is increased by <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 1,
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
	["First aid"] = {
		Name = "First aid",
		Description = `Healing is <font color="rgb(150, 150, 210)">15%</font> more effective on other players.`,
		Tier = 1,
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("HealingBonus") then
				character:SetAttribute("HealingBonus", character:GetAttribute("HealingBonus") + 0.12)
			else
				character:SetAttribute("HealingBonus", 0.12)
			end
		end,
	},
	["Pain relief"] = {
		Name = "Pain relief",
		Description = `Damage taken is reduced by <font color="rgb(150, 150, 210)">5%</font>.`,
		Tier = 2,
		Requirements = { "Masked up" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("DamageResistance") then
				character:SetAttribute("DamageResistance", character:GetAttribute("DamageResistance") + 5)
			else
				character:SetAttribute("DamageResistance", 5)
			end
		end,
	},
	["I am a surgeon"] = {
		Name = "I am a surgeon",
		Description = `Melee damage is increased by <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 2,
		Requirements = { "Dissect" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("MeleeDamageBonus") then
				character:SetAttribute("MeleeDamageBonus", character:GetAttribute("MeleeDamageBonus") + 10)
			else
				character:SetAttribute("MeleeDamageBonus", 10)
			end
		end,
	},
	-- ["Cold resistance"] = {
	-- 	Name = "Cold resistance",
	-- 	Description = `Cold temperature toleration increased by <font color="rgb(150, 150, 210)">15%</font>. Cooling rate becomes slower when close to freezing.`,
	-- 	Tier = 2,
	-- 	Requirements = { "Masked up" },
	-- 	PerkFunction = function(player: Player)
	-- 		local character = player.Character
	-- 		if not character then
	-- 			return
	-- 		end
	-- 		if character:GetAttribute("ColdResistance") then
	-- 			character:SetAttribute("ColdResistance", character:GetAttribute("ColdResistance") + 15)
	-- 		else
	-- 			character:SetAttribute("ColdResistance", 15)
	-- 		end
	-- 	end,
	-- },
	-- ["Heat resistance"] = {
	--     Name = "Heat resistance",
	--     Description = `Heat temperature toleration increased by <font color="rgb(150, 150, 210)">15%</font>. Heating rate becomes slower when close to overheating.`,
	--     Tier = 2,
	--     Requirements = {"Masked up"},
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
	["Paramedic"] = {
		Name = "Paramedic",
		Description = `Sprint speed is increased by <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 3,
		Requirements = { "I am a surgeon", "Emergency rush" },
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
	["Dr. Klein's intern"] = {
		Name = "Dr. Klein's intern",
		Description = `Health is increased by <font color="rgb(150, 150, 210)">5%</font>.`,
		Tier = 3,
		Requirements = { "Pain relief" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("BonusHealth") then
				character:SetAttribute("BonusHealth", character:GetAttribute("BonusHealth") + 0.05)
			else
				character:SetAttribute("BonusHealth", 1.05)
			end
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")
			if not humanoid then
				return
			end
			humanoid.MaxHealth = humanoid.MaxHealth * character:GetAttribute("BonusHealth")
		end,
	},
	["Medical training"] = {
		Name = "Medical training",
		Description = `Healing is <font color="rgb(150, 150, 210)">35%</font> more effective on other players.`,
		Tier = 3,
		Requirements = { "First aid", "Pain relief" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("HealingBonus") then
				character:SetAttribute("HealingBonus", character:GetAttribute("HealingBonus") + 0.35)
			else
				character:SetAttribute("HealingBonus", 0.35)
			end
		end,
	},
	["Anatomy doctor"] = {
		Name = "Anatomy doctor",
		Description = `Melee damage is increased by <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 3,
		Requirements = { "I am a surgeon" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("MeleeDamageBonus") then
				character:SetAttribute("MeleeDamageBonus", character:GetAttribute("MeleeDamageBonus") + 10)
			else
				character:SetAttribute("MeleeDamageBonus", 10)
			end
		end,
	},
	["On a scale from 1 to 10"] = {
		Name = "On a scale from 1 to 10",
		Description = `Damage taken is reduced by <font color="rgb(150, 150, 210)">5%</font>.`,
		Tier = 4,
		Requirements = { "Dr. Klein's intern" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("DamageResistance") then
				character:SetAttribute("DamageResistance", character:GetAttribute("DamageResistance") + 5)
			else
				character:SetAttribute("DamageResistance", 5)
			end
		end,
	},
	["Superman"] = {
		Name = "Superman",
		Description = `Sprint speed is increased by <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 4,
		Requirements = { "Paramedic" },
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
	["Combat medic"] = {
		Name = "Combat medic",
		Description = `Melee damage is increased by <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 4,
		Requirements = { "Anatomy doctor" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("MeleeDamageBonus") then
				character:SetAttribute("MeleeDamageBonus", character:GetAttribute("MeleeDamageBonus") + 10)
			else
				character:SetAttribute("MeleeDamageBonus", 10)
			end
		end,
	},
	["Free health insurance"] = {
		Name = "Free health insurance",
		Description = `Health regenerates by <font color="rgb(150, 150, 210)">2</font> HP every second for anyone within a <font color="rgb(150, 150, 210)">10</font> unit radius.`,
		Tier = 5,
		Requirements = { "On a scale from 1 to 10", "Medical training" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			character:AddTag("HealthRegenAOE")
		end,
	},
	["The best doctor ever"] = {
		Name = "The best doctor ever",
		Description = `Healing is <font color="rgb(150, 150, 210)">35%</font> more effective on other players.`,
		Tier = 5,
		Requirements = { "Medical training", "Superman" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("HealingBonus") then
				character:SetAttribute("HealingBonus", character:GetAttribute("HealingBonus") + 0.35)
			else
				character:SetAttribute("HealingBonus", 0.35)
			end
		end,
	},
	["Vampirism"] = {
		Name = "Vampirism",
		Description = `Melee damage applies lifesteal by <font color="rgb(150, 150, 210)">15%</font>.`,
		Tier = 5,
		Requirements = { "Combat medic", "Medical training" },
		PerkFunction = function(player: Player)
			local character = player.Character
			if not character then
				return
			end
			if character:GetAttribute("LifeSteal") then
				character:SetAttribute("LifeSteal", character:GetAttribute("LifeSteal") + 0.15)
			else
				character:SetAttribute("LifeSteal", 0.15)
			end
		end,
	},
}

return module
