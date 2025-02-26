--disable
local Object = script.Parent
local Used = false

local Debris = game:GetService("Debris")


function Explode()
	wait(3)
	Object.Fuse:Play()
	Object.Smoke1:Emit(40)
	Object.Smoke2:Emit(40)
	Object.Smoke3:Emit(40)
	
	wait(15)
	Object:Destroy()
end


--use this to determine if you want this human to be harmed or not, returns boolean
Explode()