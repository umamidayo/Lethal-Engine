local module = {}

function module.DistanceCheck(position1, position2, range)
	if (position1 - position2).Magnitude > range then
		return true
	end
end

return module
