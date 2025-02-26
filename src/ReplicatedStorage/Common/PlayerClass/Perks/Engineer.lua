local function addAttribute(player: Player, attributeName: string, value: any)
	local character = player.Character
	if not character then
		return
	end

	if character:GetAttribute(attributeName) then
		character:SetAttribute(attributeName, character:GetAttribute(attributeName) + value)
	else
		character:SetAttribute(attributeName, value)
	end
end

local module = {
	-- Tier 1
	["Rifling"] = {
		Name = "Rifling",
		Description = `Bullet damage is increased by <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 1,
		PerkFunction = function(player: Player)
			addAttribute(player, "DamageBonus", 10)
		end,
	},
	["Cybernetic Implants"] = {
		Name = "Cybernetic Implants",
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

	-- Tier 2
	["Razor Sharp"] = {
		Name = "Razor Sharp",
		Description = `Barbed Wire does <font color="rgb(150, 150, 210)">25%</font> more damage to zombies.`,
		Tier = 2,
		Requirements = { "Cybernetic Implants" },
		PerkFunction = function(player: Player)
			addAttribute(player, "BarbedWireLevel", 1)
		end,
	},
	["Sentry Calibration"] = {
		Name = "Sentry Calibration",
		Description = 'Sentry turret damage increased by <font color="rgb(150, 150, 210)">15%</font>.',
		Tier = 2,
		Requirements = { "Rifling" },
		PerkFunction = function(player: Player)
			addAttribute(player, "SentryLevel", 1)
		end,
	},
	["Shrapnel"] = {
		Name = "Shrapnel",
		Requirements = { "Rifling" },
		Description = 'Explosive traps deal <font color="rgb(150, 150, 210)">25%</font> more damage.',
		Tier = 2,
		PerkFunction = function(player: Player)
			addAttribute(player, "ExplosiveTrapLevel", 1)
		end,
	},

	-- Tier 3
	["Electric Feel"] = {
		Name = "Electric Feel",
		Description = `Barbed Wire will <font color="rgb(150, 150, 210)">chain electrocute</font> zombies on contact for <font color="rgb(150, 150, 210)">25%</font> of their max health.`,
		Tier = 3,
		Requirements = { "Razor Sharp" },
		PerkFunction = function(player: Player)
			addAttribute(player, "BarbedWireLevel", 1)
		end,
	},
	["Burn, Baby, Burn!"] = {
		Name = "Burn, Baby, Burn!",
		Description = `Sentry bullets will ignite zombies and deal <font color="rgb(150, 150, 210)">10%</font> of their max health as damage over time.`,
		Tier = 3,
		Requirements = { "Sentry Calibration" },
		PerkFunction = function(player: Player)
			addAttribute(player, "SentryLevel", 1)
		end,
	},
	["Chemical Reaction"] = {
		Name = "Chemical Reaction",
		Description = `Explosive traps will release a toxic cloud that slows and deals <font color="rgb(150, 150, 210)">5%</font> of a zombie's max health as damage over time.`,
		Tier = 3,
		Requirements = { "Shrapnel" },
		PerkFunction = function(player: Player)
			addAttribute(player, "ExplosiveTrapLevel", 1)
		end,
	},

	-- Tier 4
	["More Gunpowder"] = {
		Name = "More Gunpowder",
		Description = `Bullet damage is increased by another <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 4,
		Requirements = { "Burn, Baby, Burn!" },
		PerkFunction = function(player: Player)
			addAttribute(player, "DamageBonus", 10)
		end,
	},
	["Lethal Gas"] = {
		Name = "Lethal Gas",
		Description = `Upgrades toxic cloud to a lethal gas that slows more and deals <font color="rgb(150, 150, 210)">20%</font> more damage.`,
		Tier = 4,
		Requirements = { "Chemical Reaction" },
		PerkFunction = function(player: Player)
			addAttribute(player, "ExplosiveTrapLevel", 1)
		end,
	},
	["Advanced Blood Circulation"] = {
		Name = "Advanced Blood Circulation",
		Description = `Health is increased by <font color="rgb(150, 150, 210)">10%</font>.`,
		Tier = 4,
		Requirements = { "Electric Feel" },
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

	-- Tier 5
	["Final Detonation"] = {
		Name = "Final Detonation",
		Description = `Barbed Wire's electric range and damage is doubled.`,
		Tier = 5,
		Requirements = { "Advanced Blood Circulation" },
		PerkFunction = function(player: Player)
			addAttribute(player, "BarbedWireLevel", 1)
		end,
	},
	["Wildfire"] = {
		Name = "Wildfire",
		Description = `Ignited zombies have a <font color="rgb(150, 150, 210)">25%</font> chance to spread fire to nearby zombies.`,
		Tier = 5,
		Requirements = { "More Gunpowder" },
		PerkFunction = function(player: Player)
			addAttribute(player, "SentryLevel", 1)
		end,
	},
	["Contagion"] = {
		Name = "Contagion",
		Description = `Lethal Gas has a <font color="rgb(150, 150, 210)">25%</font> chance to spread to nearby zombies.`,
		Tier = 5,
		Requirements = { "Lethal Gas" },
		PerkFunction = function(player: Player)
			addAttribute(player, "ExplosiveTrapLevel", 1)
		end,
	},
}

return module
