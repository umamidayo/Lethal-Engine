local SE_Workspace = workspace:WaitForChild("ACS_WorkSpace")
local Debris = game:GetService("Debris")
local TS = game:GetService("TweenService")

local Glass = { "4668969235", "1565825075", "1565824613", "4668969774", "4668969602", "4668970218", "4668970412" }
local Metal = { "4656732707", "4656731892", "4656731369", "4656730961", "4656730553" }
local Grass = { "4656723881", "4656724474", "4656724827", "4656725141", "4656725914" }
local Wood = { "4656734860", "4656734329", "4656733733", "4656733402", "4656733030" }
local Concrete = { "4991840567", "8500357892", "4927234432", "8500357771", "4927235094", "4927236859", "5303772965" }
local Explosion = { "287390459", "287390954", "287391087", "287391197", "287391361", "287391499", "287391567" }
local Cracks = { "8500357892", "8500357771", "4991840567", "4927234734", "4927235094", "4927236859", "5303772965" } -- Bullet Cracks
local Hits =
	{ "3744371091", "3744371584", "1565837588", "1565836522", "1565734495", "3744371864", "1565734259", "3744371342" } -- Player
local Body = {
	"4635529646",
	"4635529872",
	"4635529434",
	"4635529230",
	"363818432",
	"363818488",
	"363818567",
	"363818611",
	"363818653",
} -- Body Shots
local Whizz = {
	"342190005",
	"342190012",
	"342190017",
	"342190024",
	"253951210",
	"253951228",
	"253951272",
	"253951309",
	"253951341",
} -- Bullet Whizz

local bloods = { "4117590991", "4117588426", "4117589176", "4117589687", "4117590335" }
local bloodColor = ColorSequence.new(Color3.fromRGB(144, 41, 41))
local Hitmarker = {}

local setVolume = 0.5

function Hitmarker.HitEffect(Ray_Ignore, Position, HitPart, Normal, Material, CanBreachDoor)
	if HitPart ~= nil and HitPart.Parent ~= nil then
		local Attachment = Instance.new("Attachment", workspace.Terrain)
		Attachment.CFrame = CFrame.new(Position, Position + Normal)

		if HitPart.Name == "Head" or HitPart.Parent.Name == "Top" then
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(34, 50) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Hits[math.random(1, #Hits)]

			BulletWhizz:Play()

			local Particles = Instance.new("ParticleEmitter")
			Particles.Enabled = false
			Particles.Color = bloodColor
			Particles.LightEmission = 0
			Particles.LightInfluence = 1
			Particles.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5, 0),
				NumberSequenceKeypoint.new(1, 3),
			})
			Particles.Texture = "rbxassetid://11561421303"
			Particles.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			Particles.Acceleration = Vector3.new(0, -20, 0)
			Particles.Lifetime = NumberRange.new(0.2, 0.5)
			Particles.Rate = 1000
			Particles.Drag = 0
			Particles.Rotation = NumberRange.new(-360, 360)
			Particles.RotSpeed = NumberRange.new(-40, 40)
			Particles.Speed = NumberRange.new(-25, 25)
			Particles.VelocitySpread = math.random(15, 25)
			Particles.SpreadAngle = Vector2.new(-25, 25)
			Particles.LockedToPart = true
			Particles.Parent = Attachment
			Particles.EmissionDirection = "Front"
			Particles:Emit(15)
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		elseif
			HitPart.Name == "HumanoidRootPart"
			or HitPart.Name == "Torso"
			or HitPart.Name == "UpperTorso"
			or HitPart.Name == "LowerTorso"
			or HitPart.Name == "Right Arm"
			or HitPart.Name == "Left Arm"
			or HitPart.Name == "Right Leg"
			or HitPart.Name == "Left Leg"
			or HitPart.Name == "RightUpperArm"
			or HitPart.Name == "RightLowerArm"
			or HitPart.Name == "RightHand"
			or HitPart.Name == "LeftUpperArm"
			or HitPart.Name == "LeftLowerArm"
			or HitPart.Name == "LeftHand"
			or HitPart.Name == "RightUpperLeg"
			or HitPart.Name == "RightLowerLeg"
			or HitPart.Name == "RightFoot"
			or HitPart.Name == "LeftUpperLeg"
			or HitPart.Name == "LeftLowerLeg"
			or HitPart.Name == "LeftFoot"
			or HitPart.Parent.Name == "Chest"
			or HitPart.Parent.Name == "Back"
		then
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(34, 46) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Body[math.random(1, #Body)]

			BulletWhizz:Play()

			local Particles = Instance.new("ParticleEmitter")
			Particles.Enabled = false
			Particles.Color = bloodColor
			Particles.LightEmission = 0
			Particles.LightInfluence = 1
			Particles.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5, 0),
				NumberSequenceKeypoint.new(1, 2),
			})
			Particles.Texture = "rbxassetid://11561421303"
			Particles.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			Particles.Acceleration = Vector3.new(0, -20, 0)
			Particles.Lifetime = NumberRange.new(0.2, 0.5)
			Particles.Rate = 1000
			Particles.Drag = 0
			Particles.Rotation = NumberRange.new(-360, 360)
			Particles.RotSpeed = NumberRange.new(-40, 40)
			Particles.Speed = NumberRange.new(-15, 15)
			Particles.VelocitySpread = math.random(15, 25)
			Particles.SpreadAngle = Vector2.new(-25, 25)
			Particles.LockedToPart = true
			Particles.Parent = Attachment
			Particles.EmissionDirection = "Front"
			Particles:Emit(10)
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		elseif HitPart.Parent:IsA("Accessory") then
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(34, 50) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Hits[math.random(1, #Hits)]

			BulletWhizz:Play()

			local Particles = Instance.new("ParticleEmitter")
			Particles.Enabled = false
			Particles.Color = bloodColor
			Particles.LightEmission = 0
			Particles.LightInfluence = 1
			Particles.Size = NumberSequence.new(0, 2.5)
			Particles.Texture = "rbxassetid://11561421303"
			Particles.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			Particles.Acceleration = Vector3.new(0, -20, 0)
			Particles.Lifetime = NumberRange.new(0.5, 0.5)
			Particles.Rate = 2000
			Particles.RotSpeed = NumberRange.new(-10, 10)
			Particles.Speed = NumberRange.new(2, 7)
			Particles.SpreadAngle = Vector2.new(-380, 380)
			Particles.LockedToPart = true
			Particles.Parent = Attachment
			Particles.EmissionDirection = "Front"
			Particles:Emit(10)
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		elseif HitPart.Name == "Glass" then
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(32, 60) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Glass[math.random(1, #Glass)]

			BulletWhizz:Play()

			--local bg = Instance.new("BillboardGui", Attachment)
			--bg.Adornee = Attachment
			--local flashsize = math.random(10, 15)/10
			--bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			--local flash = Instance.new("ImageLabel", bg)
			--flash.BackgroundTransparency = 1
			--flash.Size = UDim2.new(0.05, 0, 0.05, 0)
			--flash.Position = UDim2.new(0.5, 0, 0.5, 0)
			--flash.Image = "http://www.roblox.com/asset/?id=5984841909"
			--flash.ImageTransparency = math.random(0, .5)
			--flash.Rotation = math.random(0, 360)
			--flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)
			--game.Debris:AddItem(bg, 0.1)
			HitPart:Destroy()
		elseif HitPart.Name == "DoorHinge" and CanBreachDoor == true then
			local DoorModel = HitPart.Parent

			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(38, 58) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Metal[math.random(1, #Metal)]

			BulletWhizz:Play()

			local Particles = Instance.new("ParticleEmitter")
			Particles.Color = ColorSequence.new(Color3.fromRGB(255, 150, 0))
			Particles.LightEmission = 1
			Particles.LightInfluence = 0
			Particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			Particles.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.25, 0),
				NumberSequenceKeypoint.new(1, 0.1),
			})
			Particles.Acceleration = Vector3.new(0, -50, 0)
			Particles.Lifetime = NumberRange.new(0.15 - 0.05, 0.15 + 0.5)
			Particles.Rate = 1000
			Particles.Drag = 10
			Particles.RotSpeed = NumberRange.new(360)
			Particles.Speed = NumberRange.new(50 - 25, 50 + 25)
			Particles.VelocitySpread = math.random(5, 20)
			Particles.Parent = Attachment
			Particles.EmissionDirection = "Front"
			delay(0.1, function()
				Particles.Enabled = false
				Debris:AddItem(Attachment, Particles.Lifetime.Max)
			end)
			--local bg = Instance.new("BillboardGui", Attachment)
			--bg.Adornee = Attachment
			--local flashsize = math.random(15, 30)/10
			--bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			--local flash = Instance.new("ImageLabel", bg)
			--flash.BackgroundTransparency = 1
			--flash.Size = UDim2.new(0.05, 0, 0.05, 0)
			--flash.Position = UDim2.new(0.45, 0, 0.45, 0)
			--flash.Image = "http://www.roblox.com/asset/?id=233113663"
			--flash.ImageTransparency = math.random(0, .5)
			--flash.Rotation = math.random(0, 360)
			--flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.15)
			--game.Debris:AddItem(bg, 0.07)

			HitPart:Destroy()
			if DoorModel:FindFirstChild("DoorHinge") == nil then
				DoorModel.Hinge:Destroy()
			end
		elseif HitPart.Name == "Knob" and CanBreachDoor == true then
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(38, 58) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Metal[math.random(1, #Metal)]

			BulletWhizz:Play()

			local Particles = Instance.new("ParticleEmitter")
			Particles.Color = ColorSequence.new(Color3.fromRGB(255, 150, 0))
			Particles.LightEmission = 1
			Particles.LightInfluence = 0
			Particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			Particles.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.25, 0),
				NumberSequenceKeypoint.new(1, 0.1),
			})
			Particles.Acceleration = Vector3.new(0, -50, 0)
			Particles.Lifetime = NumberRange.new(0.15 - 0.05, 0.15 + 0.5)
			Particles.Rate = 1000
			Particles.Drag = 10
			Particles.RotSpeed = NumberRange.new(-360, 360)
			Particles.Speed = NumberRange.new(50 - 25, 50 + 25)
			Particles.VelocitySpread = math.random(5, 20)
			Particles.Parent = Attachment
			Particles.EmissionDirection = "Front"
			delay(0.1, function()
				Particles.Enabled = false
				Debris:AddItem(Attachment, Particles.Lifetime.Max)
			end)
			--local bg = Instance.new("BillboardGui", Attachment)
			--bg.Adornee = Attachment
			--local flashsize = math.random(15, 30)/10
			--bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			--local flash = Instance.new("ImageLabel", bg)
			--flash.BackgroundTransparency = 1
			--flash.Size = UDim2.new(0.05, 0, 0.05, 0)
			--flash.Position = UDim2.new(0.45, 0, 0.45, 0)
			--flash.Image = "http://www.roblox.com/asset/?id=233113663"
			--flash.ImageTransparency = math.random(0, .5)
			--flash.Rotation = math.random(0, 360)
			--flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.15)
			--game.Debris:AddItem(bg, 0.07)

			local DoorModel = HitPart
			if DoorModel.Parent:FindFirstChild("Hinge") ~= nil then
				DoorModel.Parent.Hinge.HingeConstraint.ActuatorType = Enum.ActuatorType.Motor
			end
			HitPart:Destroy()
		elseif
			Material == Enum.Material.Concrete
			or Material == Enum.Material.Slate
			or Material == Enum.Material.Cobblestone
			or Material == Enum.Material.Brick
			or Material == Enum.Material.Granite
			or Material == Enum.Material.Basalt
			or Material == Enum.Material.Rock
			or Material == Enum.Material.CrackedLava
			or Material == Enum.Material.Limestone
			or Material == Enum.Material.Asphalt
			or Material == Enum.Material.Sandstone
		then
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(38, 46) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Concrete[math.random(1, #Concrete)]

			BulletWhizz:Play()

			local Particles = Instance.new("ParticleEmitter")
			Particles.Enabled = false
			Particles.Color = ColorSequence.new(Color3.new(0.827451, 0.803922, 0.72549))
			Particles.LightEmission = 0
			Particles.LightInfluence = 1
			Particles.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1, 0.1),
				NumberSequenceKeypoint.new(1, 2),
			})
			Particles.Texture = "rbxassetid://404342776"
			Particles.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.75, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			Particles.Acceleration = Vector3.new(math.random(-5, 5), math.random(-20, 20), math.random(-5, 5))
			Particles.Lifetime = NumberRange.new(1, 5)
			Particles.Rate = 1000
			Particles.Drag = 25
			Particles.RotSpeed = NumberRange.new(-10, 10)
			Particles.Speed = NumberRange.new(25, 40)
			Particles.SpreadAngle = Vector2.new(180, 360)
			Particles.Parent = Attachment
			Particles.EmissionDirection = "Front"
			Particles:Emit(50)

			Debris:AddItem(Attachment, Particles.Lifetime.Max)

			--local bg = Instance.new("BillboardGui", Attachment)
			--bg.Adornee = Attachment
			--local flashsize = math.random(10, 15)/10
			--bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			--local flash = Instance.new("ImageLabel", bg)
			--flash.BackgroundTransparency = 1
			--flash.Size = UDim2.new(0.05, 0, 0.05, 0)
			--flash.Position = UDim2.new(0.5, 0, 0.5, 0)
			--flash.Image = "http://www.roblox.com/asset/?id=476778304"
			--flash.ImageTransparency = math.random(0, .5)
			--flash.Rotation = math.random(0, 360)
			--flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)
			--game.Debris:AddItem(bg, 0.1)
		elseif Material == Enum.Material.Wood or Material == Enum.Material.WoodPlanks then
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(38, 50) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Wood[math.random(1, #Wood)]

			BulletWhizz:Play()

			local Particles = Instance.new("ParticleEmitter")
			Particles.Enabled = false
			Particles.Color = ColorSequence.new(HitPart.Color)
			Particles.LightEmission = 0
			Particles.LightInfluence = 1
			Particles.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5, 0),
				NumberSequenceKeypoint.new(1, 0.1),
			})
			Particles.Texture = "rbxassetid://6407141377"
			Particles.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			Particles.Acceleration = Vector3.new(0, -50, 0)
			Particles.Lifetime = NumberRange.new(0.5, 0.75)
			Particles.Rate = 100
			Particles.Drag = 5
			Particles.RotSpeed = NumberRange.new(-360, 360)
			Particles.Speed = NumberRange.new(40, 50)
			Particles.VelocitySpread = 50
			Particles.Parent = Attachment
			Particles.EmissionDirection = "Front"
			Particles:Emit(20)
			Debris:AddItem(Attachment, Particles.Lifetime.Max)

			--local bg = Instance.new("BillboardGui", Attachment)
			--bg.Adornee = Attachment
			--local flashsize = math.random(10, 15)/10
			--bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			--local flash = Instance.new("ImageLabel", bg)
			--flash.BackgroundTransparency = 1
			--flash.Size = UDim2.new(0.05, 0, 0.05, 0)
			--flash.Position = UDim2.new(0.5, 0, 0.5, 0)
			--flash.Image = "http://www.roblox.com/asset/?id=476778304"
			--flash.ImageTransparency = math.random(0, .5)
			--flash.Rotation = math.random(0, 360)
			--flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)
			--game.Debris:AddItem(bg, 0.1)
		elseif Material == Enum.Material.Fabric then
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(38, 50) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Grass[math.random(1, #Grass)]

			BulletWhizz:Play()

			local Particles = Instance.new("ParticleEmitter")
			Particles.Enabled = false
			Particles.Color = ColorSequence.new(HitPart.Color)
			Particles.LightEmission = 0
			Particles.LightInfluence = 1
			Particles.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.1, 0.1),
				NumberSequenceKeypoint.new(1, 5),
			})
			Particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
			Particles.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.75, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			Particles.Acceleration = Vector3.new(0, 0, 0)
			Particles.Lifetime = NumberRange.new(0.9 - 0.05, 0.9 + 0.05)
			Particles.Rate = 200
			Particles.Drag = 100
			Particles.RotSpeed = NumberRange.new(-360, 360)
			Particles.Speed = NumberRange.new(35 - 5, 35 + 5)
			Particles.VelocitySpread = 100
			Particles.Parent = Attachment
			Particles.EmissionDirection = "Front"
			Particles:Emit(50)

			Debris:AddItem(Attachment, Particles.Lifetime.Max)

			--local bg = Instance.new("BillboardGui", Attachment)
			--bg.Adornee = Attachment
			--local flashsize = math.random(10, 15)/10
			--bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			--local flash = Instance.new("ImageLabel", bg)
			--flash.BackgroundTransparency = 1
			--flash.Size = UDim2.new(0.05, 0, 0.05, 0)
			--flash.Position = UDim2.new(0.5, 0, 0.5, 0)
			--flash.Image = "http://www.roblox.com/asset/?id=476778304"
			--flash.ImageTransparency = math.random(0, .5)
			--flash.Rotation = math.random(0, 360)
			--flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)
			--game.Debris:AddItem(bg, 0.1)
		elseif
			Material == Enum.Material.Grass
			or Material == Enum.Material.Sand
			or Material == Enum.Material.Ground
			or Material == Enum.Material.Snow
			or Material == Enum.Material.Mud
			or Material == Enum.Material.LeafyGrass
		then
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(38, 50) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Grass[math.random(1, #Grass)]

			BulletWhizz:Play()

			local Particles = Instance.new("ParticleEmitter")
			Particles.Enabled = false
			Particles.Color = ColorSequence.new(Color3.fromRGB(95, 86, 75))
			Particles.LightEmission = 0
			Particles.LightInfluence = 1
			Particles.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1, 0.1),
				NumberSequenceKeypoint.new(1, 4),
			})
			Particles.Texture = "rbxassetid://404342776"
			Particles.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.75, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			Particles.Acceleration = Vector3.new(math.random(-5, 5), math.random(-20, 20), math.random(-5, 5))
			Particles.Lifetime = NumberRange.new(1, 5)
			Particles.Rate = 1000
			Particles.Drag = 30
			Particles.RotSpeed = NumberRange.new(-10, 10)
			Particles.Speed = NumberRange.new(40, 50)
			Particles.SpreadAngle = Vector2.new(180, 360)
			Particles.Parent = Attachment
			Particles.EmissionDirection = "Front"
			Particles:Emit(50)

			Debris:AddItem(Attachment, Particles.Lifetime.Max)

			--local bg = Instance.new("BillboardGui", Attachment)
			--bg.Adornee = Attachment
			--local flashsize = math.random(10, 15)/10
			--bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			--local flash = Instance.new("ImageLabel", bg)
			--flash.BackgroundTransparency = 1
			--flash.Size = UDim2.new(0.05, 0, 0.05, 0)
			--flash.Position = UDim2.new(0.5, 0, 0.5, 0)
			--flash.Image = "http://www.roblox.com/asset/?id=476778304"
			--flash.ImageTransparency = math.random(0, .5)
			--flash.Rotation = math.random(0, 360)
			--flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)
			--game.Debris:AddItem(bg, 0.1)
		elseif Material == Enum.Material.Plastic or Material == Enum.Material.SmoothPlastic then
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(32, 50) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Cracks[math.random(1, #Cracks)]

			BulletWhizz:Play()
			local Particles = Instance.new("ParticleEmitter")
			Particles.Enabled = false
			Particles.Color = ColorSequence.new(Color3.new(0.827451, 0.803922, 0.72549))
			Particles.LightEmission = 0
			Particles.LightInfluence = 1
			Particles.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1, 0.1),
				NumberSequenceKeypoint.new(1, 2),
			})
			Particles.Texture = "rbxassetid://404342776"
			Particles.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.75, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			Particles.Acceleration = Vector3.new(math.random(-5, 5), math.random(-20, 20), math.random(-5, 5))
			Particles.Lifetime = NumberRange.new(1, 5)
			Particles.Rate = 1000
			Particles.Drag = 25
			Particles.RotSpeed = NumberRange.new(-10, 10)
			Particles.Speed = NumberRange.new(25, 40)
			Particles.SpreadAngle = Vector2.new(180, 360)
			Particles.Parent = Attachment
			Particles.EmissionDirection = "Top"
			Particles:Emit(50)
			Debris:AddItem(Attachment, Particles.Lifetime.Max)

			--local bg = Instance.new("BillboardGui", Attachment)
			--bg.Adornee = Attachment
			--local flashsize = math.random(10, 15)/10
			--bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			--local flash = Instance.new("ImageLabel", bg)
			--flash.BackgroundTransparency = 1
			--flash.Size = UDim2.new(0.05, 0, 0.05, 0)
			--flash.Position = UDim2.new(0.5, 0, 0.5, 0)
			--flash.Image = "http://www.roblox.com/asset/?id=476778304"
			--flash.ImageTransparency = math.random(0, .5)
			--flash.Rotation = math.random(0, 360)
			--flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)
			--game.Debris:AddItem(bg, 0.1)
		elseif Material == Enum.Material.ForceField then
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(32, 50) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Whizz[math.random(1, #Whizz)]

			BulletWhizz:Play()
			--local bg = Instance.new("BillboardGui", Attachment)
			--bg.Adornee = Attachment
			--local flashsize = math.random(15, 30)/10
			--bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			--local flash = Instance.new("ImageLabel", bg)
			--flash.BackgroundTransparency = 1
			--flash.Size = UDim2.new(0.05, 0, 0.05, 0)
			--flash.Position = UDim2.new(0.45, 0, 0.45, 0)
			--flash.Image = "http://www.roblox.com/asset/?id=233113663"
			--flash.ImageTransparency = math.random(0, .5)
			--flash.Rotation = math.random(0, 360)
			--flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.15)
			--game.Debris:AddItem(bg, 0.07)
			game.Debris:AddItem(Attachment, 1)
		elseif
			Material == Enum.Material.CorrodedMetal
			or Material == Enum.Material.Metal
			or Material == Enum.Material.DiamondPlate
		then
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(38, 58) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Metal[math.random(1, #Metal)]

			BulletWhizz:Play()

			local Particles = Instance.new("ParticleEmitter")
			Particles.Enabled = false
			Particles.Color = ColorSequence.new(Color3.fromRGB(255, 213, 146))
			Particles.Brightness = 10
			Particles.LightEmission = 1
			Particles.LightInfluence = 0
			Particles.Texture = "rbxassetid://4911290852"
			Particles.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.4, 0),
				NumberSequenceKeypoint.new(1, 0.1),
			})
			Particles.Acceleration = Vector3.new(0, -50, 0)
			Particles.Lifetime = NumberRange.new(0.5, 2)
			Particles.Rate = 1000
			Particles.Drag = 10
			Particles.RotSpeed = NumberRange.new(-360, 360)
			Particles.Speed = NumberRange.new(25, 100)
			Particles.VelocitySpread = math.random(45, 45)
			Particles.Parent = Attachment
			Particles.EmissionDirection = "Front"
			Particles:Emit(50)
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
			--local bg = Instance.new("BillboardGui", Attachment)
			--bg.Adornee = Attachment
			--local flashsize = math.random(15, 30)/10
			--bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			--local flash = Instance.new("ImageLabel", bg)
			--flash.BackgroundTransparency = 1
			--flash.Size = UDim2.new(0.05, 0, 0.05, 0)
			--flash.Position = UDim2.new(0.45, 0, 0.45, 0)
			--flash.Image = "http://www.roblox.com/asset/?id=233113663"
			--flash.ImageTransparency = math.random(0, .5)
			--flash.Rotation = math.random(0, 360)
			--flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.15)
			--game.Debris:AddItem(bg, 0.07)
		elseif
			Material == Enum.Material.Glass
			or Material == Enum.Material.Ice
			or Material == Enum.Material.Glacier
		then
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(32, 60) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Glass[math.random(1, #Glass)]

			BulletWhizz:Play()

			local Particles = Instance.new("ParticleEmitter")
			Particles.Enabled = false
			Particles.Color = ColorSequence.new(Color3.new(50, 50, 50))
			Particles.LightEmission = 1
			Particles.LightInfluence = 0
			Particles.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 3),
			})
			Particles.Texture = "http://www.roblox.com/asset/?id=13269725650"
			Particles.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			Particles.Acceleration = Vector3.new(0, -25, 0)
			Particles.Lifetime = NumberRange.new(0.25, 0.5)
			Particles.Rate = 1000
			Particles.Drag = 5
			Particles.RotSpeed = NumberRange.new(-25, 25)
			Particles.Speed = NumberRange.new(25, 25)
			Particles.VelocitySpread = 50
			Particles.Parent = Attachment
			Particles.EmissionDirection = "Front"
			Particles:Emit(5)
			Debris:AddItem(Attachment, Particles.Lifetime.Max)

			--local bg = Instance.new("BillboardGui", Attachment)
			--bg.Adornee = Attachment
			--local flashsize = math.random(10, 15)/10
			--bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			--local flash = Instance.new("ImageLabel", bg)
			--flash.BackgroundTransparency = 1
			--flash.Size = UDim2.new(0.05, 0, 0.05, 0)
			--flash.Position = UDim2.new(0.5, 0, 0.5, 0)
			--flash.Image = "http://www.roblox.com/asset/?id=476778304"
			--flash.ImageTransparency = math.random(0, .5)
			--flash.Rotation = math.random(0, 360)
			--flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)
			--game.Debris:AddItem(bg, 0.1)
		else
			local BulletWhizz = Instance.new("Sound")
			BulletWhizz.Parent = Attachment
			BulletWhizz.Volume = setVolume
			BulletWhizz.MaxDistance = 100
			BulletWhizz.EmitterSize = 5
			BulletWhizz.PlaybackSpeed = math.random(32, 50) / 40
			BulletWhizz.SoundId = "rbxassetid://" .. Cracks[math.random(1, #Cracks)]

			BulletWhizz:Play()

			local Particles = Instance.new("ParticleEmitter")
			Particles.Enabled = false
			Particles.Color = ColorSequence.new(Color3.new(50, 50, 50))
			Particles.LightEmission = 0
			Particles.LightInfluence = 1
			Particles.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.1, 0.1),
				NumberSequenceKeypoint.new(1, 2),
			})
			Particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
			Particles.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.75, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			Particles.Acceleration = Vector3.new(0, 0, 0)
			Particles.Lifetime = NumberRange.new(0.5, 1)
			Particles.Rate = 1000
			Particles.Drag = 20
			Particles.RotSpeed = NumberRange.new(-360, 360)
			Particles.Speed = NumberRange.new(15, 30)
			Particles.SpreadAngle = Vector2.new(180, 360)
			Particles.Parent = Attachment
			Particles.EmissionDirection = "Front"
			Particles:Emit(50)

			Debris:AddItem(Attachment, Particles.Lifetime.Max)

			--local bg = Instance.new("BillboardGui", Attachment)
			--bg.Adornee = Attachment
			--local flashsize = math.random(10, 15)/10
			--bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			--local flash = Instance.new("ImageLabel", bg)
			--flash.BackgroundTransparency = 1
			--flash.Size = UDim2.new(0.05, 0, 0.05, 0)
			--flash.Position = UDim2.new(0.5, 0, 0.5, 0)
			--flash.Image = "http://www.roblox.com/asset/?id=476778304"
			--flash.ImageTransparency = math.random(0, .5)
			--flash.Rotation = math.random(0, 360)
			--flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)
			--game.Debris:AddItem(bg, 0.1)
		end

		if HitPart.Name == "Hitmaker" then
			local Marca = Instance.new("Part")
			Marca.Material = Enum.Material.Neon
			Marca.Anchored = true
			Marca.CanCollide = false
			Marca.Color = Color3.fromRGB(255, 0, 0)
			Marca.Size = Vector3.new(0.2, 0.2, 0.01)
			Marca.Parent = SE_Workspace.Server
			Marca.CFrame = CFrame.new(Position, Position + Normal)
			--table.insert(Ray_Ignore, Marca)

			TS:Create(
				Marca,
				TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 5),
				{ Color = Color3.fromRGB(0, 0, 255) }
			):Play()
			TS:Create(
				Marca,
				TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 15),
				{ Transparency = 1, Size = Vector3.new(0, 0, 0.01) }
			):Play()
			Debris:AddItem(Attachment, 5)
			game.Debris:AddItem(Marca, 20)
		elseif HitPart.Name == "alvo" then
			local Marca = Instance.new("Part")
			Marca.Anchored = true
			Marca.CanCollide = false
			Marca.Transparency = 1
			Marca.Size = Vector3.new(0.2, 0.2, 0.01)
			Marca.Parent = SE_Workspace.Server
			Marca.CFrame = CFrame.new(Position, Position + Normal)
			Debris:AddItem(Attachment, 5)
			game.Debris:AddItem(Marca, 20)
			table.insert(Ray_Ignore, Marca)
			local Dec = Instance.new("Decal")
			Dec.Texture = "rbxassetid://359667865"
			Dec.Parent = Marca
		end
	end
end

function Hitmarker.Explosion(Position, HitPart, Normal)
	local Hitmark = Instance.new("Attachment")
	Hitmark.CFrame = CFrame.new(Position, Position + Normal)
	Hitmark.Parent = workspace.Terrain

	local S = Instance.new("Sound")
	S.EmitterSize = 50
	S.MaxDistance = 1500
	S.SoundId = "rbxassetid://" .. Explosion[math.random(1, 7)]
	S.PlaybackSpeed = math.random(30, 55) / 40
	S.Volume = setVolume
	S.Parent = Hitmark
	S.PlayOnRemove = true
	S:Destroy()

	local Exp = Instance.new("Explosion")
	Exp.BlastPressure = 0
	Exp.BlastRadius = 0
	Exp.DestroyJointRadiusPercent = 0
	Exp.Position = Hitmark.Position
	Exp.Parent = Hitmark

	Debris:AddItem(Hitmark, 5)
end

return Hitmarker
