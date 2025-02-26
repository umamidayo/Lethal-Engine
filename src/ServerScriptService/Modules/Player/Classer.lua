local classDataTemplate = {
	CurrentClass = "Survivor",
	Survivor = {
		Level = 1,
		Experience = 0,
		PerkPoints = 0,
		Perks = {},
	},
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ProfileService = require(ServerScriptService.Modules.ProfileService)
local ClassDataStore = ProfileService.GetProfileStore("ClassData", classDataTemplate)
local store = require(ReplicatedStorage.Common.Store)
local PlayerClasses = ServerScriptService.Modules.Player.Classes

local module = {}
module.__index = module

module.LEVELING_XP_REQUIREMENT = 20
module.LEVELING_XP_EXPONENT = 2

module.mainClasser = nil

-- Creates a new player class assigner object.
function module.new()
	local self = setmetatable({}, module)
	self.classDataStore = ClassDataStore
	self.profiles = {}
	self.classes = {}
	for _, class in PlayerClasses:GetChildren() do
		if not class:IsA("ModuleScript") then
			continue
		end
		self.classes[class.Name] = require(class)
	end
	return self
end

-- Sets up the player's profile and returns the profile and player's class states.
function module:setup(player: Player)
	self.profiles[player.Name] = self.classDataStore:LoadProfileAsync(`Player_{player.UserId}`)
	assert(self.profiles[player.Name], `Failed to load profile for player {player.Name}`)
	self.profiles[player.Name]:Reconcile()
	self.profiles[player.Name]:ListenToRelease(function()
		self.profiles[player.Name] = nil
	end)

	-- Getting their profile data
	local profile = self.profiles[player.Name]
	local className = profile.Data.CurrentClass
	local level = profile.Data[className].Level or 1
	local experience = profile.Data[className].Experience or 0
	local perkpoints = profile.Data[className].PerkPoints or 0
	local perks = profile.Data[className].Perks or {}

	-- Making sure their perk points are correct
	if #perks < level then
		profile.Data[className].PerkPoints = level - #perks
	end
	perkpoints = profile.Data[className].PerkPoints

	-- Getting their classes from the profile
	local classes = {}
	for clss, _ in profile.Data do
		if clss ~= "CurrentClass" then
			table.insert(classes, clss)
		end
	end

	store:dispatch({
		type = "SETUP_PLAYER",
		userId = player.UserId,
		className = className,
		level = level,
		experience = experience,
		requiredExperience = (level + 1) * module.LEVELING_XP_REQUIREMENT * (level + 1) ^ module.LEVELING_XP_EXPONENT,
		perkpoints = perkpoints,
		perks = perks,
		classes = classes,
	})

	return self.profiles[player.Name]
end

-- Returns the player's profile.
function module:getProfile(player: Player): { any }
	local profile = self.profiles[player.Name]
	assert(profile, `Player {player.Name} does not have a profile`)
	return profile
end

-- Adds a new class to the player's profile and returns it.
function module:setClass(player: Player, class: string)
	local profile = self:getProfile(player)
	assert(self.classes[class], `Class {class} does not exist`)
	profile.Data.CurrentClass = class

	-- Checking if they actually own the class
	if not profile.Data[class] then
		profile.Data[class] = {
			Level = 1,
			Experience = 0,
			PerkPoints = 0,
			Perks = {},
		}
	end

	-- Getting the profile data
	local className = profile.Data.CurrentClass
	local level = profile.Data[className].Level
	local experience = profile.Data[className].Experience
	local perks = profile.Data[className].Perks or {}

	-- Making sure their perk points are correct
	if #perks < level then
		profile.Data[className].PerkPoints = level - #perks
	end
	local perkpoints = profile.Data[className].PerkPoints

	-- Getting their classes from the profile
	local classes = {}
	for clss, _ in profile.Data do
		if clss ~= "CurrentClass" then
			table.insert(classes, clss)
		end
	end

	store:dispatch({
		type = "SETUP_PLAYER",
		userId = player.UserId,
		className = className,
		level = level,
		experience = experience,
		requiredExperience = (level + 1) * module.LEVELING_XP_REQUIREMENT * (level + 1) ^ module.LEVELING_XP_EXPONENT,
		perkpoints = perkpoints,
		perks = {},
		classes = classes,
	})

	return profile.Data[class]
end

function module:hasClass(player: Player, class: string): boolean
	local profile = self:getProfile(player)
	for className, _ in profile.Data do
		if className == class then
			return true
		end
	end
end

function module:addClass(player: Player, class: string)
	local profile = self:getProfile(player)
	assert(not self:hasClass(player, class), `Player {player.Name} already has class {class}`)

	profile.Data[class] = {
		Level = 1,
		Experience = 0,
		PerkPoints = 0,
		Perks = {},
	}

	store:dispatch({
		type = "ADD_CLASS",
		userId = player.UserId,
		class = class,
	})
	return profile.Data[class]
end

function module:saveClassData(player: Player)
	local profile = self:getProfile(player)
	if profile and profile:IsActive() then
		profile:Save()
		return true
	end
end

return module
