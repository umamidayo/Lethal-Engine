local module = {}

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local pathfind = require(ServerScriptService.Modules.Pathfind)
local NPCs = workspace.NPC_Workspace.NPCs
local MoveNodes = workspace.NPC_Workspace.MoveNodes
local NPC_Storage = game.ServerStorage.NPC_Storage
local lastNodes = {}
local randomNodes = {}
local paths = {}
local busy = {}
local elapsed = 0

local npcSettings = {
	Deer = {
		Name = "Deer",
		DeathItem = "Raw Meat",
		Quantity = 0,
		MaxQuantity = 15,
	},
}

local function spawnNPCs()
	for _, npc in npcSettings do
		if not NPC_Storage:FindFirstChild(npc.Name) then
			continue
		end
		if npc.Quantity >= npc.MaxQuantity then
			continue
		end

		local newNPC: Model = NPC_Storage:FindFirstChild(npc.Name):Clone()
		newNPC:PivotTo(
			CFrame.new(
				MoveNodes:GetChildren()[math.random(1, #MoveNodes:GetChildren())].Position + Vector3.new(0, 3, 0)
			)
		)

		local humanoid: Humanoid = newNPC:FindFirstChild("Humanoid")
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

		humanoid.Died:Once(function()
			newNPC.Parent = workspace.Resources
			newNPC.Name = npc.DeathItem
			npcSettings[npc.Name].Quantity =
				math.clamp(npcSettings[npc.Name].Quantity - 1, 0, npcSettings[npc.Name].MaxQuantity)

			if newNPC.Name == "Raw Meat" then
				for i, v in newNPC:GetChildren() do
					if v:IsA("BasePart") == false then
						continue
					end
					if v.Name == "Deer" or v.Name == "HumanoidRootPart" then
						local weld = Instance.new("WeldConstraint")
						weld.Parent = v
						weld.Part1 = workspace.NPC_Workspace.MoveNodes.MoveNode
						continue
					end
					v.Size = Vector3.new()
				end
			end

			local sound: Sound = game.SoundService.NPCs:FindFirstChild(npc.Name).Death:Clone()
			sound.PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
			sound.Parent = newNPC.PrimaryPart
			sound:Play()

			game.Debris:AddItem(newNPC, 300)
		end)

		npcSettings[npc.Name].Quantity =
			math.clamp(npcSettings[npc.Name].Quantity + 1, 0, npcSettings[npc.Name].MaxQuantity)

		newNPC.Parent = NPCs
	end
end

local function moveNPCs()
	for i, npc: Model in NPCs:GetChildren() do
		if npc == nil or npc.PrimaryPart == nil then
			continue
		end
		if busy[npc] then
			continue
		end
		busy[npc] = true

		lastNodes[npc] = MoveNodes:GetChildren()[math.random(1, #MoveNodes:GetChildren())]
		randomNodes[npc] = MoveNodes:GetChildren()[math.random(1, #MoveNodes:GetChildren())]
		paths[npc] = pathfind.NewPath()

		if randomNodes[npc] == lastNodes[npc] then
			task.wait()
			continue
		end
		lastNodes[npc] = randomNodes[npc]

		local waypoints = pathfind.getWaypoints(paths[npc], npc.PrimaryPart.Position, randomNodes[npc].Position)

		if waypoints then
			--movement.showWaypoints(merchantWaypoints)
			pathfind.Move(npc, waypoints)
			--movement.destroyWaypoints(merchantWaypoints)
		end

		busy[npc] = nil
	end
end

function module.init()
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 1 then
			return
		end
		elapsed = 0

		spawnNPCs()
		moveNPCs()
	end)
end

return module
