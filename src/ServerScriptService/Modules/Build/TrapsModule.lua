local module = {}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

function module.inLineOfSight(model: Model, target: Model)
	local modelCFrame: CFrame, modelSize: Vector3 = model:GetBoundingBox()
	local targetCFrame: CFrame, targetSize: Vector3 = target:GetBoundingBox()
	
	rayParams.FilterDescendantsInstances = {target, model, workspace.Landscape, workspace.Zombies, workspace.DeadZombies}
	local rayResult = workspace:Raycast(modelCFrame.Position, (targetCFrame.Position - modelCFrame.Position), rayParams)

	if not rayResult then
		return true
	end
end

function module.Explode(model: Model, Radius: number, SplashDamage: number)
	local modelCFrame: CFrame, modelSize: Vector3 = model:GetBoundingBox()
	
	local Explosion = Instance.new("Explosion")
	Explosion.BlastRadius = Radius * 0.875
	Explosion.BlastPressure = 0
	Explosion.Position = modelCFrame.Position
	Explosion.Parent = model
	
	game.Debris:AddItem(Explosion, 3)
	
	local Hits = {}

	Explosion.Hit:Connect(function(hit, distance)
		if not hit or not hit.Parent then return end
		if not hit.Parent:FindFirstChild("Humanoid") then return end
		if game.Players:GetPlayerFromCharacter(hit.Parent) then return end
		
		local humanoid: Humanoid = hit.Parent.Humanoid
		if Hits[humanoid] == true then return end
		Hits[humanoid] = true
		
		if not module.inLineOfSight(hit.Parent, model) then return end

		local DistanceFactor = distance/Radius
		DistanceFactor = 1 - DistanceFactor

		local HitDamage = DistanceFactor * SplashDamage
		humanoid:TakeDamage(HitDamage)
		
		task.delay(0.1, function()
			if humanoid.Health <= 0 then
				hit:ApplyImpulse((hit.Position - model.PrimaryPart.Position).Unit * Explosion.BlastRadius * 25)
			end
		end)
	end)
end

return module
