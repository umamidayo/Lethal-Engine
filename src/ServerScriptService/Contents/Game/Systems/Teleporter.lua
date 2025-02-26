local Teams = game:GetService("Teams")

local rayParams = RaycastParams.new()
rayParams.FilterDescendantsInstances = { workspace.Landscape, workspace.Teleports }
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local TELEPORT_COOLDOWN = 10
local ZOMBIE_SAFE_DISTANCE = 50
local TEAMMATE_SPAWN_OFFSET = 3
local RANDOM_SPAWN_RANGE = 200
local RANDOM_TEAMMATE_OFFSET = { -20, -15, -10, -5, 5, 10, 15, 20 }

local debounce = {}
local teleports: { BasePart } = workspace.Teleports:GetChildren()

local module = {}

local function teleportToRandomPosition(player: Player)
	local teleportRaycast

	repeat
		local randomTeleport = teleports[math.random(1, #teleports)]
		local randomOffset = Vector3.new(
			math.random(-RANDOM_SPAWN_RANGE, RANDOM_SPAWN_RANGE),
			0,
			math.random(-RANDOM_SPAWN_RANGE, RANDOM_SPAWN_RANGE)
		)

		teleportRaycast = workspace:Raycast(randomTeleport.Position + randomOffset, Vector3.new(0, -50, 0), rayParams)
		task.wait()
	until teleportRaycast
		and teleportRaycast.Instance.Name == "Terrain"
		and teleportRaycast.Material ~= Enum.Material.Water

	player.Character:PivotTo(CFrame.new(teleportRaycast.Position + Vector3.new(0, 4, 0)))
	player.Team = Teams.Survivor
end

local function tryTeleportToSpawnPoint(player: Player): boolean
	for _, spawnpoint: Model in workspace.Buildables.Player:GetChildren() do
		if spawnpoint.Name == "SATCOM Radio" and spawnpoint:GetAttribute("Owner") == player.Name then
			local spawnPosition = spawnpoint.WorldPivot.Position
				+ (spawnpoint.WorldPivot.LookVector * TEAMMATE_SPAWN_OFFSET)
				+ Vector3.new(0, 4, 0)

			player.Character:PivotTo(CFrame.new(spawnPosition))
			player.Team = Teams.Survivor
			return true
		end
	end
	return false
end

local function isZombieFreeArea(player: Player): boolean
	for _, zombie in workspace.Zombies:GetChildren() do
		if not zombie:FindFirstChild("Torso") then
			continue
		end
		if player:DistanceFromCharacter(zombie.Torso.Position) <= ZOMBIE_SAFE_DISTANCE then
			return false
		end
	end
	return true
end

local function findSafeTeammate(player: Player): Player?
	local safeTeammate

	for _, teammate: Player in Teams.Survivor:GetPlayers() do
		if not teammate.Character or not teammate.Character:FindFirstChild("HumanoidRootPart") then
			continue
		end

		if not isZombieFreeArea(teammate) then
			continue
		end

		if player:IsFriendsWith(teammate.UserId) then
			return teammate
		end

		safeTeammate = teammate
	end

	return safeTeammate
end

local function tryTeleportToTeammate(player: Player, teammate: Player): boolean
	local timeOut = tick()
	local teammateRaycast

	repeat
		local randomOffset = Vector3.new(
			RANDOM_TEAMMATE_OFFSET[math.random(#RANDOM_TEAMMATE_OFFSET)],
			30,
			RANDOM_TEAMMATE_OFFSET[math.random(#RANDOM_TEAMMATE_OFFSET)]
		)

		teammateRaycast =
			workspace:Raycast(teammate.Character.Torso.Position + randomOffset, Vector3.new(0, -40, 0), rayParams)
		task.wait()
	until teammateRaycast or (tick() - timeOut) > 3

	if teammateRaycast then
		player.Character:PivotTo(CFrame.new(teammateRaycast.Position + Vector3.new(0, 4, 0)))
		player.Team = Teams.Survivor
		return true
	end

	return false
end

function module.init()
	workspace.Map.ExitDoor.Door.Door.ProximityPrompt.Triggered:Connect(function(player: Player)
		if debounce[player] and (tick() - debounce[player]) < TELEPORT_COOLDOWN then
			return
		end
		debounce[player] = tick()

		if tryTeleportToSpawnPoint(player) then
			return
		end

		if #Teams.Survivor:GetPlayers() > 0 then
			local safeTeammate = findSafeTeammate(player)
			if safeTeammate and tryTeleportToTeammate(player, safeTeammate) then
				return
			end
		end

		teleportToRandomPosition(player)
	end)
end

return module
