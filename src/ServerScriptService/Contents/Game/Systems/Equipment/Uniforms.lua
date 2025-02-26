local module = {}

local MAX_DISTANCE = 12
local COOLDOWN = 0.2
local debounces = {}

local function changeClothes(character: Model, shirt: Shirt, pants: Pants)
	for _, item in character:GetChildren() do
		if item:IsA("Shirt") or item:IsA("Pants") then
			item:Destroy()
		end
	end

	local newShirt = shirt:Clone()
	local newPants = pants:Clone()
	newShirt.Parent = character
	newPants.Parent = character
end

local function handleUniformInteraction(player: Player, uniform: Model)
	if not player.Character or not player.Character.PrimaryPart then
		return
	end

	local distance = (player.Character.PrimaryPart.Position - uniform.WorldPivot.Position).Magnitude
	if distance > MAX_DISTANCE then
		return
	end

	if debounces[player] and (tick() - debounces[player]) < COOLDOWN then
		return
	end
	debounces[player] = tick()

	local shirt = uniform:FindFirstChildOfClass("Shirt")
	local pants = uniform:FindFirstChild("Pants")
	if not shirt or not pants then
		return
	end

	changeClothes(player.Character, shirt, pants)
end

function module.init()
	for _, uniform in workspace.GearFolder.Uniforms:GetChildren() do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = MAX_DISTANCE
		clickDetector.Parent = uniform

		clickDetector.MouseClick:Connect(function(player)
			handleUniformInteraction(player, uniform)
		end)
	end
end

return module
