local module = {}

function module.inRange(position1: Vector3, position2: Vector3, range: number)
	return (position1 - position2).Magnitude <= range
end

function module.inLineOfSight(position1: Vector3, position2: Vector3, filterList: { Instance })
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterList
	raycastParams.IgnoreWater = true
	local rayResult = workspace:Raycast(position1, position2 - position1, raycastParams)
	return rayResult == nil
end

return module
