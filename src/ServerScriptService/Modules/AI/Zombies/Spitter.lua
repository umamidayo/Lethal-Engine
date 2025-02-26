local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Teams = game:GetService("Teams")

local Bezier = require(ReplicatedStorage.Common.Libraries.Bezier)
local ZombieClass = require(ServerScriptService.Modules.AI.ZombieClass)

local ZombieEvent = ReplicatedStorage.RemotesLegacy.Zombie_Event

local module = {}
module.__index = module
setmetatable(module, ZombieClass)

function module.new(character: Model)
	local self = setmetatable(ZombieClass.new(character), module)
	self.Humanoid.WalkSpeed = 16
	self.Humanoid.JumpPower = 40
	self.Humanoid.MaxHealth = 250
	self.Humanoid.Health = 250
	self.Money = 175
	self.Exp = 3
	self.Damage = 30
	self.AbilityRange = 100
	self.AbilityMinimumRange = 15
	self.lastSpitTick = nil
	self.SizeScale = 1.15
	return self
end

local function createSpit()
	local spitHitPart = Instance.new("Part")
	spitHitPart.Anchored = true
	spitHitPart.CanCollide = false
	spitHitPart.Shape = Enum.PartType.Ball
	spitHitPart.Size = Vector3.one
	spitHitPart.Transparency = 1

	return spitHitPart
end

local function getPlayerCharacterParts()
	local characterParts = {}
	for _, player in Teams.Survivor:GetPlayers() do
		if not player.Character then
			continue
		end
		for _, part in player.Character:GetDescendants() do
			if part:IsA("BasePart") then
				table.insert(characterParts, part)
			end
		end
	end
	return characterParts
end

local function checkSpitCollision(zombie, targetPosition)
	local spitterRaycastParams = RaycastParams.new()
	spitterRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	spitterRaycastParams.FilterDescendantsInstances =
		{ zombie, workspace.Landscape, workspace.Forcefields, workspace.Zombies, workspace.DeadZombies }
	local groundRayResult = workspace:Raycast(targetPosition, -Vector3.yAxis * 40, spitterRaycastParams)
	local groundPosition

	if groundRayResult then
		groundPosition = groundRayResult.Position
	end

	local spitProjectilePositions = {
		zombie.Head.Position,
		((targetPosition + zombie.Head.Position) / 2)
			+ Vector3.new(0, 2, 0) * math.abs(targetPosition.Y - zombie.Head.Position.Y),
		groundPosition,
	}

	local spitBezier = Bezier.new(spitProjectilePositions[1], spitProjectilePositions[2], spitProjectilePositions[3])
	local t, currentPosition, currentDerivative, collisionRaycastResult
	local raycastCount = math.round(spitBezier.Length / 10)

	local characterParts = getPlayerCharacterParts()

	--local NumPoints = raycastCount
	--local StartPoints = {}

	--for i = 1, NumPoints do
	--	local BezierPart = Instance.new("Part", workspace.Landscape)
	--	BezierPart.Color = Color3.fromRGB(0, 255, 30)
	--	BezierPart.Size = Vector3.new(0.25, 0.25, 11)
	--	BezierPart.Transparency = 0.5
	--	BezierPart.CanCollide = false
	--	BezierPart.Anchored = true
	--	table.insert(StartPoints, BezierPart)
	--end

	spitterRaycastParams.FilterDescendantsInstances =
		{ unpack(characterParts), workspace.Landscape, workspace.Forcefields, workspace.Zombies, workspace.DeadZombies }

	for i = 1, raycastCount do
		t = (i - 1) / (raycastCount - 1)
		currentDerivative = spitBezier:CalculateDerivativeAt(t)
		currentPosition = spitBezier:CalculatePositionAt(t)

		--StartPoints[i].CFrame = CFrame.new(currentPosition, currentPosition + currentDerivative)
		collisionRaycastResult = workspace:Raycast(
			currentPosition,
			((currentPosition + currentDerivative) - currentPosition).Unit * 10,
			module.SpitterRaycastParams
		)

		if collisionRaycastResult then
			--StartPoints[i].Size = Vector3.new(0.25, 0.25, collisionRaycastResult.Distance)
			--StartPoints[i].Color = Color3.fromRGB(255, 0, 0)

			spitProjectilePositions = {
				zombie.Head.Position,
				((collisionRaycastResult.Position + zombie.Head.Position) / 2)
					+ Vector3.new(0, 2, 0) * math.abs(targetPosition.Y - zombie.Head.Position.Y),
				collisionRaycastResult.Position,
			}

			targetPosition = collisionRaycastResult.Position
			break
		end

		task.wait()
	end

	spitBezier:Destroy()

	return spitProjectilePositions, targetPosition
end

--[[
	Checks the character's head position to the origin part's position for line of sight.

	Returns a boolean based on the raycast result being nil (In line of sight).
]]
local function characterIsVisible(character, OriginPart)
	local explosiveParams = RaycastParams.new()
	explosiveParams.FilterType = Enum.RaycastFilterType.Blacklist
	explosiveParams.FilterDescendantsInstances =
		{ character, OriginPart, workspace.Landscape, workspace.Zombies, workspace.DeadZombies }
	local rayResult =
		workspace:Raycast(OriginPart.Position, (character.Head.Position - OriginPart.Position), explosiveParams)
	return rayResult == nil
end

local function buildingIsVisible(build: Model, hitPart: BasePart, OriginPart: BasePart)
	local explosiveParams = RaycastParams.new()
	explosiveParams.FilterType = Enum.RaycastFilterType.Blacklist
	explosiveParams.FilterDescendantsInstances =
		{ build, hitPart, OriginPart, workspace.Landscape, workspace.Zombies, workspace.DeadZombies }
	local rayResult = workspace:Raycast(OriginPart.Position, (hitPart.Position - OriginPart.Position), explosiveParams)
	return rayResult == nil
end

local function explode(Object, Radius, SplashDamage, damagePlayersOnly)
	local Explosion = Instance.new("Explosion")
	Explosion.Visible = false
	Explosion.BlastRadius = Radius * 0.875
	Explosion.BlastPressure = 0
	Explosion.Position = Object.Position
	Explosion.Parent = Object
	game.Debris:AddItem(Explosion, 3)

	local Hits = {}

	Explosion.Hit:Connect(function(hit, distance)
		if not hit or not hit.Parent then
			return
		end
		local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")

		if humanoid then
			if Hits[humanoid] == true then
				return
			end
			if not characterIsVisible(hit.Parent, Object) then
				return
			end
			Hits[humanoid] = true

			if humanoid.Parent.Parent == workspace.Zombies then
				if damagePlayersOnly then
					return
				end
			end

			local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)

			if player and player:GetAttribute("Protection") then
				SplashDamage =
					math.clamp(SplashDamage - (player:GetAttribute("Protection") * 0.35), SplashDamage * 0.4, 999)
			end

			local DistanceFactor = distance / Radius
			DistanceFactor = 1 - DistanceFactor

			local HitDamage = DistanceFactor * SplashDamage

			humanoid:TakeDamage(HitDamage)

			if humanoid.Health <= 0 then
				task.wait(0.1)
				hit:ApplyImpulse((hit.Position - Explosion.Position).Unit * distance * 10)
			end
		end

		if hit.Parent:GetAttribute("Health") then
			if Hits[hit.Parent] == true then
				return
			end
			Hits[hit.Parent] = true

			if not buildingIsVisible(hit.Parent, hit, Object) then
				return
			end

			local DistanceFactor = distance / Radius
			DistanceFactor = 1 - DistanceFactor

			local HitDamage = math.clamp(DistanceFactor * SplashDamage, 1, 999)
			hit.Parent:SetAttribute("Health", hit.Parent:GetAttribute("Health") - HitDamage)

			if hit.Parent and hit.Parent:GetAttribute("Health") <= 0 then
				Debris:AddItem(hit.Parent, 0)
			end
		end
	end)
end

function module:useAbility()
	if self:blockedLineOfSight(self.Target.Position) then
		return
	end
	if (self.Character.PrimaryPart.Position - self.Target.Position).Magnitude < self.AbilityMinimumRange then
		return
	end
	if self.lastSpitTick and tick() - self.lastSpitTick < 4 then
		return
	end
	self.lastSpitTick = tick()

	local spitProjectilePositions, endPosition = checkSpitCollision(self.Character, self.Target.Position)
	local spitBezier = Bezier.new(spitProjectilePositions[1], spitProjectilePositions[2], spitProjectilePositions[3])

	local spitHitPart = createSpit()
	spitHitPart.CFrame = CFrame.new(endPosition)

	local spitProjectileTime = spitBezier.Length / 60

	ZombieEvent:FireAllClients(
		"ZombieFX",
		{ "SpitterShot", self, self.Target.Position, spitProjectilePositions, spitProjectileTime }
	)

	task.wait(spitProjectileTime)
	spitHitPart.Parent = workspace
	explode(spitHitPart, 10, 40, true)
	Debris:AddItem(spitHitPart, 0.1)
end

return module
