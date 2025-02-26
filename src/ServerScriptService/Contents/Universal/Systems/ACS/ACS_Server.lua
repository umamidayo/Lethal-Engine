local module = {}
local Teams = game:GetService("Teams")

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local ACS_Workspace = workspace:WaitForChild("ACS_WorkSpace")
local Engine = ReplicatedStorage:WaitForChild("ACS_Engine")
local Evt = Engine:WaitForChild("Events")
local Mods = Engine:WaitForChild("Modules")
local GunModels = Engine:WaitForChild("GunModels")
local SVGunModels = Engine:WaitForChild("GrenadeModels")
local AttModels = Engine:WaitForChild("AttModels")
local Rules = Engine:WaitForChild("GameRules")

local gameRules = require(Rules:WaitForChild("Config"))
local Ultil = require(Mods:WaitForChild("Utilities"))
local Ragdoll = require(Mods:WaitForChild("Ragdoll"))

local DoorsFolder = ACS_Workspace:FindFirstChild("Doors")
local DoorsFolderClone = DoorsFolder:Clone()
local BreachClone = ACS_Workspace.Breach:Clone()
BreachClone.Parent = ServerStorage
DoorsFolderClone.Parent = ServerStorage

local HeadRotData = {
	LastFire = tick(),
	HeadRotations = {},
}
-----------------------------------------------------------------

local function CalculateDMG(SKP_0, SKP_1, SKP_2, SKP_4, SKP_5, SKP_6)
	if not SKP_1 then
		return
	end

	local skp_0: Model = Players:GetPlayerFromCharacter(SKP_1.Parent) or nil
	local skp_1: number = 0
	local skp_2 = SKP_5.MinDamage * SKP_6.minDamageMod

	if SKP_4 == 1 then
		local skp_3 = math.random(SKP_5.HeadDamage[1], SKP_5.HeadDamage[2])
		skp_1 = math.max(skp_2, (skp_3 * SKP_6.DamageMod) - (SKP_2 / 25) * SKP_5.DamageFallOf)
	elseif SKP_4 == 2 then
		local skp_3 = math.random(SKP_5.TorsoDamage[1], SKP_5.TorsoDamage[2])
		skp_1 = math.max(skp_2, (skp_3 * SKP_6.DamageMod) - (SKP_2 / 25) * SKP_5.DamageFallOf)
	else
		local skp_3 = math.random(SKP_5.LimbDamage[1], SKP_5.LimbDamage[2])
		skp_1 = math.max(skp_2, (skp_3 * SKP_6.DamageMod) - (SKP_2 / 25) * SKP_5.DamageFallOf)
	end

	if SKP_1.Parent:FindFirstChild("ACS_Client") and not SKP_5.IgnoreProtection then
		local skp_4 = SKP_1.Parent.ACS_Client.Protecao.VestProtect
		local skp_5 = SKP_1.Parent.ACS_Client.Protecao.HelmetProtect

		if SKP_4 == 1 then
			if SKP_5.BulletPenetration < skp_5.Value then
				skp_1 = math.max(0.5, skp_1 * (SKP_5.BulletPenetration / skp_5.Value))
			end
		else
			if SKP_5.BulletPenetration < skp_4.Value then
				skp_1 = math.max(0.5, skp_1 * (SKP_5.BulletPenetration / skp_4.Value))
			end
		end
	end

	-- Perks damage bonus
	local DamageBonus = SKP_0.Character:GetAttribute("DamageBonus") or 0
	skp_1 += (skp_1 * (DamageBonus / 100))

	if skp_0 then
		if skp_0.Team ~= SKP_0.Team or skp_0.Neutral then
			local skp_t = Instance.new("ObjectValue")
			skp_t.Name = "creator"
			skp_t.Value = SKP_0
			skp_t.Parent = SKP_1
			game.Debris:AddItem(skp_t, 5)

			SKP_1:TakeDamage(skp_1)
			return
		end

		if not gameRules.TeamKill then
			return
		end
		local skp_t = Instance.new("ObjectValue")
		skp_t.Name = "creator"
		skp_t.Value = SKP_0
		skp_t.Parent = SKP_1
		game.Debris:AddItem(skp_t, 5)

		SKP_1:TakeDamage(skp_1 * gameRules.TeamDmgMult)
		return
	end

	local skp_t = Instance.new("ObjectValue")
	skp_t.Name = "creator"
	skp_t.Value = SKP_0
	skp_t.Parent = SKP_1
	Debris:AddItem(skp_t, 5)
	SKP_1:TakeDamage(skp_1)
	return
end

local function Damage(SKP_0, SKP_1, SKP_2, SKP_3, SKP_4, SKP_5, SKP_6, SKP_7, SKP_8)
	if SKP_0.Team == Teams.Spawn then
		return
	end

	if not SKP_0 or not SKP_0.Character then
		return
	end

	if not SKP_0.Character:FindFirstChild("Humanoid") or SKP_0.Character.Humanoid.Health <= 0 then
		return
	end

	if SKP_7 then
		return SKP_0.Character.Humanoid:TakeDamage(math.max(SKP_8, 0))
	end

	if SKP_1 then
		return CalculateDMG(SKP_0, SKP_2, SKP_3, SKP_4, SKP_5, SKP_6)
	end
end

local function loadAttachment(weapon, WeaponData)
	if not weapon or not WeaponData or not weapon:FindFirstChild("Nodes") then
		return
	end
	--load sight Att
	if weapon.Nodes:FindFirstChild("Sight") and WeaponData.SightAtt ~= "" then
		local SightAtt = AttModels[WeaponData.SightAtt]:Clone()
		SightAtt.Parent = weapon
		SightAtt:SetPrimaryPartCFrame(weapon.Nodes.Sight.CFrame)

		for _, key in pairs(weapon:GetChildren()) do
			if not key:IsA("BasePart") or key.Name ~= "IS" then
				continue
			end
			key.Transparency = 1
		end

		for _, key in pairs(SightAtt:GetChildren()) do
			if key.Name == "SightMark" or key.Name == "Main" then
				key:Destroy()
				continue
			end
			if not key:IsA("BasePart") then
				continue
			end
			Ultil.Weld(weapon:WaitForChild("Handle"), key)
			key.Anchored = false
			key.CanCollide = false
		end
	end

	--load Barrel Att
	if weapon.Nodes:FindFirstChild("Barrel") and WeaponData.BarrelAtt ~= "" then
		local BarrelAtt = AttModels[WeaponData.BarrelAtt]:Clone()
		BarrelAtt.Parent = weapon
		BarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.Barrel.CFrame)

		if BarrelAtt:FindFirstChild("BarrelPos") then
			weapon.Handle.Muzzle.WorldCFrame = BarrelAtt.BarrelPos.CFrame
		end

		for _, key in pairs(BarrelAtt:GetChildren()) do
			if not key:IsA("BasePart") then
				continue
			end
			Ultil.Weld(weapon:WaitForChild("Handle"), key)
			key.Anchored = false
			key.CanCollide = false
		end
	end

	--load Under Barrel Att
	if weapon.Nodes:FindFirstChild("UnderBarrel") and WeaponData.UnderBarrelAtt ~= "" then
		local UnderBarrelAtt = AttModels[WeaponData.UnderBarrelAtt]:Clone()
		UnderBarrelAtt.Parent = weapon
		UnderBarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.UnderBarrel.CFrame)

		for _, key in pairs(UnderBarrelAtt:GetChildren()) do
			if not key:IsA("BasePart") then
				continue
			end
			Ultil.Weld(weapon:WaitForChild("Handle"), key)
			key.Anchored = false
			key.CanCollide = false
		end
	end

	if weapon.Nodes:FindFirstChild("Other") and WeaponData.OtherAtt ~= "" then
		local OtherAtt = AttModels[WeaponData.OtherAtt]:Clone()
		OtherAtt.Parent = weapon
		OtherAtt:SetPrimaryPartCFrame(weapon.Nodes.Other.CFrame)

		for _, key in pairs(OtherAtt:GetChildren()) do
			if not key:IsA("BasePart") then
				continue
			end
			Ultil.Weld(weapon:WaitForChild("Handle"), key)
			key.Anchored = false
			key.CanCollide = false
		end
	end
end

function module.init()
	game.StarterPlayer.CharacterWalkSpeed = gameRules.NormalWalkSpeed
	Evt.AcessId.OnServerInvoke = 1
	Evt.Damage.OnServerInvoke = Damage

	Evt.HitEffect.OnServerEvent:Connect(
		function(Player, Position, HitPart: BasePart, Normal, Material, Settings, LimbDamage)
			Evt.HitEffect:FireAllClients(Player, Position, HitPart, Normal, Material, Settings)

			if not HitPart then
				return
			end
			if Players:GetPlayerFromCharacter(HitPart.Parent) then
				local Humanoid = HitPart.Parent:FindFirstChildWhichIsA("Humanoid")
				if not Humanoid then
					return
				end
				if Humanoid.Health > 0 then
					return
				end
			end

			HitPart:ApplyImpulse((HitPart.Position - Player.Character.PrimaryPart.Position).Unit * LimbDamage)
		end
	)

	Evt.GunStance.OnServerEvent:Connect(function(Player, stance, Data)
		Evt.GunStance:FireAllClients(Player, stance, Data)
	end)

	Evt.ServerBullet.OnServerEvent:Connect(function(Player, Origin, Direction, WeaponData, ModTable)
		Evt.ServerBullet:FireAllClients(Player, Origin, Direction, WeaponData, ModTable)
	end)

	Evt.Stance.OnServerEvent:Connect(function(Player, Stance, Virar)
		if not Player or not Player.Character then
			return
		end

		if not Player.Character:FindFirstChild("Humanoid") or Player.Character.Humanoid.Health <= 0 then
			return
		end

		local ACS_Client = Player.Character:FindFirstChild("ACS_Client")
		if not ACS_Client then
			return
		end

		local Torso = Player.Character:FindFirstChild("Torso")
		local RootPart = Player.Character:FindFirstChild("HumanoidRootPart")

		if not Torso or not RootPart then
			return
		end

		local RootJoint = RootPart:FindFirstChild("RootJoint")
		local RS = Torso:FindFirstChild("Right Shoulder")
		local LS = Torso:FindFirstChild("Left Shoulder")
		local RH = Torso:FindFirstChild("Right Hip")
		local LH = Torso:FindFirstChild("Left Hip")

		if not RootJoint or not RS or not LS or not RH or not LH then
			return
		end

		if Stance == 2 then
			TweenService:Create(
				RootJoint,
				TweenInfo.new(0.3),
				{ C1 = CFrame.new(0, 1.5, 2.45) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(180)) }
			):Play()
			TweenService:Create(
				RH,
				TweenInfo.new(0.3),
				{ C1 = CFrame.new(0.5, 1, 0) * CFrame.Angles(math.rad(-5), math.rad(90), math.rad(0)) }
			):Play()
			TweenService:Create(
				LH,
				TweenInfo.new(0.3),
				{ C1 = CFrame.new(-0.5, 1, 0) * CFrame.Angles(math.rad(-5), math.rad(-90), math.rad(0)) }
			):Play()
		end
		if Virar == 1 then
			if Stance == 0 then
				TweenService:Create(
					RootJoint,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(-1, -0, 0) * CFrame.Angles(math.rad(-90), math.rad(-15), math.rad(-180)) }
				):Play()
				TweenService:Create(
					RH,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(0.5, 1, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)) }
				):Play()
				TweenService:Create(
					LH,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(-0.5, 1, 0) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)) }
				):Play()
			elseif Stance == 1 then
				TweenService:Create(
					RootJoint,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(-1, 0.75, 0.25) * CFrame.Angles(math.rad(-80), math.rad(-15), math.rad(-180)) }
				):Play()
				TweenService:Create(
					RH,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(0.5, 0, 0.4) * CFrame.Angles(math.rad(20), math.rad(90), math.rad(0)) }
				):Play()
				TweenService:Create(
					LH,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(-0.5, 0, 0.4) * CFrame.Angles(math.rad(20), math.rad(-90), math.rad(0)) }
				):Play()
			end
		elseif Virar == -1 then
			if Stance == 0 then
				TweenService:Create(
					RootJoint,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(15), math.rad(180)) }
				):Play()
				TweenService:Create(
					RH,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(0.5, 1, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)) }
				):Play()
				TweenService:Create(
					LH,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(-0.5, 1, 0) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)) }
				):Play()
			elseif Stance == 1 then
				TweenService:Create(
					RootJoint,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(1, 0.75, 0.25) * CFrame.Angles(math.rad(-80), math.rad(15), math.rad(180)) }
				):Play()
				TweenService:Create(
					RH,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(0.5, 0, 0.4) * CFrame.Angles(math.rad(20), math.rad(90), math.rad(0)) }
				):Play()
				TweenService:Create(
					LH,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(-0.5, 0, 0.4) * CFrame.Angles(math.rad(20), math.rad(-90), math.rad(0)) }
				):Play()
			end
		elseif Virar == 0 then
			if Stance == 0 then
				TweenService:Create(
					RootJoint,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(180)) }
				):Play()
				TweenService:Create(
					RH,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(0.5, 1, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)) }
				):Play()
				TweenService:Create(
					LH,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(-0.5, 1, 0) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)) }
				):Play()
			elseif Stance == 1 then
				TweenService:Create(
					RootJoint,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(0, 1, 0.25) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(180)) }
				):Play()
				TweenService:Create(
					RH,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(0.5, 0, 0.4) * CFrame.Angles(math.rad(20), math.rad(90), math.rad(0)) }
				):Play()
				TweenService:Create(
					LH,
					TweenInfo.new(0.3),
					{ C1 = CFrame.new(-0.5, 0, 0.4) * CFrame.Angles(math.rad(20), math.rad(-90), math.rad(0)) }
				):Play()
			end
		end

		if Stance == 2 then
			TweenService:Create(
				RS,
				TweenInfo.new(0.3),
				{ C1 = CFrame.new(-0.5, 0.95, 0) * CFrame.Angles(math.rad(-175), math.rad(90), math.rad(0)) }
			):Play()
			TweenService:Create(
				LS,
				TweenInfo.new(0.3),
				{ C1 = CFrame.new(0.5, 0.95, 0) * CFrame.Angles(math.rad(-175), math.rad(-90), math.rad(0)) }
			):Play()
		else
			--p1.CFrame:inverse() * p2.CFrame
			TweenService:Create(
				RS,
				TweenInfo.new(0.3),
				{ C1 = CFrame.new(-0.5, 0.5, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)) }
			):Play()
			TweenService:Create(
				LS,
				TweenInfo.new(0.3),
				{ C1 = CFrame.new(0.5, 0.5, 0) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)) }
			):Play()
		end
	end)

	Evt.Surrender.OnServerEvent:Connect(function(Player, Victim)
		if not Player or not Player.Character then
			return
		end

		local PClient = nil
		if Victim then
			if Victim == Player or not Victim.Character then
				return
			end

			PClient = Victim.Character:FindFirstChild("ACS_Client")
			if not PClient then
				return
			end

			if PClient:GetAttribute("Surrender") then
				PClient:SetAttribute("Surrender", false)
			end
		end

		PClient = Player.Character:FindFirstChild("ACS_Client")
		if not PClient then
			return
		end

		if not PClient:GetAttribute("Surrender") then
			PClient:SetAttribute("Surrender", true)
		end
	end)

	Evt.Grenade.OnServerEvent:Connect(
		function(
			Player: Player,
			WeaponTool: Tool,
			grenadeName: string,
			cameraCFrame: CFrame,
			lookVector: Vector3,
			power: number
		)
			if not Player or not Player.Character then
				return
			end
			if not Player.Character:FindFirstChild("Humanoid") or Player.Character.Humanoid.Health <= 0 then
				return
			end

			if not WeaponTool or not grenadeName then
				Player:kick("Exploit Protocol")
				warn(Player.Name .. " - Potential Exploiter! Case 3: Tried To Access Grenade Event")
				return
			end

			if not SVGunModels:FindFirstChild(grenadeName) then
				warn("ACS_Server Couldn't Find " .. grenadeName .. " In Grenade Model Folder")
				return
			end

			local skp_0 = SVGunModels[grenadeName]:Clone()

			for _, SKP_Arg1 in pairs(Player.Character:GetChildren()) do
				if not SKP_Arg1:IsA("BasePart") then
					continue
				end
				local skp_1 = Instance.new("NoCollisionConstraint")
				skp_1.Parent = skp_0
				skp_1.Part0 = skp_0.PrimaryPart
				skp_1.Part1 = SKP_Arg1
			end

			local skp_1 = Instance.new("ObjectValue")
			skp_1.Name = "creator"
			skp_1.Value = Player
			skp_1.Parent = skp_0.PrimaryPart

			skp_0.Parent = ACS_Workspace.Server
			skp_0.PrimaryPart.CFrame = cameraCFrame
			skp_0.PrimaryPart:ApplyImpulse(lookVector * power * skp_0.PrimaryPart:GetMass())
			skp_0.PrimaryPart:SetNetworkOwner(nil)
			skp_0.PrimaryPart.Damage.Disabled = false

			WeaponTool:Destroy()
		end
	)

	Evt.Equip.OnServerEvent:Connect(function(Player, Arma, Mode, Settings, Anim)
		if not Player or not Player.Character or not Arma then
			return
		end

		local Head = Player.Character:FindFirstChild("Head")
		local Torso = Player.Character:FindFirstChild("Torso")
		local LeftArm = Player.Character:FindFirstChild("Left Arm")
		local RightArm = Player.Character:FindFirstChild("Right Arm")

		if not Head or not Torso or not LeftArm or not RightArm then
			return
		end
		local RS = Torso:FindFirstChild("Right Shoulder")
		local LS = Torso:FindFirstChild("Left Shoulder")
		if not RS or not LS then
			return
		end

		-- EQUIP
		if Mode == 1 then
			local GunModel = GunModels:FindFirstChild(Arma.Name)
			if not GunModel then
				warn(Player.Name .. ": Couldn't load Server-side weapon model")
				return
			end

			local ServerGun = GunModel:Clone()
			ServerGun.Name = "S" .. Arma.Name

			local AnimBase = Instance.new("Part")
			AnimBase.FormFactor = "Custom"
			AnimBase.CanCollide = false
			AnimBase.Transparency = 1
			AnimBase.Anchored = false
			AnimBase.Name = "AnimBase"
			AnimBase.Size = Vector3.new(0.1, 0.1, 0.1)
			AnimBase.Parent = Player.Character

			local AnimBaseW = Instance.new("Motor6D")
			AnimBaseW.Part0 = Head
			AnimBaseW.Part1 = AnimBase
			AnimBaseW.Parent = AnimBase
			AnimBaseW.Name = "AnimBaseW"

			local ruaw = Instance.new("Motor6D")
			ruaw.Name = "RAW"
			ruaw.Part0 = RightArm
			ruaw.Part1 = AnimBase
			ruaw.Parent = AnimBase
			ruaw.C0 = Anim.SV_RightArmPos
			RS.Enabled = false

			local luaw = Instance.new("Motor6D")
			luaw.Name = "LAW"
			luaw.Part0 = LeftArm
			luaw.Part1 = AnimBase
			luaw.Parent = AnimBase
			luaw.C0 = Anim.SV_LeftArmPos
			LS.Enabled = false

			ServerGun.Parent = Player.Character

			loadAttachment(ServerGun, Settings)

			if ServerGun:FindFirstChild("Nodes") ~= nil then
				ServerGun.Nodes:Destroy()
			end

			for _, SKP_002 in ServerGun:GetDescendants() do
				if SKP_002.Name ~= "SightMark" then
					continue
				end
				SKP_002:Destroy()
			end

			for _, SKP_002 in ServerGun:GetDescendants() do
				if not SKP_002:IsA("BasePart") or SKP_002.Name == "Handle" then
					continue
				end
				Ultil.WeldComplex(ServerGun:WaitForChild("Handle"), SKP_002, SKP_002.Name)
			end

			local SKP_004 = Instance.new("Motor6D")
			SKP_004.Name = "Handle"
			SKP_004.Parent = ServerGun.Handle
			SKP_004.Part0 = RightArm
			SKP_004.Part1 = ServerGun.Handle
			SKP_004.C1 = Anim.SV_GunPos:inverse()

			for _, L_75_forvar2 in ServerGun:GetDescendants() do
				if not L_75_forvar2:IsA("BasePart") then
					continue
				end
				L_75_forvar2.Anchored = false
				L_75_forvar2.CanCollide = false
			end
			return
		end

		-- UNEQUIP
		if Mode == 2 then
			if Arma and Player.Character:FindFirstChild("S" .. Arma.Name) then
				Player.Character["S" .. Arma.Name]:Destroy()
				Player.Character.AnimBase:Destroy()
			end

			RS.Enabled = true
			LS.Enabled = true
		end
		return
	end)

	Evt.Squad.OnServerEvent:Connect(function(Player, SquadName, SquadColor)
		if not Player or not Player.Character then
			return
		end
		if not Player.Character:FindFirstChild("ACS_Client") then
			return
		end

		Player.Character.ACS_Client.FireTeam.SquadName.Value = SquadName
		Player.Character.ACS_Client.FireTeam.SquadColor.Value = SquadColor
	end)

	Evt.HeadRot.OnServerEvent:Connect(function(Player, CF)
		if not CF then
			return
		end
		-- Update cached rotation
		HeadRotData.HeadRotations[Player.Name] = CF
	end)

	RunService.Heartbeat:Connect(function()
		if next(HeadRotData.HeadRotations) == nil then
			return
		end

		if tick() - HeadRotData.LastFire < 0.2 then
			return
		end

		HeadRotData.LastFire = tick()
		Evt.HeadRot:FireAllClients(HeadRotData.HeadRotations)

		-- Clear data for next update
		HeadRotData.HeadRotations = {}
	end)

	Evt.Atirar.OnServerEvent:Connect(function(Player, Arma, Suppressor, FlashHider)
		Evt.Atirar:FireAllClients(Player, Arma, Suppressor, FlashHider)
	end)

	Evt.Whizz.OnServerEvent:Connect(function(_, Victim)
		Evt.Whizz:FireClient(Victim)
	end)

	Evt.Suppression.OnServerEvent:Connect(function(_, Victim, Mode, Intensity, Time)
		Evt.Suppression:FireClient(Victim, Mode, Intensity, Time)
	end)

	Evt.Refil.OnServerEvent:Connect(function(_, Stored, NewStored)
		Stored.Value = Stored.Value - NewStored
	end)

	Evt.SVLaser.OnServerEvent:Connect(function(Player, Position, Modo, Cor, IRmode, Arma)
		Evt.SVLaser:FireAllClients(Player, Position, Modo, Cor, IRmode, Arma)
	end)

	Evt.SVFlash.OnServerEvent:Connect(function(Player, Arma, Mode)
		Evt.SVFlash:FireAllClients(Player, Arma, Mode)
	end)

	Evt.SVSuppressor.OnServerEvent:Connect(function(Player, Arma, Mode)
		Evt.SVSuppressor:FireAllClients(Player, Arma, Mode)
	end)

	Players.PlayerAdded:Connect(function(player)
		if gameRules.AgeRestrictEnabled and not RunService:IsStudio() then
			if player.AccountAge < gameRules.AgeLimit then
				player:Kick(
					"Age restricted server! Please wait: " .. (gameRules.AgeLimit - player.AccountAge) .. " Days"
				)
			end
		end

		player.CharacterAdded:Connect(function(char)
			char.Humanoid.BreakJointsOnDeath = false
			char.Humanoid.Died:Connect(function()
				pcall(function()
					Ragdoll(char)
				end)
			end)
		end)
	end)
end

return module
