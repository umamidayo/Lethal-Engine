local module = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local ACS_Workspace = workspace:WaitForChild("ACS_WorkSpace")
local Engine = ReplicatedStorage:WaitForChild("ACS_Engine")
local Evt = Engine:WaitForChild("Events")
local Mods = Engine:WaitForChild("Modules")
local Rules = Engine:WaitForChild("GameRules")
local PastaFx = Engine:WaitForChild("FX")
local gameRules = require(Rules:WaitForChild("Config"))
local HitMod = require(Mods:WaitForChild("Hitmarker"))
local ACSModifier = require(Mods:WaitForChild("ACSModifier"))
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera

local WhizzSound = {
	"4872110675",
	"5303773495",
	"5303772965",
	"5303773495",
	"5303772257",
	"342190005",
	"342190012",
	"342190017",
	"342190024",
}

local Ignore_Model = { cam, plr.Character, ACS_Workspace.Client, ACS_Workspace.Server }
local NVG = false

local LaserTransparencySequence = NumberSequence.new(0)
local DoorsFolder = ACS_Workspace:FindFirstChild("Doors")
local mDistance = 5
local Key = nil

local bulletCache = {}
local bulletsFired = 0

local function CastRay(Bullet)
	if not Bullet then
		return
	end

	if not bulletCache[Bullet] then
		bulletCache[Bullet] = {
			Bpos = Bullet.Position,
			Bpos2 = cam.CFrame.Position,
			recast = false,
			raycastResult = nil,
		}
	end

	task.delay(5, function()
		bulletCache[Bullet] = nil
	end)
end

local bulletRaycastParams = RaycastParams.new()
bulletRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
bulletRaycastParams.IgnoreWater = true

local function bulletPhysics(Bullet, BulletInfo)
	if not Bullet or not BulletInfo then
		bulletCache[Bullet] = nil
		return
	end

	bulletCache[Bullet].Bpos = Bullet.Position
	bulletCache[Bullet].raycastResult = workspace:Raycast(
		bulletCache[Bullet].Bpos2,
		(bulletCache[Bullet].Bpos - bulletCache[Bullet].Bpos2) * 1,
		bulletRaycastParams
	)
	bulletRaycastParams.FilterDescendantsInstances = Ignore_Model

	if bulletCache[Bullet].raycastResult then
		local raycastResult = bulletCache[Bullet].raycastResult

		if not bulletCache[Bullet].recast then
			local Hit2 = raycastResult.Instance

			if
				Hit2
				and (Hit2.Parent:IsA("Accessory") or Hit2.Parent:IsA("Hat") or Hit2.Transparency >= 1 or Hit2.CanCollide == false or Hit2.Name == "Ignorable" or Hit2.Name == "Glass" or Hit2.Name == "Ignore" or Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1" or Hit2.Parent.Name == "Arm2")
				and Hit2.Name ~= "Right Arm"
				and Hit2.Name ~= "Left Arm"
				and Hit2.Name ~= "Right Leg"
				and Hit2.Name ~= "Left Leg"
				and Hit2.Name ~= "UpperTorso"
				and Hit2.Name ~= "LowerTorso"
				and Hit2.Name ~= "RightUpperArm"
				and Hit2.Name ~= "RightLowerArm"
				and Hit2.Name ~= "RightHand"
				and Hit2.Name ~= "LeftUpperArm"
				and Hit2.Name ~= "LeftLowerArm"
				and Hit2.Name ~= "LeftHand"
				and Hit2.Name ~= "RightUpperLeg"
				and Hit2.Name ~= "RightLowerLeg"
				and Hit2.Name ~= "RightFoot"
				and Hit2.Name ~= "LeftUpperLeg"
				and Hit2.Name ~= "LeftLowerLeg"
				and Hit2.Name ~= "LeftFoot"
				and Hit2.Name ~= "Armor"
				and Hit2.Name ~= "EShield"
			then
				table.insert(Ignore_Model, Hit2)
				bulletCache[Bullet].recast = true
			end

			if not bulletCache[Bullet].recast then
				Debris:AddItem(Bullet, 0)
				bulletCache[Bullet] = nil
			end
		end
	end

	if bulletCache[Bullet] then
		bulletCache[Bullet].Bpos2 = bulletCache[Bullet].Bpos
	end
end

local function getNearest()
	local nearest = nil
	local minDistance = mDistance
	local Character = plr.Character or plr.CharacterAdded:Wait()

	for _, door in pairs(DoorsFolder:GetChildren()) do
		if door.Door:FindFirstChild("Knob") ~= nil then
			local distance = (door.Door.Knob.Position - Character.Torso.Position).magnitude

			if distance < minDistance then
				nearest = door
				minDistance = distance
			end
		end
	end

	return nearest
end

local function Interact(_, inputState, _)
	if inputState ~= Enum.UserInputState.Begin then
		return
	end

	local nearestDoor = getNearest()
	local Character = plr.Character or plr.CharacterAdded:Wait()

	if nearestDoor == nil then
		return
	end

	if (nearestDoor.Door.Knob.Position - Character.Torso.Position).magnitude <= mDistance then
		if nearestDoor ~= nil then
			if nearestDoor:FindFirstChild("RequiresKey") then
				Key = nearestDoor.RequiresKey.Value
			else
				Key = nil
			end
			Evt.DoorEvent:FireServer(nearestDoor, 1, Key)
		end
	end
end

function module.init()
	Scheduler.AddToScheduler("Interval_0.05", "ACS_Events", function()
		for bullet, bulletinfo in bulletCache do
			bulletPhysics(bullet, bulletinfo)
		end
	end)

	Evt.NVG.Event:Connect(function(Value)
		NVG = Value
	end)

	Evt.HitEffect.OnClientEvent:Connect(function(Player, Position, HitPart, Normal, Material, CanBreachDoor)
		if Player ~= plr then
			HitMod.HitEffect(Ignore_Model, Position, HitPart, Normal, Material, CanBreachDoor)
		end
	end)

	Evt.Atirar.OnClientEvent:Connect(function(Player: Player, Arma, Suppressor, FlashHider)
		if Player ~= plr and Arma then
			if
				Player.Character
				and Player.Character:FindFirstChild("S" .. Arma.Name)
				and Player.Character:FindFirstChild("S" .. Arma.Name).Handle:FindFirstChild("Muzzle")
			then
				local Muzzle = Player.Character:FindFirstChild("S" .. Arma.Name).Handle.Muzzle
				local FlashFXLight = Muzzle:FindFirstChild("FlashFXLight")

				if Suppressor then
					Muzzle.Supressor:Play()
				else
					Muzzle.Fire:Play()
					if Player:DistanceFromCharacter(workspace.CurrentCamera.CFrame.Position) > 250 then
						Muzzle.Echo:Play()
					end
				end

				if FlashHider and Suppressor then
					Muzzle["Smoke"]:Emit(10)
				elseif (FlashHider and not Suppressor) or (not FlashHider and not Suppressor) then
					Muzzle["FlashFX[Flash]"]:Emit(10)
					Muzzle["Smoke"]:Emit(10)
					if FlashFXLight then
						task.spawn(function()
							FlashFXLight.Enabled = true
							task.wait(0.05)
							FlashFXLight.Enabled = false
						end)
					end
				end
			end

			if
				Player.Character:FindFirstChild("AnimBase") ~= nil
				and Player.Character.AnimBase:FindFirstChild("AnimBaseW")
			then
				local AnimBase = Player.Character:WaitForChild("AnimBase"):WaitForChild("AnimBaseW")
				TweenService:Create(
					AnimBase,
					TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0),
					{ C1 = CFrame.new(0, 0, 0.15):Inverse() }
				):Play()
				task.delay(0.1, function()
					TweenService:Create(
						AnimBase,
						TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0),
						{ C1 = CFrame.new():Inverse() }
					):Play()
				end)
			end
		end
	end)

	Evt.SVLaser.OnClientEvent:Connect(function(Player, Position, Modo, Cor, IR, Arma)
		if Player ~= plr and Player.Character and Arma then
			if not ACS_Workspace.Server:FindFirstChild(`{Player.Name}_Laser`) then
				local Dot = Instance.new("Part")
				Dot.Name = Player.Name .. "_Laser"
				Dot.Transparency = 1
				Dot.Parent = ACS_Workspace.Server

				local Att0 = Instance.new("Attachment")
				Att0.Name = "Att0"
				Att0.Parent = Dot

				if
					Player.Character:FindFirstChild("S" .. Arma.Name)
					and Player.Character:FindFirstChild("S" .. Arma.Name).Handle:FindFirstChild("Muzzle")
				then
					local Muzzle = Player.Character:FindFirstChild("S" .. Arma.Name).Handle.Muzzle
					local Laser = Instance.new("Beam")
					Laser.Transparency = LaserTransparencySequence
					Laser.LightEmission = 1
					Laser.LightInfluence = 0
					Laser.Color = ColorSequence.new(Cor)
					Laser.FaceCamera = true
					Laser.Width0 = 0.01
					Laser.Width1 = 0.01
					Laser.Attachment0 = Att0
					Laser.Attachment1 = Muzzle
					Laser.Parent = Dot
					if not NVG then
						Laser.Enabled = false
					end
				end
			end

			if Modo == 1 then
				if ACS_Workspace.Server:FindFirstChild(Player.Name .. "_Laser") then
					local LA = ACS_Workspace.Server:FindFirstChild(Player.Name .. "_Laser")
					LA.Shape = "Ball"
					LA.Size = Vector3.new(0.1, 0.1, 0.1)
					LA.CanCollide = false
					LA.Anchored = true
					LA.Color = Cor
					LA.Material = Enum.Material.Neon
					LA.Position = Position
					if NVG then
						LA.Transparency = 0

						if LA:FindFirstChild("Beam") then
							LA.Beam.Enabled = true
						end
					else
						if IR then
							LA.Transparency = 1
						else
							LA.Transparency = 0
						end

						if LA:FindFirstChild("Beam") then
							LA.Beam.Enabled = false
						end
					end
				end
			elseif Modo == 2 then
				if ACS_Workspace.Server:FindFirstChild(Player.Name .. "_Laser") then
					ACS_Workspace.Server:FindFirstChild(Player.Name .. "_Laser"):Destroy()
				end
			end
		end
	end)

	Evt.SVFlash.OnClientEvent:Connect(function(Player, Arma, Mode)
		if Player ~= plr and Player.Character and Arma then
			local Weapon = Player.Character:FindFirstChild("S" .. Arma.Name)
			if Weapon then
				if Mode then
					for _, part in Weapon:GetDescendants() do
						if part:IsA("BasePart") and part.Name == "FlashPoint" then
							part.Light.Enabled = true
						end
					end
				else
					for _, part in Weapon:GetDescendants() do
						if part:IsA("BasePart") and part.Name == "FlashPoint" then
							part.Light.Enabled = false
						end
					end
				end
			end
		end
	end)

	Evt.SVSuppressor.OnClientEvent:Connect(function(Player, Arma, Mode)
		if Player ~= plr and Player.Character and Arma then
			local Weapon = Player.Character:FindFirstChild("S" .. Arma.Name)

			if Weapon then
				if Mode then
					for _, v in Weapon:FindFirstChild("Suppressor"):GetChildren() do
						if v:IsA("BasePart") then
							v.Transparency = 0
						end
					end
				else
					for _, v in Weapon:FindFirstChild("Suppressor"):GetChildren() do
						if v:IsA("BasePart") then
							v.Transparency = 1
						end
					end
				end
			end
		end
	end)

	Evt.Whizz.OnClientEvent:Connect(function()
		local Som = Instance.new("Sound")
		Som.Parent = plr.PlayerGui
		Som.SoundId = "rbxassetid://" .. WhizzSound[math.random(1, #WhizzSound)]
		Som.Volume = 1
		Som.PlayOnRemove = true
		Som:Destroy()
	end)

	Evt.MedSys.MedHandler.OnClientEvent:connect(function(Mode)
		if Mode == 4 then
			local FX = Instance.new("ColorCorrectionEffect")
			FX.Parent = cam

			TweenService:Create(FX, TweenInfo.new(0.15, Enum.EasingStyle.Linear), { Contrast = -0.25 }):Play()
			task.delay(0.15, function()
				TweenService:Create(
					FX,
					TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.15),
					{ Contrast = 0 }
				):Play()
				Debris:AddItem(FX, 1.5)
			end)
		elseif Mode == 5 then
			local FX = Instance.new("ColorCorrectionEffect")
			FX.Parent = cam

			TweenService:Create(FX, TweenInfo.new(0.15, Enum.EasingStyle.Linear), { Contrast = 0.5 }):Play()
			task.delay(0.15, function()
				TweenService:Create(
					FX,
					TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.15),
					{ Contrast = 0 }
				):Play()
				Debris:AddItem(FX, 1.5)
			end)
		elseif Mode == 6 then
			local FX = Instance.new("ColorCorrectionEffect")
			FX.Parent = cam

			TweenService:Create(FX, TweenInfo.new(0.15, Enum.EasingStyle.Linear), { Contrast = -0.25 }):Play()
			task.delay(0.15, function()
				TweenService:Create(
					FX,
					TweenInfo.new(60, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.15),
					{ Contrast = 0 }
				):Play()
				Debris:AddItem(FX, 60)
			end)
		elseif Mode == 7 then
			local FX = Instance.new("ColorCorrectionEffect")
			FX.Parent = cam

			TweenService:Create(FX, TweenInfo.new(0.15, Enum.EasingStyle.Linear), { Contrast = 0.5 }):Play()
			task.delay(0.15, function()
				TweenService:Create(
					FX,
					TweenInfo.new(30, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.15),
					{ Contrast = 0 }
				):Play()
				Debris:AddItem(FX, 30)
			end)
		end
	end)

	Evt.Suppression.OnClientEvent:Connect(function(Mode, _, Tempo)
		local SE_GUI = plr.PlayerGui:FindFirstChild("StatusUI")
		if plr.Character and plr.Character.Humanoid.Health > 0 and SE_GUI then
			if Mode == 1 then
				TweenService:Create(
					SE_GUI.Efeitos.Suppress,
					TweenInfo.new(0.1),
					{ ImageTransparency = 0, Size = UDim2.fromScale(1, 1.15) }
				):Play()
				task.delay(0.1, function()
					TweenService:Create(
						SE_GUI.Efeitos.Suppress,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, 0, false, 0.15),
						{ ImageTransparency = 1, Size = UDim2.fromScale(2, 2) }
					):Play()
				end)
			elseif Mode == 2 then
				local ring = PastaFx.EarRing:Clone()
				ring.Parent = plr.PlayerGui
				ring.Volume = 0
				ring:Play()
				Debris:AddItem(ring, Tempo)

				TweenService:Create(ring, TweenInfo.new(0.1), { Volume = 2 }):Play()
				task.delay(0.1, function()
					TweenService:Create(
						ring,
						TweenInfo.new(Tempo, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0.15),
						{ Volume = 0 }
					):Play()
				end)

				TweenService:Create(
					SE_GUI.Efeitos.Dirty,
					TweenInfo.new(0.1),
					{ ImageTransparency = 0, Size = UDim2.fromScale(1, 1.15) }
				):Play()
				task.delay(0.1, function()
					TweenService
						:Create(
							SE_GUI.Efeitos.Dirty,
							TweenInfo.new(
								Tempo,
								Enum.EasingStyle.Exponential,
								Enum.EasingDirection.InOut,
								0,
								false,
								0.15
							),
							{ ImageTransparency = 1, Size = UDim2.fromScale(2, 2) }
						)
						:Play()
				end)
			else
				local ring = PastaFx.EarRing:Clone()
				ring.Parent = plr.PlayerGui
				ring.Volume = 0
				ring:Play()
				Debris:AddItem(ring, Tempo)

				TweenService:Create(ring, TweenInfo.new(0.1), { Volume = 2 }):Play()
				task.delay(0.1, function()
					TweenService:Create(
						ring,
						TweenInfo.new(Tempo, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0.15),
						{ Volume = 0 }
					):Play()
				end)
			end
		end
	end)

	Evt.GunStance.OnClientEvent:Connect(function(Player, stance, Data)
		if not Player or not Player.Character then
			return
		end
		if not Player.Character:FindFirstChild("Humanoid") or Player.Character.Humanoid.Health <= 0 then
			return
		end
		if
			not Player.Character:FindFirstChild("AnimBase")
			or not Player.Character.AnimBase:FindFirstChild("RAW")
			or not Player.Character.AnimBase:FindFirstChild("LAW")
		then
			return
		end

		local Right_Weld = Player.Character.AnimBase:FindFirstChild("RAW")
		local Left_Weld = Player.Character.AnimBase:FindFirstChild("LAW")

		if not Right_Weld or not Left_Weld then
			return
		end

		if stance == 0 then
			TweenService:Create(Right_Weld, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { C0 = Data.SV_RightArmPos })
				:Play()
			TweenService:Create(Left_Weld, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { C0 = Data.SV_LeftArmPos })
				:Play()
			return
		elseif stance == 2 then
			TweenService:Create(Right_Weld, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { C0 = Data.RightAim }):Play()
			TweenService:Create(Left_Weld, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { C0 = Data.LeftAim }):Play()
			return
		elseif stance == 1 then
			TweenService:Create(Right_Weld, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { C0 = Data.RightHighReady })
				:Play()
			TweenService:Create(Left_Weld, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { C0 = Data.LeftHighReady })
				:Play()
			return
		elseif stance == -1 then
			TweenService:Create(Right_Weld, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { C0 = Data.RightLowReady })
				:Play()
			TweenService:Create(Left_Weld, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { C0 = Data.LeftLowReady })
				:Play()
			return
		elseif stance == -2 then
			TweenService:Create(Right_Weld, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { C0 = Data.RightPatrol })
				:Play()
			TweenService:Create(Left_Weld, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { C0 = Data.LeftPatrol }):Play()
			return
		elseif stance == 3 then
			TweenService:Create(Right_Weld, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { C0 = Data.RightSprint })
				:Play()
			TweenService:Create(Left_Weld, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { C0 = Data.LeftSprint }):Play()
			return
		end
		return
	end)

	local NeckTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

	Evt.HeadRot.OnClientEvent:Connect(function(HeadRotations: { CFrame })
		for PlayerName: string, HeadRot: CFrame in HeadRotations do
			local Player = Players:FindFirstChild(PlayerName)
			if
				not Player
				or Player == plr
				or not Player.Character
				or not Player.Character:FindFirstChild("Torso")
				or not Player.Character:FindFirstChild("Head")
			then
				continue
			end
			local Neck = Player.Character.Torso:FindFirstChild("Neck")
			if not Neck then
				return
			end
			TweenService:Create(Neck, NeckTweenInfo, { C1 = HeadRot }):Play()
		end
	end)

	Evt.ServerBullet.OnClientEvent:Connect(function(Player, Origin, Direction, WeaponData, ModTable)
		if Player ~= plr and Player.Character then
			bulletsFired += 1
			local Bullet = Instance.new("Part")
			Bullet.Name = Player.Name .. "_Bullet" .. bulletsFired
			Bullet.CanCollide = false
			Bullet.Shape = Enum.PartType.Ball
			Bullet.Transparency = 1
			Bullet.Size = Vector3.one
			Bullet.Parent = ACS_Workspace.Server

			local BulletCF = CFrame.new(Origin, Direction)
			local BColor = Color3.fromRGB(255, 255, 255)

			if WeaponData.RainbowMode then
				BColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
			else
				BColor = WeaponData.TracerColor
			end

			if WeaponData.Tracer == true then
				local At1 = Instance.new("Attachment")
				At1.Name = "At1"
				At1.Position = Vector3.new(-0.15, 0, 0)
				At1.Parent = Bullet

				local At2 = Instance.new("Attachment")
				At2.Name = "At2"
				At2.Position = Vector3.new(0.15, 0, 0)
				At2.Parent = Bullet

				local Tracer = Engine.FX.Tracer:Clone()
				Tracer.Color = ColorSequence.new(BColor)
				Tracer.Attachment0 = At1
				Tracer.Attachment1 = At2
				Tracer.Parent = Bullet

				TweenService:Create(Tracer, ACSModifier.TracerTweenInfo, {
					MaxLength = 5,
					Brightness = 5,
				}):Play()
			end

			if WeaponData.BulletFlare == true then
				local bg = Instance.new("BillboardGui")
				bg.Parent = Bullet
				bg.Adornee = Bullet
				bg.LightInfluence = 0

				local flashsize = math.random(20, 30)
				bg.Size = UDim2.new(flashsize, 0, flashsize, 0)

				local flash = Instance.new("ImageLabel")
				flash.BackgroundTransparency = 1
				flash.Size = UDim2.new(1, 0, 1, 0)
				flash.Position = UDim2.new(0, 0, 0, 0)
				flash.Image = "http://www.roblox.com/asset/?id=1047066405"
				flash.ImageTransparency = 0.5
				flash.ImageColor3 = BColor
				flash.Parent = bg
			end

			local BulletMass = Bullet:GetMass()
			local DropForce = Vector3.new(0, BulletMass * workspace.Gravity - 2, 0)
			local BF = Instance.new("BodyForce")
			BF.Parent = Bullet

			Bullet.CFrame = BulletCF
			Bullet:ApplyImpulse(Direction * WeaponData.MuzzleVelocity * ModTable.MuzzleVelocity * 0.25)
			TweenService:Create(Bullet, ACSModifier.BulletDropForceTweenInfo, {
				AssemblyLinearVelocity = Direction * WeaponData.MuzzleVelocity * ModTable.MuzzleVelocity * 0.075,
			}):Play()
			BF.Force = DropForce

			Debris:AddItem(Bullet, 5)
			CastRay(Bullet)
		end
	end)

	ContextActionService:BindAction("Interact", Interact, false, Enum.KeyCode.G)

	if gameRules.WaterMark then
		local StarterGui = game:GetService("StarterGui")
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = "Advanced Combat System",
			Color = Color3.fromRGB(255, 175, 0),
			Font = Enum.Font.Roboto,
			TextSize = 14,
		})

		plr.Chatted:Connect(function(Message)
			if string.lower(Message) == "/acs" then
				StarterGui:SetCore("ChatMakeSystemMessage", {
					Text = "------------------------------------------------",
					Color = Color3.fromRGB(0, 0, 35),
					Font = Enum.Font.RobotoCondensed,
					TextSize = 20,
				})

				StarterGui:SetCore("ChatMakeSystemMessage", {
					Text = "Advanced Combat System",
					Color = Color3.fromRGB(255, 175, 0),
					Font = Enum.Font.RobotoCondensed,
					TextSize = 20,
				})

				StarterGui:SetCore("ChatMakeSystemMessage", {
					Text = "Made By: 00Scorpion00",
					Color = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.RobotoCondensed,
					TextSize = 14,
				})

				StarterGui:SetCore("ChatMakeSystemMessage", {
					Text = "Version: " .. gameRules.Version,
					Color = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.RobotoCondensed,
					TextSize = 14,
				})

				StarterGui:SetCore("ChatMakeSystemMessage", {
					Text = "------------------------------------------------",
					Color = Color3.fromRGB(0, 0, 35),
					Font = Enum.Font.RobotoCondensed,
					TextSize = 20,
				})
			end
		end)
	end
end

return module
