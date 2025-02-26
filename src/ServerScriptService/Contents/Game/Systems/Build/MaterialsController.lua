local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local Materials = require(ServerScriptService.Modules.Build.Materials_Module)
local DataStore2 = require(ServerScriptService.Modules.DataStore2)

local MATERIALS_FOLDER = workspace.Materials
local MATERIAL_SOUNDS = SoundService.MatSounds:GetChildren()
local MATERIALS_GAMEPASS = 252800553
local COLLECTION_DISTANCE = 10
local COLLECTION_DURATION = 2.5
local RESPAWN_TIME = 300 -- 5 minutes
local BONUS_MULTIPLIER = 1.25

local hasGamepass = {}

local function createCollectionTrigger(material: Model)
	local trigger = Instance.new("ProximityPrompt")
	trigger.MaxActivationDistance = COLLECTION_DISTANCE
	trigger.RequiresLineOfSight = false
	trigger.ActionText = "Collect Build Materials"
	trigger.HoldDuration = COLLECTION_DURATION
	trigger.Parent = material.PrimaryPart

	trigger.Triggered:Connect(function(player: Player)
		if material.Parent ~= MATERIALS_FOLDER then
			return
		end

		local amount = material:GetAttribute("Materials")
		if hasGamepass[player.UserId] then
			amount = math.floor(amount * BONUS_MULTIPLIER + 0.5)
		end

		Materials.Increment(player, amount)
		local materialsStore = DataStore2("Materials", player)
		materialsStore:Increment(amount)

		local sound = MATERIAL_SOUNDS[math.random(1, #MATERIAL_SOUNDS)]:Clone()
		sound.Parent = player.Character.PrimaryPart
		sound:Play()
		sound:Destroy()

		material.Parent = nil
		task.wait(RESPAWN_TIME)
		material.Parent = MATERIALS_FOLDER
	end)
end

local module = {}

function module.init()
	Players.PlayerAdded:Connect(function(player)
		if MarketplaceService:UserOwnsGamePassAsync(player.UserId, MATERIALS_GAMEPASS) then
			hasGamepass[player.UserId] = true
		end
	end)

	for _, material in MATERIALS_FOLDER:GetChildren() do
		createCollectionTrigger(material)
	end
end

return module
