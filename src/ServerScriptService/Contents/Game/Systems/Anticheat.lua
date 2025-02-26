local DataStore = game:GetService("DataStoreService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local Notifier = ReplicatedStorage.RemotesLegacy.Notifier
local TempBanStore = DataStore:GetDataStore("TempBanStore", 6)
local floatParams = OverlapParams.new()
local rayParams = RaycastParams.new()
local regionParams = OverlapParams.new()

local Times = {
	Minute = 60,
	Hour = 3600,
	Day = 86400,
}

local players = {}
local flags = {}
local lastFlagTime = {}
local Anticheat = {}

local function teleportPlayerToGround(player: Player, rootpart: BasePart, humanoid: Humanoid)
	rayParams.FilterDescendantsInstances = { player.Character, workspace.Map_NoBuild }
	local rayResult = workspace:Raycast(rootpart.Position, Vector3.new(0, -1, 0) * 30, rayParams)

	if rayResult then
		player.Character:MoveTo(rayResult.Position + Vector3.new(0, 4, 0))
	else
		humanoid:TakeDamage(humanoid.MaxHealth)
	end
end

local function isOutOfBounds(player: Player)
	if not player.Character then
		return
	end

	local humanoid: Humanoid = player.Character:FindFirstChild("Humanoid")
	local rootpart: BasePart = player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoid and not rootpart then
		if player.Team ~= Teams.Dead then
			warn(script.Name .. ": " .. player.Name .. " has no HumanoidRootPart and Humanoid.")
		end
		return
	end

	if humanoid.Health <= 0 then
		return
	end

	if player.Team == Teams.Survivor and player:DistanceFromCharacter(Vector3.zero) > 1650 then
		humanoid:UnequipTools()
		return true
	end
end

local function isFlying(player: Player)
	if not player.Character then
		return
	end

	local humanoid: Humanoid = player.Character:FindFirstChild("Humanoid")
	local rootpart: BasePart = player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoid and not rootpart then
		if player.Team ~= Teams.Dead then
			warn(script.Name .. ": " .. player.Name .. " has no HumanoidRootPart and Humanoid.")
		end
		return
	end

	if humanoid.Health <= 0 then
		return
	end

	local raycastDistance = 10

	if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
		raycastDistance += 20
	end

	rayParams.FilterDescendantsInstances = { player.Character }

	local rayResult = workspace:Raycast(rootpart.Position, -Vector3.yAxis * raycastDistance, rayParams)

	if rayResult then
		if rayResult.Instance.Parent == workspace.Map_NoBuild then
			teleportPlayerToGround(player, rootpart, humanoid)
			flags[player].Area += 1
			Notifier:FireClient(player, "Anti-Cheat Warning: Do not attempt to climb this structure.")
		end
		return
	end

	floatParams.FilterDescendantsInstances = { player.Character, workspace.Map_NoBuild }

	local parts = workspace:GetPartBoundsInRadius(rootpart.Position, 15, floatParams)

	if #parts > 0 then
		return
	end

	local TerrainChecker = Instance.new("Part")
	TerrainChecker.Anchored = true
	TerrainChecker.CanCollide = false
	TerrainChecker.Transparency = 1
	TerrainChecker.Size = Vector3.one * 15
	TerrainChecker.Position = rootpart.Position
	TerrainChecker.Parent = workspace

	parts = TerrainChecker:GetTouchingParts()

	Debris:AddItem(TerrainChecker, 0.1)

	for _, v in parts do
		if v:IsA("Terrain") then
			return
		end
	end

	return true
end

local function isInRestrictedArea(player: Player)
	if not player.Character then
		return
	end

	local humanoid: Humanoid = player.Character:FindFirstChild("Humanoid")
	local rootpart: BasePart = player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoid and not rootpart then
		if player.Team ~= Teams.Dead then
			warn(script.Name .. ": " .. player.Name .. " has no HumanoidRootPart and Humanoid.")
		end
		return
	end

	if humanoid.Health <= 0 then
		return
	end

	regionParams.FilterDescendantsInstances = { workspace.Forcefields.NoZombie }

	local parts = workspace:GetPartBoundsInRadius(rootpart.Position, 10, regionParams)

	if player.Team == Teams.Survivor then
		if #parts <= 0 then
			return
		end
		humanoid:TakeDamage(humanoid.MaxHealth)
		return true
	elseif player.Team == Teams.Spawn then
		if #parts > 0 then
			return
		end
		humanoid:TakeDamage(humanoid.MaxHealth)
		return true
	end
end

local function isAdmin(player: Player)
	return player:IsInGroup(10705478) and player:GetRankInGroup(10705478) >= 10
end

local function toHMS(s)
	return ("%02i hrs %02i mins %02i seconds"):format(s / 60 ^ 2, s / 60 % 60, s % 60)
end

Players.PlayerAdded:Connect(function(player)
	local admin = isAdmin(player)

	if admin then
		return
	end

	local success, banInfo = pcall(function()
		return TempBanStore:GetAsync(tostring(player.UserId) .. "_tempban")
	end)

	if success and banInfo then
		if os.time() - banInfo.BanTime < banInfo.BanLength then
			player:Kick(
				"Anti-cheat banned | Ban length: "
					.. toHMS(banInfo.BanLength - (os.time() - banInfo.BanTime))
					.. " | Remarks: "
					.. banInfo.BanReason
			)
		end
	end

	if flags[player] == nil then
		flags[player] = { Fly = 0, Area = 0 }
	end

	table.insert(players, player)
end)

function Anticheat.init()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	floatParams.FilterType = Enum.RaycastFilterType.Exclude
	regionParams.FilterType = Enum.RaycastFilterType.Include

	Players.PlayerRemoving:Connect(function(player)
		if flags[player] then
			flags[player] = nil
		end

		if lastFlagTime[player] then
			lastFlagTime[player] = nil
		end

		local index = table.find(players, player)

		if index then
			table.remove(players, index)
		end
	end)

	Scheduler.AddToScheduler("Interval_5", "AntiCheat", function()
		for _, player in players do
			if lastFlagTime[player] ~= nil and (tick() - lastFlagTime[player]) > (Times.Minute * 5) then
				if flags[player].Fly > 0 then
					flags[player].Fly = math.clamp(flags[player].Fly - 1, 0, 6)
				end

				if flags[player].Area > 0 then
					flags[player].Area = math.clamp(flags[player].Area - 1, 0, 3)
				end
			end

			if isFlying(player) then
				flags[player].Fly += 1
				lastFlagTime[player] = tick()
			end

			if isInRestrictedArea(player) then
				flags[player].Area += 1
				lastFlagTime[player] = tick()
			end

			if isOutOfBounds(player) then
				player:LoadCharacter()
			end

			if flags[player].Fly >= 6 or flags[player].Area >= 3 then
				local banReason

				if flags[player].Fly >= 6 then
					banReason = "Float detection exceeded tolerance level"
				elseif flags[player].Area >= 3 then
					banReason = "Player found in a restricted area (3x)"
				end

				local banInfo = { BanTime = os.time(), BanLength = Times.Day, BanReason = banReason }

				local success, errormsg = pcall(function()
					if not isAdmin(player) then
						TempBanStore:SetAsync(tostring(player.UserId) .. "_tempban", banInfo)
					end
				end)

				if success then
					player:Kick(
						"Anti-cheat banned | Ban length: "
							.. toHMS(banInfo.BanLength - (os.time() - banInfo.BanTime))
							.. " | Remarks: "
							.. banInfo.BanReason
					)
					warn(script.Parent.Name .. ": " .. player.Name .. " was banned by the anti-cheat.")
				end
			end
		end
	end)
end

return Anticheat
