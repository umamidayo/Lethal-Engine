local module = {}

function module.EquipTool(character: Model, tool: Tool)
    if not character or not tool then return end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end

    humanoid:EquipTool(tool)
end

function module.UnequipTool(character: Model)
    if not character then return end

    local tool = character:FindFirstChildWhichIsA("Tool")

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end

    humanoid:UnequipTools()

    return tool
end

function module.GetEquippedTool(player: Player)
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end

    if humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then return end

    return character:FindFirstChildWhichIsA("Tool")
end

function module.IsDead(player: Player)
    local character = player.Character
    if not character then return true end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return true end

    if humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then
        return true
    end
end

--[[
    Sets the size percentage of an R6 character.

    character: Model of the R6 character.

    Percentage: Scale number between 0 and 1.
]]
function module.SetSize(character: Model, Percentage: number)
	local Motors = {}
	local NewMotors = {}
	local NewVal = Instance.new("BoolValue")
	NewVal.Name = "AppliedGrowth"
	NewVal.Parent = character


	for i,v in pairs(character.Torso:GetChildren()) do
		if v:IsA("Motor6D") then
			table.insert(Motors, v)
		end
	end
	table.insert(Motors, character.HumanoidRootPart.RootJoint)

	for i,v in pairs(Motors) do

		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = v.C0:GetComponents()
		X = X * Percentage
		Y = Y * Percentage
		Z = Z * Percentage
		R00 = R00 * Percentage
		R01 = R01 * Percentage
		R02 = R02 * Percentage
		R10 = R10 * Percentage
		R11 = R11 * Percentage
		R12 = R12 * Percentage
		R20 = R20 * Percentage
		R21 = R21 * Percentage
		R22 = R22 * Percentage
		v.C0 = CFrame.new(X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22)

		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = v.C1:GetComponents()
		X = X * Percentage
		Y = Y * Percentage
		Z = Z * Percentage
		R00 = R00 * Percentage
		R01 = R01 * Percentage
		R02 = R02 * Percentage
		R10 = R10 * Percentage
		R11 = R11 * Percentage
		R12 = R12 * Percentage
		R20 = R20 * Percentage
		R21 = R21 * Percentage
		R22 = R22 * Percentage
		v.C1 = CFrame.new(X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22)

		table.insert(NewMotors, {v:Clone(), v.Parent})
		v:Destroy()
	end

	for i,v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			v.Size = v.Size * Percentage
		end
	end

	for i,v in pairs(NewMotors) do
		v[1].Parent = v[2]
	end
end

return module
