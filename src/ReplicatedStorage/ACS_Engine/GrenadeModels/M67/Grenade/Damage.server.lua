--disable
local Object = script.Parent
local Used = false

local SplashDamage = 150
local Radius = 49.5
local GrenadeArmorFactor = 50

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local Tag = Object:WaitForChild("creator")
local Debris = game:GetService("Debris")

function CheckForHumanoid(L_225_arg1)
	local L_226_ = false
	local L_227_ = nil
	if L_225_arg1 then
		if (L_225_arg1.Parent:FindFirstChildOfClass("Humanoid") or L_225_arg1.Parent.Parent:FindFirstChildOfClass("Humanoid")) then
			L_226_ = true
			if L_225_arg1.Parent:FindFirstChildOfClass('Humanoid') then
				L_227_ = L_225_arg1.Parent:FindFirstChildOfClass('Humanoid')
			elseif L_225_arg1.Parent.Parent:FindFirstChildOfClass('Humanoid') then
				L_227_ = L_225_arg1.Parent.Parent:FindFirstChildOfClass('Humanoid')
			end
		else
			L_226_ = false
		end	
	end
	return L_226_, L_227_
end

function isVisible(character: Model)
	rayParams.FilterDescendantsInstances = {Object, character, workspace.Landscape, workspace.Zombies}
	local rayResult = workspace:Raycast(Object.Position, (character.Head.Position - Object.Position), rayParams)
	
	if not rayResult then
		return true
	end
end

function Explode()
	local Explosion = Instance.new("Explosion")
	Explosion.BlastRadius = Radius*.875
	Explosion.BlastPressure = 0
	Explosion.Position = Object.Position
	Explosion.Parent = Object
	
	Explosion.Hit:Connect(function(hit, distance)
		local humanoid = hit.Parent:FindFirstChildWhichIsA("Humanoid")
		
		if humanoid then
			if game.Players:GetPlayerFromCharacter(hit.Parent) then return end
			if not isVisible(hit.Parent) then return end
			
			local DistanceFactor = distance/Radius
			DistanceFactor = 1 - DistanceFactor
			
			local HitDamage = DistanceFactor * SplashDamage
			humanoid:TakeDamage(HitDamage)
			
			local TagC = Tag:Clone()
			TagC.Parent = humanoid
			
			task.wait()
			
			if humanoid.Health <= 0 then
				hit:ApplyImpulse((hit.Position - Object.Position).Unit * Explosion.BlastRadius * 2)
			end
			
			Debris:AddItem(TagC, 5)
		end
	end)

	Debris:AddItem(Object, 7)
end

--helpfully checks a table for a specific value
function contains(t, v)
	for _, val in pairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

--used by checkTeams


--use this to determine if you want this human to be harmed or not, returns boolean

task.delay(3, function()
	Used = true
	game.ReplicatedStorage.RemotesLegacy.GrenadeClientEvent:FireAllClients(Object)
	Explode()
end)