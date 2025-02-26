local function getDate(data)
	local date = DateTime.fromLocalTime(data.year, data.month, data.day, data.hour, data.minute)
	return tostring(date:FormatLocalTime("LLL", "en-us"))
end

local UpdateLogData = {
	icons = {
		new = "rbxassetid://15614005083",
		changes = "rbxassetid://15612371702",
		fixes = "rbxassetid://15612276715",
	},
	iconColors = {
		new = Color3.fromRGB(38, 155, 69),
		changes = Color3.fromRGB(209, 154, 51),
		fixes = Color3.fromRGB(47, 84, 184),
	},
	version = "9.8c",
	date = getDate({
		year = 2025,
		month = 2,
		day = 25,
		hour = 6,
		minute = 50,
	}),
	new = {
		"Added an Update Log to keep you updated on the development progress.",
		"Added Reset Perk button to the Perks menu.",
	},
	changes = {
		"The overhead display will now show the status of the player's data (Loading...) instead of nil.",
	},
	fixes = {
		"Fixed tools and controls not working after respawning.",
		"Improved performance for the Perks info tooltip.",
		"Attempted patch to fix missing player data on the overhead display.",
	},
}

return UpdateLogData
