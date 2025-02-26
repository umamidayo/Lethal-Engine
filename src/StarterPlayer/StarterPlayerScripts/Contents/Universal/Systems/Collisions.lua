local module = {}

local function disableTrussPartsPlayerCollision()
	local collideable
	
	for i,v: TrussPart in workspace.TrussParts:GetChildren() do
		collideable = v.CanCollide
		v.CanCollide = false
		v.Transparency = 1
	end
	
	return collideable
end

function module.init()
    local trussPartsCollideable

    repeat
        trussPartsCollideable = disableTrussPartsPlayerCollision()
        task.wait(1)
    until trussPartsCollideable == false
end

return module
