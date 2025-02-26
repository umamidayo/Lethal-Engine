local Pathfinder = game:GetService("PathfindingService")

local Movement = {}

function Movement.NewPath()
	local agentParams = {
		AgentRadius = 4,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = false,
		WaypointSpacing = 15,
		Costs = {
			Water = 100,
			Ground = 5,
			--Grass = 10,
			--Sand = 5,
			--LeafyGrass = 1,
		}
	}
	
	return Pathfinder:CreatePath(agentParams)
end

function Movement.getWaypoints(path: Path, startPosition: Vector3, endPosition: Vector3)
	local success, errormsg = pcall(function()
		path:ComputeAsync(startPosition, endPosition)
	end)
	
	if success and path.Status == Enum.PathStatus.Success then
		return path:GetWaypoints()
	end
end

function Movement.showWaypoints(waypoints: {PathWaypoint})
	local shownWaypoints = {}
	
	for _,waypoint in pairs(waypoints) do
		local part = Instance.new("Part")
		part.Anchored = true
		part.Shape = "Ball"
		part.Size = Vector3.new(0.6, 0.6, 0.6)
		part.Material = "Neon"
		part.CanCollide = false
		part.Position = waypoint.Position + Vector3.new(0, 0, 0)
		part.Parent = workspace
		table.insert(shownWaypoints, part)
	end
	
	return shownWaypoints
end

function Movement.destroyWaypoints(waypoints: {Part})
	for i,part in pairs(waypoints) do
		part:Destroy()
		table.remove(waypoints, i)
	end
end

function Movement.Move(npc: Model, waypoints: {PathWaypoint})
	local humanoid = npc:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return end
	
	local lastPosition, distance, calculatedTime, startTime, lastWaypoint
	local currentIndex = 0
	
	npc:SetAttribute("State", "Moving")
	
	for index,waypoint in pairs(waypoints) do
		if not npc then return end
		if not npc.PrimaryPart then return end
		if not humanoid then return end
		if humanoid.Health <= 0 then return end
		
		currentIndex = index
		lastPosition = npc.PrimaryPart.Position
		distance = (lastPosition - waypoint.Position).Magnitude
		calculatedTime = (distance / humanoid.WalkSpeed)
		startTime = os.time()
		
		humanoid:MoveTo(waypoint.Position)
		
		if lastWaypoint and math.abs(lastWaypoint.Position.Y - waypoint.Position.Y) > 3.5 then
			task.wait(calculatedTime / 2)
			humanoid.Jump = true
		end
		
		task.wait(calculatedTime / 1.5)
		lastWaypoint = waypoint
	end
	
	npc:SetAttribute("State", "Idle")
	
	task.wait(math.random(10, 30))
	
	return currentIndex == waypoints
end

return Movement
