local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = {}

local NPC_Workspace: Folder = workspace:WaitForChild("NPC_Workspace")
local NPC_Animations: Folder = ReplicatedStorage:WaitForChild("Animations")
local NPCs: Folder = NPC_Workspace:WaitForChild("NPCs")

local function deer(npc: Model)
	local humanoid: Humanoid = npc:WaitForChild("Humanoid")
	local animator: Animator = humanoid:WaitForChild("Animator")

	local tracks: {[string]: AnimationTrack} = {}

	for _,animation in NPC_Animations[npc.Name]:GetChildren() do
		tracks[animation.Name] = animator:LoadAnimation(animation)
	end

	tracks["DeerIdle3"]:Play()

	local moveAnimation = humanoid.Running:Connect(function(speed)
		if humanoid.Health <= 0 then return end
		if speed > 0 then
			tracks["DeerWalk"]:Play()
		else
			tracks["DeerWalk"]:Stop()
		end
	end)

	humanoid.Died:Once(function()
		moveAnimation:Disconnect()
		tracks["DeerIdle3"]:Stop()
		tracks["DeerWalk"]:Stop()

		-- Because anchoring breaks animations
		local weld = Instance.new("WeldConstraint")
		weld.Parent = npc.PrimaryPart
		weld.Part0 = npc.PrimaryPart
		weld.Part1 = NPC_Workspace.MoveNodes.MoveNode

		tracks["DeerDeath"]:Play()
		tracks["DeerDeathIdle"]:Play()
	end)
end

local animations: {[string]: (Model) -> nil} = {
	["Deer"] = deer,
}

local function connectExistingNPCs()
	for _,npc in NPCs:GetChildren() do
		if animations[npc.Name] == nil then continue end
		animations[npc.Name](npc)
	end
end

function module.init()
    NPCs.ChildAdded:Connect(function(npc)
        if animations[npc.Name] == nil then return end
        animations[npc.Name](npc)
    end)
    
    connectExistingNPCs()
end

return module
