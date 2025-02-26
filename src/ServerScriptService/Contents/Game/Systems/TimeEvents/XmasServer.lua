local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local SoundService = game:GetService("SoundService")

local Entities = ReplicatedStorage.Entities
local Buildables = Entities.Buildables
local Zombies = Entities.Zombies
local RainPart = Entities.RainPart
local XmasClothing = Zombies.XmasClothing

local currentTime = os.time()
local winterStartTime = os.time({ year = 2024, month = 11, day = 16 })
local winterEndTime = os.time({ year = 2025, month = 3, day = 31 })

local module = {}

local function insertHat(accessoryId: number)
	task.spawn(function()
		local hat = InsertService:LoadAsset(accessoryId)
		if not hat then
			return
		end
		local accessory = hat:FindFirstChildOfClass("Accessory")
		if accessory then
			local HatAttachment = accessory:FindFirstChild("HatAttachment", true)
			if HatAttachment then
				HatAttachment.Name = "HairAttachment"
			end
			if not HatAttachment then
				return
			end
			accessory.Parent = XmasClothing.HatsFolder
		end
	end)
end

function module.init()
	-- check if it is currently december
	if currentTime >= winterStartTime and currentTime <= winterEndTime then
		-- it is december, load the christmas theme
		RainPart.ParticleEmitter.Speed = NumberRange.new(0.1, 0.2)
		RainPart.ParticleEmitter.Lifetime = NumberRange.new(25, 25)
		RainPart.ParticleEmitter.LightEmission = 0.3
		RainPart.ParticleEmitter.Size = NumberSequence.new(20, 20)
		RainPart.ParticleEmitter.Texture = "rbxassetid://15497898406"

		SoundService.Ambience:WaitForChild("Thunder").SoundId = "rbxassetid://0"
		SoundService.Ambience:WaitForChild("RainAmb").SoundId = "rbxassetid://6670092634"

		local bed = Buildables:WaitForChild("Utility"):WaitForChild("Bed")
		bed.Bed.TextureID = "rbxassetid://15490882268"

		local BarbedWire = Buildables:WaitForChild("Traps"):WaitForChild("Barbed Wire")
		BarbedWire.SpiralBarbs.Decal.Color3 = Color3.fromRGB(255, 255, 255)
		BarbedWire.SpiralBarbs.Decal.Texture = "rbxassetid://15497319645"

		insertHat(14873220740)
		insertHat(15238960633)
		insertHat(14833673772)
		insertHat(14864603712)
		insertHat(8222808735)

		task.spawn(function()
			task.wait(3)
			--print("Changing tree crowns")
			for _, child in pairs(workspace.Landscape:GetChildren()) do
				if child.Name == "Tree" then
					local Crown = child:FindFirstChild("Crown")
					if not Crown then
						continue
					end
					--print("Changing crown")
					Crown.TextureID = "rbxassetid://15497426506"
				elseif child.Name == "Bush" then
					local Leaves = child:FindFirstChild("Leaves")
					if not Leaves then
						continue
					end
					Leaves.TextureID = "rbxassetid://15497501254"
				end
			end
		end)

		workspace.Terrain:SetMaterialColor(Enum.Material.Grass, Color3.fromRGB(188, 192, 188))
		workspace.Terrain:SetMaterialColor(Enum.Material.Ground, Color3.fromRGB(195, 190, 180))
		workspace.Terrain:SetMaterialColor(Enum.Material.Sand, Color3.fromRGB(194, 185, 176))
		workspace.Terrain:SetMaterialColor(Enum.Material.LeafyGrass, Color3.fromRGB(178, 185, 178))
		workspace.Terrain.WaterColor = Color3.fromRGB(49, 62, 62)
	end
end

return module
