local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local COOLDOWN = 0.2
local debounce: { [Player]: number? } = {}
local Cosmetics = {}

local function weldParts(part0: BasePart, part1: BasePart)
	local weld = Instance.new("Weld")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.C0 = CFrame.new()
	weld.C1 = part1.CFrame:ToObjectSpace(part0.CFrame)
	weld.Parent = part0
end

local function equipItem(character: Model, item: Model)
	local attachPart = character:FindFirstChild(item.PrimaryPart.Name)
	if not attachPart then
		return
	end

	local itemClone = item:Clone()
	itemClone:PivotTo(attachPart.CFrame)
	itemClone.PrimaryPart:Destroy()

	for _, part in itemClone:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		weldParts(attachPart, part)
		part.CanCollide = false
		part.Anchored = false
	end

	itemClone.Parent = character

	local clickDetector = itemClone:FindFirstChildWhichIsA("ClickDetector")
	if clickDetector then
		Debris:AddItem(clickDetector, 0)
	end
end

function Cosmetics.init()
	for _, item in CollectionService:GetTagged("Cosmetic") do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.Parent = item

		clickDetector.MouseClick:Connect(function(player)
			if debounce[player] and tick() - debounce[player] < COOLDOWN then
				return
			end
			debounce[player] = tick()

			local character = player.Character
			if not character then
				return
			end

			local equippedItem = character:FindFirstChild(item.Name)
			if equippedItem then
				Debris:AddItem(equippedItem, 0)
			else
				equipItem(character, item)
			end
		end)
	end
end

return Cosmetics
