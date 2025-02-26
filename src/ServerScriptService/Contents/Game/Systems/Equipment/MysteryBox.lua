local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local MysteryBoxModule = require(ServerScriptService.Modules.MysteryBoxModule)

local WEAPON_COOLDOWN = 300 -- 5 minutes
local FOOD_COOLDOWN = 180 -- 3 minutes
local MAX_DISTANCE = 12

local debounce = {}
local module = {}

local function handleCrateInteraction(
	player: Player,
	crate: Model | BasePart,
	cooldown: number,
	getItem: () -> Instance,
	storage: Folder
)
	if crate.Parent ~= storage then
		return
	end

	if debounce[crate] and (tick() - debounce[crate]) < cooldown then
		return
	end
	debounce[crate] = tick()

	local character = player.Character
	if not character or not character.PrimaryPart then
		return
	end

	local cratePosition = if crate:IsA("Model") then crate:GetPivot().Position else crate.Position
	if (character.PrimaryPart.Position - cratePosition).Magnitude > MAX_DISTANCE then
		return
	end

	local item = getItem()
	item.Parent = player.Backpack

	crate.Parent = ServerStorage
	task.wait(cooldown)
	crate.Parent = storage
end

function module.init()
	for _, crate in workspace.WeaponCrates:GetChildren() do
		crate.MeshPart.ProximityPrompt.Triggered:Connect(function(player)
			handleCrateInteraction(
				player,
				crate,
				WEAPON_COOLDOWN,
				MysteryBoxModule.GetRandomWeapon,
				workspace.WeaponCrates
			)
		end)
	end

	for _, crate in workspace.FoodCrates:GetChildren() do
		crate.ProximityPrompt.Triggered:Connect(function(player)
			handleCrateInteraction(player, crate, FOOD_COOLDOWN, MysteryBoxModule.GetRandomFood, workspace.FoodCrates)
		end)
	end
end

return module
