local module = {}

local Services = {
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	User = game:GetService("UserInputService"),
	CAS = game:GetService("ContextActionService"),
	Run = game:GetService("RunService"),
	TS = game:GetService("TweenService"),
	Debris = game:GetService("Debris"),
	Players = game:GetService("Players"),
	StarterPlayer = game:GetService("StarterPlayer"),
}

local ACS_Workspace = workspace:WaitForChild("ACS_WorkSpace")
local EngineDir = Services.ReplicatedStorage:WaitForChild("ACS_Engine")
local Engine = {
	Evt = EngineDir:WaitForChild("Events"),
	Mods = EngineDir:WaitForChild("Modules"),
	HUDs = EngineDir:WaitForChild("HUD"),
	Essential = EngineDir:WaitForChild("Essential"),
	ArmModel = EngineDir:WaitForChild("ArmModel"),
	GunModels = EngineDir:WaitForChild("GunModels"),
	AttModels = EngineDir:WaitForChild("AttModels"),
	AttModules = EngineDir:WaitForChild("AttModules"),
	Rules = EngineDir:WaitForChild("GameRules"),
	PastaFx = EngineDir:WaitForChild("FX"),
}

local gameRules = require(Engine.Rules:WaitForChild("Config"))
local Mods = {
	SpringMod = require(Engine.Mods:WaitForChild("Spring")),
	HitMod = require(Engine.Mods:WaitForChild("Hitmarker")),
	Thread = require(Engine.Mods:WaitForChild("Thread")),
	Ultil = require(Engine.Mods:WaitForChild("Utilities")),
	ACSModifier = require(Engine.Mods:WaitForChild("ACSModifier")),
}

local plr = Services.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local mouse = plr:GetMouse()
local cam = workspace.CurrentCamera
local ACS_Client = char:WaitForChild("ACS_Client")

local Ammo, StoredAmmo
local WeaponInHand, WeaponTool, WeaponData, AnimData
local ViewModel, AnimPart, LArm, RArm, LArmWeld, RArmWeld, GunWeld
local SightData, BarrelData, UnderBarrelData, OtherData
local generateBullet = 1
local BSpread
local RecoilPower
local LastSpreadUpdate = time()
local SE_GUI

local CHup, CHdown, CHleft, CHright = UDim2.new(), UDim2.new(), UDim2.new(), UDim2.new()

local bulletCache = {}
local bulletsFired = 0

local ACSData = {
	Crouched = false,
	Prone = false,
	harspeed = 0,
	running = false,
	runKeyDown = false,
	aiming = false,
	shooting = false,
	reloading = false,
	mouse1down = false,
	AnimDebounce = false,
	CancelReload = false,
	SafeMode = false,
	JumpDelay = false,
	CheckingMag = false,
	GunStance = 0,
	AimPartMode = 1,
	SightAtt = nil,
	CurAimpart = nil,
	BarrelAtt = nil,
	Suppressor = false,
	SuppressorAtt = false,
	FlashHider = false,
	UnderBarrelAtt = nil,
	OtherAtt = nil,
	LaserAtt = false,
	LaserActive = false,
	IRmode = false,
	IREnable = false,
	Pointer = nil,
	TorchAtt = false,
	TorchActive = false,
	BipodAtt = false,
	CanBipod = false,
	BipodActive = false,
	GRDebounce = false,
	CookGrenade = false,
	ToolEquip = false,
	Sens = 50,
	Power = 150,
	BipodCF = CFrame.new(),
	NearZ = CFrame.new(0, 0, -0.5),
}

local ModTable = {
	camRecoilMod = {
		RecoilTilt = 1,
		RecoilUp = 1,
		RecoilLeft = 1,
		RecoilRight = 1,
	},
	gunRecoilMod = {
		RecoilUp = 1,
		RecoilTilt = 1,
		RecoilLeft = 1,
		RecoilRight = 1,
	},
	ZoomValue = 70,
	Zoom2Value = 70,
	AimRM = 1,
	SpreadRM = 1,
	DamageMod = 1,
	minDamageMod = 1,
	MinRecoilPower = 1,
	MaxRecoilPower = 1,
	RecoilPowerStepAmount = 1,
	MinSpread = 1,
	MaxSpread = 1,
	AimInaccuracyStepAmount = 1,
	AimInaccuracyDecrease = 1,
	WalkMult = 1,
	adsTime = 1,
	MuzzleVelocity = 1,
}

local maincf = CFrame.new()
local guncf = CFrame.new()
local gunbobcf = CFrame.new()
local recoilcf = CFrame.new()
local aimcf = CFrame.new()
local AimTween = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

local Ignore_Model = { cam, char, ACS_Workspace.Client, ACS_Workspace.Server }

local ModStorageFolder = plr.PlayerGui:FindFirstChild("ModStorage") or Instance.new("Folder")
ModStorageFolder.Parent = plr.PlayerGui
ModStorageFolder.Name = "ModStorage"

local function RAND(Min, Max, Accuracy)
	local Inverse = 1 / (Accuracy or 1)
	return (math.random(Min * Inverse, Max * Inverse) / Inverse)
end

SE_GUI = Engine.HUDs:WaitForChild("StatusUI"):Clone()
SE_GUI.Parent = plr.PlayerGui

local BloodScreen = Services.TS:Create(
	SE_GUI.Efeitos.Health,
	TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut, -1, true),
	{ Size = UDim2.new(1.2, 0, 1.4, 0) }
)
local BloodScreenLowHP = Services.TS:Create(
	SE_GUI.Efeitos.LowHealth,
	TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut, -1, true),
	{ Size = UDim2.new(1.2, 0, 1.4, 0) }
)

local Crosshair = SE_GUI.Crosshair

local RecoilSpring = Mods.SpringMod.new(Vector3.new())
RecoilSpring.d = 0.05
RecoilSpring.s = 20

local cameraspring = Mods.SpringMod.new(Vector3.new())
cameraspring.d = 0.5
cameraspring.s = 20

local SwaySpring = Mods.SpringMod.new(Vector3.new())
SwaySpring.d = 1
SwaySpring.s = 10

local Stance = Engine.Evt.Stance
local Stances = 0
local Virar = 0
local CameraX = 0
local CameraY = 0

local Sentado = false
local Swimming = false
local falling = false
local Steady = false
local CanLean = true
local ChangeStance = true

--// Char Parts
local Humanoid = char:WaitForChild("Humanoid")
local Torso = char:WaitForChild("Torso")
local HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
local Neck = Torso:WaitForChild("Neck")

local CFNew, CFAng = CFrame.new, CFrame.Angles
local Asin = math.asin

Services.User.MouseIconEnabled = true
plr.CameraMode = Enum.CameraMode.Classic

cam.CameraType = Enum.CameraType.Custom
cam.CameraSubject = Humanoid

if gameRules.TeamTags then
	local tag = Engine.Essential.TeamTag:clone()
	tag.Parent = char
	tag.Disabled = false
end

local function resetMods()
	ModTable.camRecoilMod.RecoilUp = 1
	ModTable.camRecoilMod.RecoilLeft = 1
	ModTable.camRecoilMod.RecoilRight = 1
	ModTable.camRecoilMod.RecoilTilt = 1

	ModTable.gunRecoilMod.RecoilUp = 1
	ModTable.gunRecoilMod.RecoilTilt = 1
	ModTable.gunRecoilMod.RecoilLeft = 1
	ModTable.gunRecoilMod.RecoilRight = 1

	ModTable.AimRM = 1
	ModTable.SpreadRM = 1
	ModTable.DamageMod = 1
	ModTable.minDamageMod = 1

	ModTable.MinRecoilPower = 1
	ModTable.MaxRecoilPower = 1
	ModTable.RecoilPowerStepAmount = 1

	ModTable.MinSpread = 1
	ModTable.MaxSpread = 1
	ModTable.AimInaccuracyStepAmount = 1
	ModTable.AimInaccuracyDecrease = 1
	ModTable.WalkMult = 1
	ModTable.MuzzleVelocity = 1
end

local function setMods(ModData)
	ModTable.camRecoilMod.RecoilUp = ModTable.camRecoilMod.RecoilUp * ModData.camRecoil.RecoilUp
	ModTable.camRecoilMod.RecoilLeft = ModTable.camRecoilMod.RecoilLeft * ModData.camRecoil.RecoilLeft
	ModTable.camRecoilMod.RecoilRight = ModTable.camRecoilMod.RecoilRight * ModData.camRecoil.RecoilRight
	ModTable.camRecoilMod.RecoilTilt = ModTable.camRecoilMod.RecoilTilt * ModData.camRecoil.RecoilTilt

	ModTable.gunRecoilMod.RecoilUp = ModTable.gunRecoilMod.RecoilUp * ModData.gunRecoil.RecoilUp
	ModTable.gunRecoilMod.RecoilTilt = ModTable.gunRecoilMod.RecoilTilt * ModData.gunRecoil.RecoilTilt
	ModTable.gunRecoilMod.RecoilLeft = ModTable.gunRecoilMod.RecoilLeft * ModData.gunRecoil.RecoilLeft
	ModTable.gunRecoilMod.RecoilRight = ModTable.gunRecoilMod.RecoilRight * ModData.gunRecoil.RecoilRight

	ModTable.AimRM = ModTable.AimRM * ModData.AimRecoilReduction
	ModTable.SpreadRM = ModTable.SpreadRM * ModData.AimSpreadReduction
	ModTable.DamageMod = ModTable.DamageMod * ModData.DamageMod
	ModTable.minDamageMod = ModTable.minDamageMod * ModData.minDamageMod

	ModTable.MinRecoilPower = ModTable.MinRecoilPower * ModData.MinRecoilPower
	ModTable.MaxRecoilPower = ModTable.MaxRecoilPower * ModData.MaxRecoilPower
	ModTable.RecoilPowerStepAmount = ModTable.RecoilPowerStepAmount * ModData.RecoilPowerStepAmount

	ModTable.MinSpread = ModTable.MinSpread * ModData.MinSpread
	ModTable.MaxSpread = ModTable.MaxSpread * ModData.MaxSpread
	ModTable.AimInaccuracyStepAmount = ModTable.AimInaccuracyStepAmount * ModData.AimInaccuracyStepAmount
	ModTable.AimInaccuracyDecrease = ModTable.AimInaccuracyDecrease * ModData.AimInaccuracyDecrease
	ModTable.WalkMult = ModTable.WalkMult * ModData.WalkMult
	ModTable.MuzzleVelocity = ModTable.MuzzleVelocity * ModData.MuzzleVelocityMod
end

local function UpdateGui()
	if not SE_GUI or not WeaponData then
		return
	end
	local HUD = SE_GUI.GunHUD

	HUD.NText.Text = WeaponData.gunName
	HUD.BText.Text = WeaponData.BulletType
	HUD.A.Visible = ACSData.SafeMode
	HUD.Att.Bipod.Visible = ACSData.BipodAtt
	HUD.Sens.Text = (ACSData.Sens / 100)

	if WeaponData.Jammed then
		HUD.B.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	else
		HUD.B.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end

	if Ammo > 0 then
		HUD.B.Visible = true
	else
		HUD.B.Visible = false
	end

	if WeaponData.ShootType == 1 then
		HUD.FText.Text = "Semi"
	elseif WeaponData.ShootType == 2 then
		HUD.FText.Text = "Burst"
	elseif WeaponData.ShootType == 3 then
		HUD.FText.Text = "Auto"
	elseif WeaponData.ShootType == 4 then
		HUD.FText.Text = "Pump-Action"
	elseif WeaponData.ShootType == 5 then
		HUD.FText.Text = "Bolt-Action"
	end

	if WeaponData.EnableZeroing then
		HUD.ZeText.Visible = true
		HUD.ZeText.Text = WeaponData.CurrentZero .. " m"
	else
		HUD.ZeText.Visible = false
	end

	if WeaponData.MagCount then
		HUD.SAText.Text = math.ceil(StoredAmmo / WeaponData.Ammo)
		HUD.Magazines.Visible = true
		HUD.Bullets.Visible = false
	else
		HUD.SAText.Text = StoredAmmo
		HUD.Magazines.Visible = false
		HUD.Bullets.Visible = true
	end

	if ACSData.LaserAtt then
		HUD.Att.Laser.Visible = true
		if ACSData.LaserActive then
			if ACSData.IRmode then
				Services.TS
					:Create(
						HUD.Att.Laser,
						TweenInfo.new(0.1, Enum.EasingStyle.Linear),
						{ ImageColor3 = Color3.fromRGB(0, 255, 0), ImageTransparency = 0.123 }
					)
					:Play()
			else
				Services.TS
					:Create(
						HUD.Att.Laser,
						TweenInfo.new(0.1, Enum.EasingStyle.Linear),
						{ ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 0.123 }
					)
					:Play()
			end
		else
			Services.TS
				:Create(
					HUD.Att.Laser,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear),
					{ ImageColor3 = Color3.fromRGB(255, 0, 0), ImageTransparency = 0.5 }
				)
				:Play()
		end
	else
		HUD.Att.Laser.Visible = false
	end

	if ACSData.TorchAtt then
		HUD.Att.Flash.Visible = true
		if ACSData.TorchActive then
			Services.TS
				:Create(
					HUD.Att.Flash,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear),
					{ ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 0.123 }
				)
				:Play()
		else
			Services.TS
				:Create(
					HUD.Att.Flash,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear),
					{ ImageColor3 = Color3.fromRGB(255, 0, 0), ImageTransparency = 0.5 }
				)
				:Play()
		end
	else
		HUD.Att.Flash.Visible = false
	end

	if ACSData.SuppressorAtt then
		HUD.Att.Silencer.Visible = true
		if ACSData.Suppressor then
			Services.TS
				:Create(
					HUD.Att.Silencer,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear),
					{ ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 0.123 }
				)
				:Play()
		else
			Services.TS
				:Create(
					HUD.Att.Silencer,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear),
					{ ImageColor3 = Color3.fromRGB(255, 0, 0), ImageTransparency = 0.5 }
				)
				:Play()
		end
	else
		HUD.Att.Silencer.Visible = false
	end

	if WeaponData.Type == "Grenade" then
		SE_GUI.GrenadeForce.Visible = true
	else
		SE_GUI.GrenadeForce.Visible = false
	end
end

local function CheckForHumanoid(L_225_arg1)
	local L_226_ = false
	local L_227_ = nil
	if L_225_arg1 then
		if
			L_225_arg1.Parent:FindFirstChildOfClass("Humanoid")
			or L_225_arg1.Parent.Parent:FindFirstChildOfClass("Humanoid")
		then
			L_226_ = true
			if L_225_arg1.Parent:FindFirstChildOfClass("Humanoid") then
				L_227_ = L_225_arg1.Parent:FindFirstChildOfClass("Humanoid")
			elseif L_225_arg1.Parent.Parent:FindFirstChildOfClass("Humanoid") then
				L_227_ = L_225_arg1.Parent.Parent:FindFirstChildOfClass("Humanoid")
			end
		else
			L_226_ = false
		end
	end
	return L_226_, L_227_
end

local function IdleAnim()
	pcall(function()
		AnimData.IdleAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
	ACSData.AnimDebounce = true
end

local function SprintAnim()
	ACSData.AnimDebounce = false
	pcall(function()
		AnimData.SprintAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

local function RunCheck()
	if ACSData.runKeyDown then
		ACSData.mouse1down = false
		ACSData.GunStance = 3
		Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
		SprintAnim()
	else
		if ACSData.aiming then
			ACSData.GunStance = 2
			Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
		else
			ACSData.GunStance = 0
			Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
		end
		IdleAnim()
	end
end

----------//Animation Loader\\----------
local function EquipAnim()
	ACSData.AnimDebounce = false
	pcall(function()
		AnimData.EquipAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
	ACSData.AnimDebounce = true
end

local function HighReady()
	pcall(function()
		AnimData.HighReady({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

local function LowReady()
	pcall(function()
		AnimData.LowReady({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

local function Patrol()
	pcall(function()
		AnimData.Patrol({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

local function ReloadAnim()
	pcall(function()
		AnimData.ReloadAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

local function TacticalReloadAnim()
	pcall(function()
		AnimData.TacticalReloadAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

local function JammedAnim()
	pcall(function()
		AnimData.JammedAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

local function PumpAnim()
	ACSData.reloading = true
	pcall(function()
		AnimData.PumpAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
	ACSData.reloading = false
end

local function MagCheckAnim()
	ACSData.CheckingMag = true
	pcall(function()
		AnimData.MagCheck({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
	ACSData.CheckingMag = false
end

local function meleeAttack()
	pcall(function()
		AnimData.meleeAttack({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

local function GrenadeReady()
	pcall(function()
		AnimData.GrenadeReady({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

local function GrenadeThrow()
	pcall(function()
		AnimData.GrenadeThrow({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

local function Stand()
	Stance:FireServer(Stances, Virar)
	Services.TS
		:Create(
			char.Humanoid,
			TweenInfo.new(0.3),
			{ CameraOffset = Vector3.new(CameraX, CameraY, char.Humanoid.CameraOffset.Z) }
		)
		:Play()

	SE_GUI.MainFrame.Poses.Levantado.Visible = true
	SE_GUI.MainFrame.Poses.Agaixado.Visible = false
	SE_GUI.MainFrame.Poses.Deitado.Visible = false

	if Steady then
		char.Humanoid.WalkSpeed = gameRules.SlowPaceWalkSpeed
	else
		if ACS_Client:GetAttribute("Injured") then
			char.Humanoid.WalkSpeed = gameRules.InjuredWalksSpeed
		else
			char.Humanoid.WalkSpeed = gameRules.NormalWalkSpeed
		end
	end
	char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
end

local function Crouch()
	Stance:FireServer(Stances, Virar)
	Services.TS
		:Create(
			char.Humanoid,
			TweenInfo.new(0.3),
			{ CameraOffset = Vector3.new(CameraX, CameraY, char.Humanoid.CameraOffset.Z) }
		)
		:Play()

	SE_GUI.MainFrame.Poses.Levantado.Visible = false
	SE_GUI.MainFrame.Poses.Agaixado.Visible = true
	SE_GUI.MainFrame.Poses.Deitado.Visible = false

	if ACS_Client:GetAttribute("Injured") then
		char.Humanoid.WalkSpeed = gameRules.InjuredCrouchWalkSpeed
	else
		char.Humanoid.WalkSpeed = gameRules.CrouchWalkSpeed
	end
	char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
end

local function Prone()
	Stance:FireServer(Stances, Virar)
	Services.TS
		:Create(
			char.Humanoid,
			TweenInfo.new(0.3),
			{ CameraOffset = Vector3.new(CameraX, CameraY, char.Humanoid.CameraOffset.Z) }
		)
		:Play()

	SE_GUI.MainFrame.Poses.Levantado.Visible = false
	SE_GUI.MainFrame.Poses.Agaixado.Visible = false
	SE_GUI.MainFrame.Poses.Deitado.Visible = true

	if ACS_Client:GetAttribute("Surrender") then
		char.Humanoid.WalkSpeed = 0
	else
		char.Humanoid.WalkSpeed = gameRules.ProneWalksSpeed
	end

	char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
end

local function Lean()
	Services.TS
		:Create(
			char.Humanoid,
			TweenInfo.new(0.3),
			{ CameraOffset = Vector3.new(CameraX, CameraY, char.Humanoid.CameraOffset.Z) }
		)
		:Play()
	Stance:FireServer(Stances, Virar)

	if Virar == 0 then
		SE_GUI.MainFrame.Poses.Esg_Left.Visible = false
		SE_GUI.MainFrame.Poses.Esg_Right.Visible = false
	elseif Virar == 1 then
		SE_GUI.MainFrame.Poses.Esg_Left.Visible = false
		SE_GUI.MainFrame.Poses.Esg_Right.Visible = true
	elseif Virar == -1 then
		SE_GUI.MainFrame.Poses.Esg_Left.Visible = true
		SE_GUI.MainFrame.Poses.Esg_Right.Visible = false
	end
end

local Tracers = 0
local function TracerCalculation()
	if not WeaponData.Tracer and not WeaponData.BulletFlare then
		return false
	end

	if WeaponData.RandomTracer.Enabled then
		if math.random(1, 100) <= WeaponData.RandomTracer.Chance then
			return true
		end
		return false
	end

	if Tracers >= WeaponData.TracerEveryXShots then
		Tracers = 0
		return true
	end
	Tracers = Tracers + 1
	return false
end

local function CastRay(Bullet, Origin)
	if not Bullet or not Origin then
		return
	end

	if not bulletCache[Bullet] then
		bulletCache[Bullet] = {
			Origin = Origin,
			Bpos = Bullet.Position,
			Bpos2 = cam.CFrame.Position,
			recast = false,
			TotalDistTraveled = 0,
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
	bulletCache[Bullet].TotalDistTraveled = (Bullet.Position - bulletCache[Bullet].Origin).Magnitude
	bulletRaycastParams.FilterDescendantsInstances = Ignore_Model
	bulletCache[Bullet].raycastResult = workspace:Raycast(
		bulletCache[Bullet].Bpos2,
		(bulletCache[Bullet].Bpos - bulletCache[Bullet].Bpos2) * 1,
		bulletRaycastParams
	)

	if bulletCache[Bullet].raycastResult then
		local raycastResult = bulletCache[Bullet].raycastResult
		local Hit2 = bulletCache[Bullet].raycastResult.Instance

		-- Ignoring parts
		if
			Hit2 and Hit2.Name == "Ignorable"
			or Hit2.Name == "Glass"
			or Hit2.Name == "Ignore"
			or Hit2.Parent.Name == "Top"
			or Hit2.Parent.Name == "Helmet"
			or Hit2.Parent.Name == "Up"
			or Hit2.Parent.Name == "Down"
			or Hit2.Parent.Name == "Face"
			or Hit2.Parent.Name == "Olho"
			or Hit2.Parent.Name == "Headset"
			or Hit2.Parent.Name == "Numero"
			or Hit2.Parent.Name == "Vest"
			or Hit2.Parent.Name == "Chest"
			or Hit2.Parent.Name == "Waist"
			or Hit2.Parent.Name == "Back"
			or Hit2.Parent.Name == "Belt"
			or Hit2.Parent.Name == "Leg1"
			or Hit2.Parent.Name == "Leg2"
			or Hit2.Parent.Name == "Arm1"
			or Hit2.Parent.Name == "Arm2"
		then
			table.insert(Ignore_Model, Hit2)
			bulletCache[Bullet].recast = true
		end

		if
			Hit2 and Hit2.Parent.Name == "Top"
			or Hit2.Parent.Name == "Helmet"
			or Hit2.Parent.Name == "Up"
			or Hit2.Parent.Name == "Down"
			or Hit2.Parent.Name == "Face"
			or Hit2.Parent.Name == "Olho"
			or Hit2.Parent.Name == "Headset"
			or Hit2.Parent.Name == "Numero"
			or Hit2.Parent.Name == "Vest"
			or Hit2.Parent.Name == "Chest"
			or Hit2.Parent.Name == "Waist"
			or Hit2.Parent.Name == "Back"
			or Hit2.Parent.Name == "Belt"
			or Hit2.Parent.Name == "Leg1"
			or Hit2.Parent.Name == "Leg2"
			or Hit2.Parent.Name == "Arm1"
			or Hit2.Parent.Name == "Arm2"
		then
			table.insert(Ignore_Model, Hit2.Parent)
			bulletCache[Bullet].recast = true
		end

		if
			Hit2
			and (Hit2.Transparency >= 1 or Hit2.CanCollide == false)
			and Hit2.Name ~= "Head"
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

		if Hit2:IsA("Accessory") then -- ignore hats
			table.insert(Ignore_Model, Hit2)
			bulletCache[Bullet].recast = true
		end

		if not bulletCache[Bullet].recast then
			-- When the bullet raycast hits a body part
			Services.Debris:AddItem(Bullet, 0)

			if not bulletCache[Bullet].hit then
				bulletCache[Bullet].hit = true
				local FoundHuman, VitimaHuman = CheckForHumanoid(raycastResult.Instance)
				Mods.HitMod.HitEffect(
					Ignore_Model,
					raycastResult.Position,
					raycastResult.Instance,
					raycastResult.Normal,
					raycastResult.Material,
					WeaponData.CanBreachDoor,
					WeaponData.LimbDamage[1]
				)
				Engine.Evt.HitEffect:FireServer(
					raycastResult.Position,
					raycastResult.Instance,
					raycastResult.Normal,
					raycastResult.Material,
					WeaponData.CanBreachDoor,
					WeaponData.LimbDamage[1]
				)

				local HitPart = raycastResult.Instance
				bulletCache[Bullet].TotalDistTraveled = (raycastResult.Position - bulletCache[Bullet].Origin).Magnitude

				if FoundHuman == true and VitimaHuman.Health > 0 and WeaponData then
					if
						HitPart.Name == "Head"
						or HitPart.Name == "Handle"
						or HitPart.Parent.Name == "Top"
						or HitPart.Parent.Name == "Headset"
						or HitPart.Parent.Name == "Olho"
						or HitPart.Parent.Name == "Face"
						or HitPart.Parent.Name == "Numero"
					then
						Engine.Evt.Damage:InvokeServer(
							WeaponTool,
							VitimaHuman,
							bulletCache[Bullet].TotalDistTraveled,
							1,
							WeaponData,
							ModTable,
							nil,
							nil
						)
					elseif
						HitPart.Name == "Torso"
						or HitPart.Name == "UpperTorso"
						or HitPart.Name == "LowerTorso"
						or HitPart.Parent.Name == "Chest"
						or HitPart.Parent.Name == "Waist"
						or HitPart.Name == "Right Arm"
						or HitPart.Name == "Left Arm"
						or HitPart.Name == "RightUpperArm"
						or HitPart.Name == "RightLowerArm"
						or HitPart.Name == "RightHand"
						or HitPart.Name == "LeftUpperArm"
						or HitPart.Name == "LeftLowerArm"
						or HitPart.Name == "LeftHand"
					then
						Engine.Evt.Damage:InvokeServer(
							WeaponTool,
							VitimaHuman,
							bulletCache[Bullet].TotalDistTraveled,
							2,
							WeaponData,
							ModTable,
							nil,
							nil
						)
					elseif
						HitPart.Name == "Right Leg"
						or HitPart.Name == "Left Leg"
						or HitPart.Name == "RightUpperLeg"
						or HitPart.Name == "RightLowerLeg"
						or HitPart.Name == "RightFoot"
						or HitPart.Name == "LeftUpperLeg"
						or HitPart.Name == "LeftLowerLeg"
						or HitPart.Name == "LeftFoot"
					then
						Engine.Evt.Damage:InvokeServer(
							WeaponTool,
							VitimaHuman,
							bulletCache[Bullet].TotalDistTraveled,
							3,
							WeaponData,
							ModTable,
							nil,
							nil
						)
					end
				end
			end

			bulletCache[Bullet] = nil
		end
	end

	if bulletCache[Bullet] then
		bulletCache[Bullet].Bpos2 = bulletCache[Bullet].Bpos
	end
end

local function CreateBullet()
	bulletsFired += 1
	local Bullet = Instance.new("Part")
	Bullet.Name = plr.Name .. "_Bullet" .. bulletsFired
	Bullet.CanCollide = false
	Bullet.Shape = Enum.PartType.Ball
	Bullet.Transparency = 1
	Bullet.Size = Vector3.new(1, 1, 1)
	Bullet.Parent = ACS_Workspace.Client

	local Origin = WeaponInHand.Handle.Muzzle.WorldPosition
	local Direction = WeaponInHand.Handle.Muzzle.WorldCFrame.LookVector
		+ (
			WeaponInHand.Handle.Muzzle.WorldCFrame.UpVector
			* ((WeaponData.BulletDrop * WeaponData.CurrentZero / 4) / WeaponData.MuzzleVelocity)
			/ 2
		)
	local BulletCF = CFrame.new(Origin, Direction)
	local WalkMul = WeaponData.WalkMult * ModTable.WalkMult
	local BColor = Color3.fromRGB(255, 255, 255)
	local balaspread

	if ACSData.aiming and WeaponData.Bullets <= 1 then
		balaspread = CFrame.Angles(
			math.rad(
				RAND(-BSpread - (ACSData.charspeed / 1) * WalkMul, BSpread + (ACSData.charspeed / 1) * WalkMul)
					/ (10 * WeaponData.AimSpreadReduction)
			),
			math.rad(
				RAND(-BSpread - (ACSData.charspeed / 1) * WalkMul, BSpread + (ACSData.charspeed / 1) * WalkMul)
					/ (10 * WeaponData.AimSpreadReduction)
			),
			math.rad(
				RAND(-BSpread - (ACSData.charspeed / 1) * WalkMul, BSpread + (ACSData.charspeed / 1) * WalkMul)
					/ (10 * WeaponData.AimSpreadReduction)
			)
		)
	else
		balaspread = CFrame.Angles(
			math.rad(
				RAND(-BSpread - (ACSData.charspeed / 1) * WalkMul, BSpread + (ACSData.charspeed / 1) * WalkMul) / 10
			),
			math.rad(
				RAND(-BSpread - (ACSData.charspeed / 1) * WalkMul, BSpread + (ACSData.charspeed / 1) * WalkMul) / 10
			),
			math.rad(
				RAND(-BSpread - (ACSData.charspeed / 1) * WalkMul, BSpread + (ACSData.charspeed / 1) * WalkMul) / 10
			)
		)
	end

	Direction = balaspread * Direction

	local Visivel = TracerCalculation()

	if WeaponData.RainbowMode then
		BColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
	else
		BColor = WeaponData.TracerColor
	end

	if Visivel then
		if gameRules.ReplicatedBullets then
			local Data = {
				Tracer = WeaponData.Tracer,
				TracerColor = WeaponData.TracerColor,
				BulletFlare = WeaponData.BulletFlare,
				MuzzleVelocity = WeaponData.MuzzleVelocity,
			}
			local ModData = {
				MuzzleVelocity = ModTable.MuzzleVelocity,
			}
			Engine.Evt.ServerBullet:FireServer(Origin, Direction, Data, ModData)
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

			local Tracer = Engine.PastaFx.Tracer:Clone()
			Tracer.Color = ColorSequence.new(BColor)
			Tracer.Attachment0 = At1
			Tracer.Attachment1 = At2
			Tracer.Parent = Bullet

			Services.TS
				:Create(Tracer, Mods.ACSModifier.TracerTweenInfo, {
					MaxLength = 5,
					Brightness = 5,
				})
				:Play()
		end

		if WeaponData.BulletFlare == true then
			local bg = Instance.new("BillboardGui")
			bg.Parent = Bullet
			bg.Adornee = Bullet
			bg.Enabled = false

			local flashsize = math.random(20, 30)
			bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			bg.LightInfluence = 0

			local flash = Instance.new("ImageLabel")
			flash.BackgroundTransparency = 1
			flash.Size = UDim2.new(1, 0, 1, 0)
			flash.Position = UDim2.new(0, 0, 0, 0)
			flash.Image = "http://www.roblox.com/asset/?id=1047066405"
			flash.ImageTransparency = 0.5
			flash.ImageColor3 = BColor
			flash.Parent = bg

			task.delay(0.1, function()
				if not Bullet:FindFirstChild("BillboardGui") then
					return
				end
				Bullet.BillboardGui.Enabled = true
			end)
		end
	end

	local BulletMass = Bullet:GetMass()
	local DropForce = Vector3.new(0, BulletMass * workspace.Gravity - 4, 0)
	local BF = Instance.new("BodyForce")
	BF.Parent = Bullet

	Bullet.CFrame = BulletCF
	Bullet:ApplyImpulse(Direction * WeaponData.MuzzleVelocity * ModTable.MuzzleVelocity * 0.5)
	task.delay(0.6, function()
		if not Bullet or not WeaponData then
			return
		end
		Services.TS
			:Create(Bullet, Mods.ACSModifier.BulletDropForceTweenInfo, {
				AssemblyLinearVelocity = Direction * WeaponData.MuzzleVelocity * ModTable.MuzzleVelocity * 0.075,
			})
			:Play()
	end)
	BF.Force = DropForce

	Services.Debris:AddItem(Bullet, 5)

	CastRay(Bullet, Origin)
end

local function SetLaser()
	if gameRules.RealisticLaser and ACSData.IREnable then
		if not ACSData.LaserActive and not ACSData.IRmode then
			ACSData.LaserActive = true
			ACSData.IRmode = true
		elseif ACSData.LaserActive and ACSData.IRmode then
			ACSData.IRmode = false
		else
			ACSData.LaserActive = false
			ACSData.IRmode = false
		end
	else
		ACSData.LaserActive = not ACSData.LaserActive
	end

	WeaponInHand.Handle.Click:play()
	UpdateGui()

	if ACSData.LaserActive then
		if ACSData.Pointer then
			return
		end
		for _, part in WeaponInHand:GetDescendants() do
			if not part:IsA("BasePart") or part.Name ~= "LaserPoint" then
				continue
			end
			local LaserPointer = Instance.new("Part")
			LaserPointer.Shape = "Ball"
			LaserPointer.Size = Vector3.new(0.1, 0.1, 0.1)
			LaserPointer.CanCollide = false
			LaserPointer.Color = part.Color
			LaserPointer.Material = Enum.Material.Neon
			LaserPointer.Parent = part

			local LaserSP = Instance.new("Attachment")
			LaserSP.Parent = part
			local LaserEP = Instance.new("Attachment")
			LaserEP.Parent = LaserPointer

			local Laser = Instance.new("Beam")
			Laser.Transparency = NumberSequence.new(0)
			Laser.LightEmission = 1
			Laser.LightInfluence = 1
			Laser.Color = ColorSequence.new(part.Color)
			Laser.FaceCamera = true
			Laser.Width0 = 0.01
			Laser.Width1 = 0.01
			Laser.Parent = LaserPointer
			Laser.Attachment0 = LaserSP
			Laser.Attachment1 = LaserEP

			if gameRules.RealisticLaser then
				Laser.Enabled = false
			end

			ACSData.Pointer = LaserPointer
			break
		end
	else
		for _, Key in pairs(WeaponInHand:GetDescendants()) do
			if not Key:IsA("BasePart") or Key.Name ~= "LaserPoint" then
				continue
			end
			Key:ClearAllChildren()
			break
		end
		ACSData.Pointer = nil
		if gameRules.ReplicatedLaser then
			Engine.Evt.SVLaser:FireServer(nil, 2, nil, ACSData.IRmode, WeaponTool)
		end
	end
end

local function SetTorch()
	ACSData.TorchActive = not ACSData.TorchActive

	for _, Key in pairs(WeaponInHand:GetDescendants()) do
		if not Key:IsA("BasePart") or Key.Name ~= "FlashPoint" then
			continue
		end
		Key.Light.Enabled = ACSData.TorchActive
	end

	Engine.Evt.SVFlash:FireServer(WeaponTool, ACSData.TorchActive)
	WeaponInHand.Handle.Click:play()
	UpdateGui()
end

local function SetSuppressor()
	ACSData.Suppressor = not ACSData.Suppressor

	for _, v: Instance in WeaponInHand:GetDescendants() do
		if string.find(v.Name, "Suppressor") then
			for _, part in v:GetDescendants() do
				if part:IsA("MeshPart") then
					if ACSData.Suppressor then
						part.Transparency = 0
					else
						part.Transparency = 1
					end
				end
			end
		end
	end

	Engine.Evt.SVSuppressor:FireServer(WeaponTool, ACSData.Suppressor)
	WeaponInHand.Handle.Click:Play()
	UpdateGui()
end

local function ADS()
	if not WeaponData or not WeaponInHand then
		return
	end
	if ACSData.aiming then
		if ACSData.SafeMode then
			ACSData.SafeMode = false
			ACSData.GunStance = 0
			IdleAnim()
			UpdateGui()
		end

		game:GetService("UserInputService").MouseDeltaSensitivity = (ACSData.Sens / 100)

		WeaponInHand.Handle.AimDown:Play()

		ACSData.GunStance = 2
		Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)

		if WeaponData.CrossHair or WeaponData.CenterDot then
			Services.TS
				:Create(Crosshair.Up, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 })
				:Play()
			Services.TS
				:Create(Crosshair.Down, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 })
				:Play()
			Services.TS
				:Create(Crosshair.Left, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 })
				:Play()
			Services.TS
				:Create(Crosshair.Right, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 })
				:Play()
			Services.TS
				:Create(Crosshair.Center, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { ImageTransparency = 1 })
				:Play()
		end
	else
		game:GetService("UserInputService").MouseDeltaSensitivity = 1
		WeaponInHand.Handle.AimUp:Play()

		ACSData.GunStance = 0
		Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)

		if WeaponData.CrossHair then
			Services.TS
				:Create(Crosshair.Up, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 0 })
				:Play()
			Services.TS
				:Create(Crosshair.Down, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 0 })
				:Play()
			Services.TS
				:Create(Crosshair.Left, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 0 })
				:Play()
			Services.TS
				:Create(Crosshair.Right, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 0 })
				:Play()
		end

		if WeaponData.CenterDot then
			Services.TS
				:Create(Crosshair.Center, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { ImageTransparency = 0 })
				:Play()
		else
			Services.TS
				:Create(Crosshair.Center, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { ImageTransparency = 1 })
				:Play()
		end
	end
end

local function SetAimpart()
	if ACSData.aiming then
		if ACSData.AimPartMode == 1 then
			ACSData.AimPartMode = 2
			if WeaponInHand:FindFirstChild("AimPart2") then
				ACSData.CurAimpart = WeaponInHand:FindFirstChild("AimPart2")
			end
		else
			ACSData.AimPartMode = 1
			ACSData.CurAimpart = WeaponInHand:FindFirstChild("AimPart")
		end
		--print("Set to Aimpart: "..ACSData.AimPartMode)
	end
end

local function Firemode()
	WeaponInHand.Handle.SafetyClick:Play()
	ACSData.mouse1down = false

	---Semi Settings---
	if
		WeaponData.ShootType == 1 and WeaponData.FireModes.Burst == true
		or WeaponData.ShootType == 3 and WeaponData.FireModes.Semi == false and WeaponData.FireModes.Burst == true
	then
		WeaponData.ShootType = 2
	elseif
		WeaponData.ShootType == 1 and WeaponData.FireModes.Burst == false and WeaponData.FireModes.Auto == true
		or WeaponData.ShootType == 2 and WeaponData.FireModes.Auto
	then
		WeaponData.ShootType = 3
	elseif
		WeaponData.ShootType == 2 and WeaponData.FireModes.Semi == true and WeaponData.FireModes.Auto == false
		or WeaponData.ShootType == 3 and WeaponData.FireModes.Semi
	then
		WeaponData.ShootType = 1
	end

	UpdateGui()
end

local HalfStep = false

local function HeadMovement()
	if
		not char:FindFirstChild("HumanoidRootPart")
		or not char:FindFirstChild("Humanoid")
		or char.Humanoid.Health <= 0
	then
		return
	end
	if char.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		return
	end
	if not ACS_Client or ACS_Client:GetAttribute("Collapsed") then
		return
	end
	if char:GetAttribute("Laying") then
		return
	end
	local CameraDirection = char.HumanoidRootPart.CFrame:toObjectSpace(cam.CFrame).lookVector
	if Neck then
		HalfStep = not HalfStep
		local neckCFrame = CFNew(0, -0.5, 0)
			* CFAng(0, Asin(CameraDirection.x) / 1.15, 0)
			* CFAng(-Asin(cam.CFrame.LookVector.y) + Asin(char.Torso.CFrame.lookVector.Y), 0, 0)
			* CFAng(-math.rad(90), 0, math.rad(180))
		Services.TS
			:Create(
				Neck,
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{ C1 = neckCFrame }
			)
			:Play()
		if not HalfStep then
			return
		end
		Engine.Evt.HeadRot:FireServer(neckCFrame)
	end
end

local function renderCam()
	cam.CFrame = cam.CFrame * CFrame.Angles(cameraspring.p.x, cameraspring.p.y, cameraspring.p.z)
end

local function renderGunRecoil()
	recoilcf = recoilcf * CFrame.Angles(RecoilSpring.p.x, RecoilSpring.p.y, RecoilSpring.p.z)
end

local function Recoil()
	local vr = (math.random(WeaponData.camRecoil.camRecoilUp[1], WeaponData.camRecoil.camRecoilUp[2]) / 2)
		* ModTable.camRecoilMod.RecoilUp
	local lr = (math.random(WeaponData.camRecoil.camRecoilLeft[1], WeaponData.camRecoil.camRecoilLeft[2]))
		* ModTable.camRecoilMod.RecoilLeft
	local rr = (math.random(WeaponData.camRecoil.camRecoilRight[1], WeaponData.camRecoil.camRecoilRight[2]))
		* ModTable.camRecoilMod.RecoilRight
	local hr = (math.random(-rr, lr) / 2)
	local tr = (math.random(WeaponData.camRecoil.camRecoilTilt[1], WeaponData.camRecoil.camRecoilTilt[2]) / 2)
		* ModTable.camRecoilMod.RecoilTilt

	local RecoilX = math.rad(vr * RAND(1, 1, 0.1))
	local RecoilY = math.rad(hr * RAND(-1, 1, 0.1))
	local RecoilZ = math.rad(tr * RAND(-1, 1, 0.1))

	local gvr = (math.random(WeaponData.gunRecoil.gunRecoilUp[1], WeaponData.gunRecoil.gunRecoilUp[2]) / 10)
		* ModTable.gunRecoilMod.RecoilUp
	local gdr = (
		math.random(-1, 1)
		* math.random(WeaponData.gunRecoil.gunRecoilTilt[1], WeaponData.gunRecoil.gunRecoilTilt[2])
		/ 10
	) * ModTable.gunRecoilMod.RecoilTilt
	local glr = (math.random(WeaponData.gunRecoil.gunRecoilLeft[1], WeaponData.gunRecoil.gunRecoilLeft[2]))
		* ModTable.gunRecoilMod.RecoilLeft
	local grr = (math.random(WeaponData.gunRecoil.gunRecoilRight[1], WeaponData.gunRecoil.gunRecoilRight[2]))
		* ModTable.gunRecoilMod.RecoilRight

	local ghr = (math.random(-grr, glr) / 10)

	local ARR = WeaponData.AimRecoilReduction * ModTable.AimRM

	if ACSData.BipodActive then
		cameraspring:accelerate(Vector3.new(RecoilX, RecoilY / 2, 0))

		if not ACSData.aiming then
			RecoilSpring:accelerate(
				Vector3.new(
					math.rad(0.25 * gvr * RecoilPower),
					math.rad(0.25 * ghr * RecoilPower),
					math.rad(0.25 * gdr)
				)
			)
			recoilcf = recoilcf
				* CFrame.new(0, 0, 0.1)
				* CFrame.Angles(
					math.rad(0.25 * gvr * RecoilPower),
					math.rad(0.25 * ghr * RecoilPower),
					math.rad(0.25 * gdr * RecoilPower)
				)
		else
			RecoilSpring:accelerate(
				Vector3.new(
					math.rad(0.25 * gvr * RecoilPower / ARR),
					math.rad(0.25 * ghr * RecoilPower / ARR),
					math.rad(0.25 * gdr / ARR)
				)
			)
			recoilcf = recoilcf
				* CFrame.new(0, 0, 0.1)
				* CFrame.Angles(
					math.rad(0.25 * gvr * RecoilPower / ARR),
					math.rad(0.25 * ghr * RecoilPower / ARR),
					math.rad(0.25 * gdr * RecoilPower / ARR)
				)
		end

		Mods.Thread:Wait(0.05)
		cameraspring:accelerate(Vector3.new(-RecoilX, -RecoilY / 2, 0))
	else
		cameraspring:accelerate(Vector3.new(RecoilX, RecoilY, RecoilZ))
		if not ACSData.aiming then
			RecoilSpring:accelerate(
				Vector3.new(math.rad(gvr * RecoilPower), math.rad(ghr * RecoilPower), math.rad(gdr))
			)
			recoilcf = recoilcf
				* CFrame.new(0, -0.05, 0.1)
				* CFrame.Angles(math.rad(gvr * RecoilPower), math.rad(ghr * RecoilPower), math.rad(gdr * RecoilPower))
		else
			RecoilSpring:accelerate(
				Vector3.new(math.rad(gvr * RecoilPower / ARR), math.rad(ghr * RecoilPower / ARR), math.rad(gdr / ARR))
			)
			recoilcf = recoilcf
				* CFrame.new(0, 0, 0.1)
				* CFrame.Angles(
					math.rad(gvr * RecoilPower / ARR),
					math.rad(ghr * RecoilPower / ARR),
					math.rad(gdr * RecoilPower / ARR)
				)
		end
	end
end

local function meleeCast()
	-- Set an origin and directional vector
	local rayOrigin = cam.CFrame.Position
	local rayDirection = cam.CFrame.LookVector * WeaponData.BladeRange

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = Ignore_Model
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if raycastResult then
		local Hit2 = raycastResult.Instance

		--Check if it's a hat or accessory
		if Hit2 and Hit2.Parent:IsA("Accessory") then
			for _, players in pairs(Services.Players:GetPlayers()) do
				if not players.Character then
					continue
				end
				for _, hats in pairs(players.Character:GetChildren()) do
					if not hats:IsA("Accessory") then
						continue
					end
					table.insert(Ignore_Model, hats)
				end
			end
			return
		end

		if
			Hit2 and Hit2.Name == "Ignorable"
			or Hit2.Name == "Glass"
			or Hit2.Name == "Ignore"
			or Hit2.Parent.Name == "Top"
			or Hit2.Parent.Name == "Helmet"
			or Hit2.Parent.Name == "Up"
			or Hit2.Parent.Name == "Down"
			or Hit2.Parent.Name == "Face"
			or Hit2.Parent.Name == "Olho"
			or Hit2.Parent.Name == "Headset"
			or Hit2.Parent.Name == "Numero"
			or Hit2.Parent.Name == "Vest"
			or Hit2.Parent.Name == "Chest"
			or Hit2.Parent.Name == "Waist"
			or Hit2.Parent.Name == "Back"
			or Hit2.Parent.Name == "Belt"
			or Hit2.Parent.Name == "Leg1"
			or Hit2.Parent.Name == "Leg2"
			or Hit2.Parent.Name == "Arm1"
			or Hit2.Parent.Name == "Arm2"
		then
			table.insert(Ignore_Model, Hit2)
			return
		end

		if
			Hit2 and Hit2.Parent.Name == "Top"
			or Hit2.Parent.Name == "Helmet"
			or Hit2.Parent.Name == "Up"
			or Hit2.Parent.Name == "Down"
			or Hit2.Parent.Name == "Face"
			or Hit2.Parent.Name == "Olho"
			or Hit2.Parent.Name == "Headset"
			or Hit2.Parent.Name == "Numero"
			or Hit2.Parent.Name == "Vest"
			or Hit2.Parent.Name == "Chest"
			or Hit2.Parent.Name == "Waist"
			or Hit2.Parent.Name == "Back"
			or Hit2.Parent.Name == "Belt"
			or Hit2.Parent.Name == "Leg1"
			or Hit2.Parent.Name == "Leg2"
			or Hit2.Parent.Name == "Arm1"
			or Hit2.Parent.Name == "Arm2"
		then
			table.insert(Ignore_Model, Hit2.Parent)
			return
		end

		if
			Hit2
			and (Hit2.Transparency >= 1 or Hit2.CanCollide == false)
			and Hit2.Name ~= "Head"
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
			return
		end
	end

	if not raycastResult then
		return
	end
	local FoundHuman, VitimaHuman = CheckForHumanoid(raycastResult.Instance)
	Mods.HitMod.HitEffect(
		Ignore_Model,
		raycastResult.Position,
		raycastResult.Instance,
		raycastResult.Normal,
		raycastResult.Material,
		WeaponData
	)
	Engine.Evt.HitEffect:FireServer(
		raycastResult.Position,
		raycastResult.Instance,
		raycastResult.Normal,
		raycastResult.Material,
		WeaponData
	)

	local HitPart = raycastResult.Instance

	if not FoundHuman or VitimaHuman.Health <= 0 then
		return
	end

	if
		HitPart.Name == "Head"
		or HitPart.Parent.Name == "Top"
		or HitPart.Parent.Name == "Headset"
		or HitPart.Parent.Name == "Olho"
		or HitPart.Parent.Name == "Face"
		or HitPart.Parent.Name == "Numero"
	then
		Mods.Thread:Spawn(function()
			Engine.Evt.Damage:InvokeServer(WeaponTool, VitimaHuman, 0, 1, WeaponData, ModTable, nil, nil)
		end)
	elseif
		HitPart.Name == "Torso"
		or HitPart.Name == "UpperTorso"
		or HitPart.Name == "LowerTorso"
		or HitPart.Parent.Name == "Chest"
		or HitPart.Parent.Name == "Waist"
		or HitPart.Name == "RightUpperArm"
		or HitPart.Name == "RightLowerArm"
		or HitPart.Name == "RightHand"
		or HitPart.Name == "LeftUpperArm"
		or HitPart.Name == "LeftLowerArm"
		or HitPart.Name == "LeftHand"
	then
		Mods.Thread:Spawn(function()
			Engine.Evt.Damage:InvokeServer(WeaponTool, VitimaHuman, 0, 2, WeaponData, ModTable, nil, nil)
		end)
	elseif
		HitPart.Name == "Right Arm"
		or HitPart.Name == "Right Leg"
		or HitPart.Name == "Left Leg"
		or HitPart.Name == "Left Arm"
		or HitPart.Name == "RightUpperLeg"
		or HitPart.Name == "RightLowerLeg"
		or HitPart.Name == "RightFoot"
		or HitPart.Name == "LeftUpperLeg"
		or HitPart.Name == "LeftLowerLeg"
		or HitPart.Name == "LeftFoot"
	then
		Mods.Thread:Spawn(function()
			Engine.Evt.Damage:InvokeServer(WeaponTool, VitimaHuman, 0, 3, WeaponData, ModTable, nil, nil)
		end)
	end
end

local function CheckMagFunction()
	if ACSData.aiming then
		ACSData.aiming = false
		ADS()
	end

	if SE_GUI then
		local HUD = SE_GUI.GunHUD

		Services.TS
			:Create(
				HUD.CMText,
				TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0),
				{ TextTransparency = 0, TextStrokeTransparency = 0.75 }
			)
			:Play()

		if Ammo >= WeaponData.Ammo then
			HUD.CMText.Text = "Full"
		elseif Ammo > math.floor(WeaponData.Ammo * 0.75) and Ammo < WeaponData.Ammo then
			HUD.CMText.Text = "Nearly full"
		elseif Ammo < math.floor(WeaponData.Ammo * 0.75) and Ammo > math.floor(WeaponData.Ammo * 0.5) then
			HUD.CMText.Text = "Almost half"
		elseif Ammo == math.floor(WeaponData.Ammo * 0.5) then
			HUD.CMText.Text = "Half"
		elseif Ammo > math.ceil(WeaponData.Ammo * 0.25) and Ammo < math.floor(WeaponData.Ammo * 0.5) then
			HUD.CMText.Text = "Less than half"
		elseif Ammo < math.ceil(WeaponData.Ammo * 0.25) and Ammo > 0 then
			HUD.CMText.Text = "Almost empty"
		elseif Ammo == 0 then
			HUD.CMText.Text = "Empty"
		end

		task.delay(0.25, function()
			Services.TS
				:Create(
					HUD.CMText,
					TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 5),
					{ TextTransparency = 1, TextStrokeTransparency = 1 }
				)
				:Play()
		end)
	end
	ACSData.mouse1down = false
	ACSData.SafeMode = false
	ACSData.GunStance = 0
	Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
	UpdateGui()
	MagCheckAnim()
	RunCheck()
end

local function GrenadeMode()
	if ACSData.Power >= 150 then
		ACSData.Power = 100
		SE_GUI.GrenadeForce.Text = "Mid Throw"
	elseif ACSData.Power >= 100 then
		ACSData.Power = 50
		SE_GUI.GrenadeForce.Text = "Low Throw"
	elseif ACSData.Power >= 50 then
		ACSData.Power = 150
		SE_GUI.GrenadeForce.Text = "High Throw"
	end
end

local function Jammed()
	if not WeaponData or WeaponData.Type ~= "Gun" or not WeaponData.Jammed then
		return
	end
	ACSData.mouse1down = false
	ACSData.reloading = true
	ACSData.SafeMode = false
	ACSData.GunStance = 0
	Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
	UpdateGui()

	JammedAnim()
	WeaponData.Jammed = false
	UpdateGui()
	ACSData.reloading = false
	RunCheck()
end

local function Reload()
	if
		WeaponData.Type == "Gun"
		and StoredAmmo > 0
		and (Ammo < WeaponData.Ammo or WeaponData.IncludeChamberedBullet and Ammo < WeaponData.Ammo + 1)
	then
		ACSData.mouse1down = false
		ACSData.reloading = true
		ACSData.SafeMode = false
		ACSData.GunStance = 0
		Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
		UpdateGui()

		if WeaponData.ShellInsert then
			if Ammo > 0 then
				for _ = 1, WeaponData.Ammo - Ammo do
					if StoredAmmo > 0 and Ammo < WeaponData.Ammo then
						if ACSData.CancelReload then
							break
						end
						ReloadAnim()
						Ammo = Ammo + 1
						StoredAmmo = StoredAmmo - 1
						UpdateGui()
					end
				end
			else
				TacticalReloadAnim()
				Ammo = Ammo + 1
				StoredAmmo = StoredAmmo - 1
				UpdateGui()
				for _ = 1, WeaponData.Ammo - Ammo do
					if StoredAmmo > 0 and Ammo < WeaponData.Ammo then
						if ACSData.CancelReload then
							break
						end
						ReloadAnim()
						Ammo = Ammo + 1
						StoredAmmo = StoredAmmo - 1
						UpdateGui()
					end
				end
			end
		else
			if Ammo > 0 then
				ReloadAnim()
			else
				TacticalReloadAnim()
			end

			if (Ammo - (WeaponData.Ammo - StoredAmmo)) < 0 then
				Ammo = Ammo + StoredAmmo
				StoredAmmo = 0
			elseif Ammo <= 0 or Ammo > 0 and not WeaponData.IncludeChamberedBullet then
				StoredAmmo = StoredAmmo - (WeaponData.Ammo - Ammo)
				Ammo = WeaponData.Ammo
			elseif Ammo > 0 and WeaponData.IncludeChamberedBullet then
				StoredAmmo = StoredAmmo - (WeaponData.Ammo - Ammo) - 1
				Ammo = WeaponData.Ammo + 1
			end
		end
		ACSData.CancelReload = false
		ACSData.reloading = false
		RunCheck()
		UpdateGui()
	end
end

local function GunFx()
	if ACSData.Suppressor == true then
		WeaponInHand.Handle.Muzzle.Supressor:Play()
	else
		WeaponInHand.Handle.Muzzle.Fire:Play()
	end

	if ACSData.FlashHider == true and ACSData.Suppressor == true then
		WeaponInHand.Handle.Muzzle["Smoke"]:Emit(10)
	elseif
		(ACSData.FlashHider == true and ACSData.Suppressor == false)
		or (ACSData.FlashHider == false and ACSData.Suppressor == false)
	then
		WeaponInHand.Handle.Muzzle["FlashFX[Flash]"]:Emit(10)
		WeaponInHand.Handle.Muzzle["Smoke"]:Emit(10)
		task.spawn(function()
			WeaponInHand.Handle.Muzzle.FlashFXLight.Enabled = true
			task.wait(0.05)
			WeaponInHand.Handle.Muzzle.FlashFXLight.Enabled = false
		end)
	end

	if BSpread then
		BSpread = math.min(
			WeaponData.MaxSpread * ModTable.MaxSpread,
			BSpread + WeaponData.AimInaccuracyStepAmount * ModTable.AimInaccuracyStepAmount
		)
		RecoilPower = math.min(
			WeaponData.MaxRecoilPower * ModTable.MaxRecoilPower,
			RecoilPower + WeaponData.RecoilPowerStepAmount * ModTable.RecoilPowerStepAmount
		)
	end

	generateBullet = generateBullet + 1
	LastSpreadUpdate = time()

	if Ammo > 0 or not WeaponData.SlideLock then
		Services.TS
			:Create(
				WeaponInHand.Handle.Slide,
				TweenInfo.new(
					30 / WeaponData.ShootRate,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.InOut,
					0,
					true,
					0
				),
				{ C0 = WeaponData.SlideEx:inverse() }
			)
			:Play()
	elseif Ammo <= 0 and WeaponData.SlideLock then
		Services.TS
			:Create(
				WeaponInHand.Handle.Slide,
				TweenInfo.new(
					30 / WeaponData.ShootRate,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.InOut,
					0,
					false,
					0
				),
				{ C0 = WeaponData.SlideEx:inverse() }
			)
			:Play()
	end
	WeaponInHand.Handle.Chamber.Smoke:Emit(10)
	WeaponInHand.Handle.Chamber.Shell:Emit(1)
end

local function Shoot()
	if WeaponData and WeaponData.Type == "Gun" and not ACSData.shooting and not ACSData.reloading then
		if ACSData.reloading or ACSData.runKeyDown or ACSData.SafeMode or ACSData.CheckingMag then
			ACSData.mouse1down = false
			return
		end

		if Ammo <= 0 or WeaponData.Jammed then
			WeaponInHand.Handle.Click:Play()
			ACSData.mouse1down = false
			return
		end

		ACSData.mouse1down = true

		if AnimData.PreShoot then
			AnimData.PreShoot({
				RArmWeld,
				LArmWeld,
				GunWeld,
				WeaponInHand,
				ViewModel,
			})
		end

		task.delay(0, function()
			if WeaponData and WeaponData.ShootType == 1 then
				ACSData.shooting = true
				Engine.Evt.Atirar:FireServer(WeaponTool, ACSData.Suppressor, ACSData.FlashHider)
				for _ = 1, WeaponData.Bullets do
					Mods.Thread:Spawn(CreateBullet)
				end
				Ammo = Ammo - 1
				GunFx()
				--JamChance()
				UpdateGui()
				Mods.Thread:Spawn(Recoil)
				task.wait(60 / WeaponData.ShootRate)
				ACSData.shooting = false
			elseif WeaponData and WeaponData.ShootType == 2 then
				for _ = 1, WeaponData.BurstShot do
					if ACSData.shooting or Ammo <= 0 or ACSData.mouse1down == false or WeaponData.Jammed then
						break
					end
					ACSData.shooting = true
					Engine.Evt.Atirar:FireServer(WeaponTool, ACSData.Suppressor, ACSData.FlashHider)
					for _ = 1, WeaponData.Bullets do
						Mods.Thread:Spawn(CreateBullet)
					end
					Ammo = Ammo - 1
					GunFx()
					--JamChance()
					UpdateGui()
					Mods.Thread:Spawn(Recoil)
					task.wait(60 / WeaponData.ShootRate)
					ACSData.shooting = false
				end
			elseif WeaponData and WeaponData.ShootType == 3 then
				while ACSData.mouse1down do
					if ACSData.shooting or Ammo <= 0 or WeaponData.Jammed then
						break
					end
					ACSData.shooting = true
					Engine.Evt.Atirar:FireServer(WeaponTool, ACSData.Suppressor, ACSData.FlashHider)
					for _ = 1, WeaponData.Bullets do
						Mods.Thread:Spawn(CreateBullet)
					end
					Ammo = Ammo - 1
					GunFx()
					--JamChance()
					UpdateGui()
					Mods.Thread:Spawn(Recoil)
					task.wait(60 / WeaponData.ShootRate)
					ACSData.shooting = false
				end
			elseif WeaponData and WeaponData.ShootType == 4 or WeaponData and WeaponData.ShootType == 5 then
				ACSData.shooting = true
				Engine.Evt.Atirar:FireServer(WeaponTool, ACSData.Suppressor, ACSData.FlashHider)
				for _ = 1, WeaponData.Bullets do
					Mods.Thread:Spawn(CreateBullet)
				end
				Ammo = Ammo - 1
				GunFx()
				UpdateGui()
				Mods.Thread:Spawn(Recoil)
				PumpAnim()
				RunCheck()
				ACSData.shooting = false
			end
		end)
	elseif WeaponData and WeaponData.Type == "Melee" and not ACSData.runKeyDown then
		if not ACSData.shooting then
			ACSData.shooting = true
			meleeCast()
			meleeAttack()
			RunCheck()
			ACSData.shooting = false
		end
	end
end

local function unset()
	bulletCache = {}
	bulletsFired = 0

	ACSData.ToolEquip = false
	Engine.Evt.Equip:FireServer(WeaponTool, 2)
	--unsetup weapon data module
	Services.CAS:UnbindAction("Fire")
	Services.CAS:UnbindAction("ADS")
	Services.CAS:UnbindAction("ReloadWeapon")
	Services.CAS:UnbindAction("CycleLaser")
	Services.CAS:UnbindAction("CycleLight")
	Services.CAS:UnbindAction("CycleSuppressor")
	Services.CAS:UnbindAction("CycleFiremode")
	Services.CAS:UnbindAction("CycleAimpart")
	Services.CAS:UnbindAction("ZeroUp")
	Services.CAS:UnbindAction("ZeroDown")
	Services.CAS:UnbindAction("CheckMag")

	ACSData.mouse1down = false
	ACSData.aiming = false

	Services.TS:Create(cam, AimTween, { FieldOfView = 70 }):Play()
	Services.TS:Create(Crosshair.Up, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 }):Play()
	Services.TS
		:Create(Crosshair.Down, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 })
		:Play()
	Services.TS
		:Create(Crosshair.Left, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 })
		:Play()
	Services.TS
		:Create(Crosshair.Right, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 })
		:Play()
	Services.TS:Create(Crosshair.Center, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { ImageTransparency = 1 }):Play()

	Services.User.MouseIconEnabled = true
	game:GetService("UserInputService").MouseDeltaSensitivity = 1
	cam.CameraType = Enum.CameraType.Custom
	plr.CameraMode = Enum.CameraMode.Classic

	if WeaponInHand then
		WeaponData.AmmoInGun = Ammo
		WeaponData.StoredAmmo = StoredAmmo

		ViewModel:Destroy()
		ViewModel = nil
		WeaponInHand = nil
		WeaponTool = nil
		LArm = nil
		RArm = nil
		LArmWeld = nil
		RArmWeld = nil
		WeaponData = nil
		AnimData = nil
		ACSData.SightAtt = nil
		ACSData.BarrelAtt = nil
		ACSData.UnderBarrelAtt = nil
		ACSData.OtherAtt = nil
		ACSData.SuppressorAtt = nil
		ACSData.LaserAtt = false
		ACSData.LaserActive = false
		ACSData.IRmode = false
		ACSData.TorchAtt = false
		ACSData.TorchActive = false
		ACSData.BipodAtt = false
		ACSData.BipodActive = false
		ACSData.Pointer = nil
		BSpread = nil
		RecoilPower = nil
		ACSData.Suppressor = false
		ACSData.FlashHider = false
		ACSData.CancelReload = false
		ACSData.reloading = false
		ACSData.SafeMode = false
		ACSData.CheckingMag = false
		ACSData.GRDebounce = false
		ACSData.CookGrenade = false
		ACSData.GunStance = 0
		resetMods()
		generateBullet = 1
		ACSData.AimPartMode = 1

		SE_GUI.GunHUD.Visible = false
		SE_GUI.GrenadeForce.Visible = false
		ACSData.BipodCF = CFrame.new()
		if gameRules.ReplicatedLaser then
			Engine.Evt.SVLaser:FireServer(nil, 2, nil, false, WeaponTool)
		end
	end
end

local function TossGrenade()
	if not WeaponTool or not WeaponData or not ACSData.GRDebounce then
		return
	end
	GrenadeThrow()
	if not WeaponTool or not WeaponData then
		return
	end
	Engine.Evt.Grenade:FireServer(WeaponTool, WeaponData.gunName, cam.CFrame, cam.CFrame.LookVector, ACSData.Power)
	unset()
end

local function Grenade()
	if ACSData.GRDebounce then
		return
	end
	ACSData.GRDebounce = true
	GrenadeReady()

	repeat
		task.wait()
	until not ACSData.CookGrenade
	TossGrenade()
end

local actionFunctions = {
	["Fire"] = function(inputState)
		if inputState == Enum.UserInputState.Begin and ACSData.AnimDebounce then
			Shoot()

			if WeaponData.Type == "Grenade" then
				ACSData.CookGrenade = true
				Grenade()
			end
		elseif inputState == Enum.UserInputState.End then
			ACSData.mouse1down = false
			ACSData.CookGrenade = false

			task.spawn(function()
				if AnimData.PostShoot then
					AnimData.PostShoot({
						RArmWeld,
						LArmWeld,
						GunWeld,
						WeaponInHand,
						ViewModel,
					})
				end
			end)
		end
	end,

	["ReloadWeapon"] = function(inputState)
		if
			inputState == Enum.UserInputState.Begin
			and ACSData.AnimDebounce
			and not ACSData.CheckingMag
			and not ACSData.reloading
		then
			if WeaponData.Jammed then
				Jammed()
			else
				Reload()
			end
		elseif inputState == Enum.UserInputState.Begin and ACSData.reloading and WeaponData.ShellInsert then
			ACSData.CancelReload = true
		end
	end,

	["CycleLaser"] = function(inputState)
		if inputState == Enum.UserInputState.Begin and ACSData.LaserAtt then
			SetLaser()
		end
	end,

	["CycleSuppressor"] = function(inputState)
		if inputState == Enum.UserInputState.Begin and ACSData.SuppressorAtt then
			SetSuppressor()
		end
	end,

	["CycleLight"] = function(inputState)
		if inputState == Enum.UserInputState.Begin and ACSData.TorchAtt then
			SetTorch()
		end
	end,

	["CycleFiremode"] = function(inputState)
		if inputState == Enum.UserInputState.Begin and WeaponData and WeaponData.FireModes.ChangeFiremode then
			Firemode()
		end
	end,

	["CycleAimpart"] = function(inputState)
		if inputState == Enum.UserInputState.Begin then
			SetAimpart()
		end
	end,

	["ZeroUp"] = function(inputState)
		if inputState == Enum.UserInputState.Begin and WeaponData and WeaponData.EnableZeroing then
			if WeaponData.CurrentZero < WeaponData.MaxZero then
				WeaponInHand.Handle.Click:play()
				WeaponData.CurrentZero = math.min(WeaponData.CurrentZero + WeaponData.ZeroIncrement, WeaponData.MaxZero)
				UpdateGui()
			end
		end
	end,

	["ZeroDown"] = function(inputState)
		if inputState == Enum.UserInputState.Begin and WeaponData and WeaponData.EnableZeroing then
			if WeaponData.CurrentZero > 0 then
				WeaponInHand.Handle.Click:play()
				WeaponData.CurrentZero = math.max(WeaponData.CurrentZero - WeaponData.ZeroIncrement, 0)
				UpdateGui()
			end
		end
	end,

	["CheckMag"] = function(inputState)
		if
			inputState == Enum.UserInputState.Begin
			and not ACSData.CheckingMag
			and not ACSData.reloading
			and not ACSData.runKeyDown
			and ACSData.AnimDebounce
		then
			CheckMagFunction()
		end
	end,

	["ToggleBipod"] = function(inputState)
		if inputState == Enum.UserInputState.End and ACSData.CanBipod then
			ACSData.BipodActive = not ACSData.BipodActive
			UpdateGui()
		end
	end,

	["ADS"] = function(inputState)
		if inputState == Enum.UserInputState.Begin and ACSData.AnimDebounce then
			if
				WeaponData
				and WeaponData.canAim
				and ACSData.GunStance > -2
				and not ACSData.runKeyDown
				and not ACSData.CheckingMag
			then
				ACSData.aiming = not ACSData.aiming
				ADS()
			end

			if WeaponData.Type == "Grenade" then
				GrenadeMode()
			end
		end
	end,

	["Stand"] = function(inputState)
		if
			inputState == Enum.UserInputState.Begin
			and ChangeStance
			and not Swimming
			and not Sentado
			and not ACSData.runKeyDown
			and not ACS_Client:GetAttribute("Collapsed")
		then
			if Stances == 2 then
				ACSData.Crouched = true
				ACSData.Proned = false
				Stances = 1
				CameraY = -1
				Crouch()
			elseif Stances == 1 then
				ACSData.Crouched = false
				Stances = 0
				CameraY = 0
				Stand()
			end
		end
	end,

	["Crouch"] = function(inputState)
		if
			inputState == Enum.UserInputState.Begin
			and ChangeStance
			and not Swimming
			and not Sentado
			and not ACSData.runKeyDown
			and not ACS_Client:GetAttribute("Collapsed")
		then
			if Stances == 0 then
				Stances = 1
				CameraY = -1
				Crouch()
				ACSData.Crouched = true
			elseif Stances == 1 then
				Stances = 2
				CameraX = 0
				CameraY = -3.25
				Virar = 0
				Lean()
				Prone()
				ACSData.Crouched = false
				ACSData.Proned = true
			end
		end
	end,

	["ToggleWalk"] = function(inputState)
		if inputState == Enum.UserInputState.Begin and ChangeStance and not ACSData.runKeyDown then
			Steady = not Steady

			SE_GUI.MainFrame.Poses.Steady.Visible = Steady

			if Stances == 0 then
				Stand()
			end
		end
	end,

	["LeanLeft"] = function(inputState)
		if
			inputState == Enum.UserInputState.Begin
			and Stances ~= 2
			and ChangeStance
			and not Swimming
			and not ACSData.runKeyDown
			and CanLean
			and not ACS_Client:GetAttribute("Collapsed")
		then
			if Virar == 0 or Virar == 1 then
				Virar = -1
				CameraX = -1.25
			else
				Virar = 0
				CameraX = 0
			end
			Lean()
		end
	end,

	["LeanRight"] = function(inputState)
		if
			inputState == Enum.UserInputState.Begin
			and Stances ~= 2
			and ChangeStance
			and not Swimming
			and not ACSData.runKeyDown
			and CanLean
			and not ACS_Client:GetAttribute("Collapsed")
		then
			if Virar == 0 or Virar == -1 then
				Virar = 1
				CameraX = 1.25
			else
				Virar = 0
				CameraX = 0
			end
			Lean()
			ADS()
		end
	end,

	["Run"] = function(inputState)
		if inputState == Enum.UserInputState.Begin and ACSData.running and not ACS_Client:GetAttribute("Injured") then
			ACSData.mouse1down = false
			ACSData.runKeyDown = true
			Stand()
			Stances = 0
			Virar = 0
			CameraX = 0
			CameraY = 0
			Lean()

			local BonusWalkSpeed = char:GetAttribute("BonusWalkSpeed") or 0
			local PerkWalkSpeed = char:GetAttribute("PerkWalkSpeed") or 0

			char:WaitForChild("Humanoid").WalkSpeed = gameRules.RunWalkSpeed
				+ BonusWalkSpeed
				+ (char.Humanoid.WalkSpeed * (PerkWalkSpeed / 100))

			if ACSData.aiming then
				ACSData.aiming = false
				ADS()
			end

			if
				not ACSData.CheckingMag
				and not ACSData.reloading
				and WeaponData
				and WeaponData.Type ~= "Grenade"
				and (ACSData.GunStance == 0 or ACSData.GunStance == 2 or ACSData.GunStance == 3)
			then
				ACSData.GunStance = 3
				Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
				SprintAnim()
			end
		elseif inputState == Enum.UserInputState.End and ACSData.runKeyDown then
			ACSData.runKeyDown = false
			Stand()
			if
				not ACSData.CheckingMag
				and not ACSData.reloading
				and WeaponData
				and WeaponData.Type ~= "Grenade"
				and (ACSData.GunStance == 0 or ACSData.GunStance == 2 or ACSData.GunStance == 3)
			then
				ACSData.GunStance = 0
				Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
				IdleAnim()
			end
		end
	end,

	--["NVG"] = function(inputState, inputObject)
	--	if inputState == Enum.UserInputState.Begin and not NVGdebounce then
	--		if not plr.Character then return end
	--		local helmet = plr.Character:FindFirstChild("Nods")
	--		if not helmet then return end
	--		local nvg = helmet:FindFirstChild("Up")
	--		if not nvg then return end
	--		NVGdebounce = true
	--		delay(.8,function()
	--			NVG = not NVG
	--			Engine.Evt.NVG:Fire(NVG)
	--			NVGdebounce = false
	--		end)
	--	end
	--end,
}

local function handleAction(actionName, inputState, inputObject)
	if actionFunctions[actionName] ~= nil then
		actionFunctions[actionName](inputState, inputObject)
	end
end

local function loadAttachment(weapon)
	if not weapon or not weapon:FindFirstChild("Nodes") then
		return
	end
	--load sight Att
	if weapon.Nodes:FindFirstChild("Sight") and WeaponData.SightAtt ~= "" then
		SightData = require(Engine.AttModules[WeaponData.SightAtt])

		ACSData.SightAtt = Engine.AttModels[WeaponData.SightAtt]:Clone()
		ACSData.SightAtt.Parent = weapon
		ACSData.SightAtt:SetPrimaryPartCFrame(weapon.Nodes.Sight.CFrame)
		weapon.AimPart.CFrame = ACSData.SightAtt.AimPos.CFrame

		if SightData.SightZoom > 0 then
			ModTable.ZoomValue = SightData.SightZoom
		end

		if SightData.SightZoom2 > 0 then
			ModTable.Zoom2Value = SightData.SightZoom2
		end

		setMods(SightData)

		for _, key in pairs(weapon:GetChildren()) do
			if key.Name ~= "IS" then
				continue
			end
			key.Transparency = 1
		end

		for _, key in pairs(ACSData.SightAtt:GetChildren()) do
			if not key:IsA("BasePart") then
				continue
			end
			Mods.Ultil.Weld(weapon:WaitForChild("Handle"), key)
			key.Anchored = false
			key.CanCollide = false
		end
	end

	--load Barrel Att
	if weapon.Nodes:FindFirstChild("Barrel") ~= nil and WeaponData.BarrelAtt ~= "" then
		BarrelData = require(Engine.AttModules[WeaponData.BarrelAtt])

		ACSData.BarrelAtt = Engine.AttModels[WeaponData.BarrelAtt]:Clone()
		ACSData.BarrelAtt.Parent = weapon
		ACSData.BarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.Barrel.CFrame)

		if ACSData.BarrelAtt:FindFirstChild("BarrelPos") ~= nil then
			weapon.Handle.Muzzle.WorldCFrame = ACSData.BarrelAtt.BarrelPos.CFrame
		end

		ACSData.Suppressor = BarrelData.IsSuppressor
		ACSData.FlashHider = BarrelData.IsFlashHider

		setMods(BarrelData)

		for _, key in pairs(ACSData.BarrelAtt:GetChildren()) do
			if not key:IsA("BasePart") then
				continue
			end
			Mods.Ultil.Weld(weapon:WaitForChild("Handle"), key)
			key.Anchored = false
			key.CanCollide = false
		end
	end

	--load Under Barrel Att
	if weapon.Nodes:FindFirstChild("UnderBarrel") ~= nil and WeaponData.UnderBarrelAtt ~= "" then
		UnderBarrelData = require(Engine.AttModules[WeaponData.UnderBarrelAtt])

		ACSData.UnderBarrelAtt = Engine.AttModels[WeaponData.UnderBarrelAtt]:Clone()
		ACSData.UnderBarrelAtt.Parent = weapon
		ACSData.UnderBarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.UnderBarrel.CFrame)

		setMods(UnderBarrelData)
		ACSData.BipodAtt = UnderBarrelData.IsBipod

		if ACSData.BipodAtt then
			Services.CAS:BindAction("ToggleBipod", handleAction, false, Enum.KeyCode.B, Enum.KeyCode.ButtonR3)
		end

		for _, key in pairs(ACSData.UnderBarrelAtt:GetChildren()) do
			if not key:IsA("BasePart") then
				continue
			end
			Mods.Ultil.Weld(weapon:WaitForChild("Handle"), key)
			key.Anchored = false
			key.CanCollide = false
		end
	end

	if weapon.Nodes:FindFirstChild("Other") ~= nil and WeaponData.OtherAtt ~= "" then
		OtherData = require(Engine.AttModules[WeaponData.OtherAtt])

		ACSData.OtherAtt = Engine.AttModels[WeaponData.OtherAtt]:Clone()
		ACSData.OtherAtt.Parent = weapon
		ACSData.OtherAtt:SetPrimaryPartCFrame(weapon.Nodes.Other.CFrame)

		setMods(OtherData)
		ACSData.LaserAtt = OtherData.EnableLaser
		ACSData.TorchAtt = OtherData.EnableFlashlight

		if OtherData.InfraRed then
			ACSData.IREnable = true
		end

		for _, key in pairs(ACSData.OtherAtt:GetChildren()) do
			if not key:IsA("BasePart") then
				continue
			end
			Mods.Ultil.Weld(weapon:WaitForChild("Handle"), key)
			key.Anchored = false
			key.CanCollide = false
		end
	end
end

local function setup(Tool)
	if not char or not Tool or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
		return
	end

	local ToolCheck = Tool
	local GunModelCheck = Engine.GunModels:FindFirstChild(Tool.Name)

	if not ToolCheck or not GunModelCheck then
		warn("Tool Or Gun Model Doesn't Exist")
		return
	end

	ACSData.ToolEquip = true
	Services.User.MouseIconEnabled = false
	plr.CameraMode = Enum.CameraMode.LockFirstPerson

	WeaponTool = ToolCheck
	WeaponData = require(Tool:FindFirstChild("ACS_Settings"))
	AnimData = require(Tool:FindFirstChild("ACS_Animations"))
	WeaponInHand = GunModelCheck:Clone()
	WeaponInHand.PrimaryPart = WeaponInHand:WaitForChild("Handle")

	Engine.Evt.Equip:FireServer(Tool, 1, WeaponData, AnimData)

	ViewModel = Engine.ArmModel:WaitForChild("Arms"):Clone()
	ViewModel.Name = "Viewmodel"

	if char:WaitForChild("Body Colors") then
		local Colors = char:WaitForChild("Body Colors"):Clone()
		Colors.Parent = ViewModel
	end

	if char:FindFirstChild("Shirt") then
		local Shirt = char:FindFirstChild("Shirt"):Clone()
		Shirt.Parent = ViewModel
	end

	AnimPart = Instance.new("Part")
	AnimPart.Size = Vector3.new(0.1, 0.1, 0.1)
	AnimPart.Anchored = true
	AnimPart.CanCollide = false
	AnimPart.Transparency = 1
	AnimPart.Parent = ViewModel

	ViewModel.PrimaryPart = AnimPart

	LArmWeld = Instance.new("Motor6D")
	LArmWeld.Name = "LeftArm"
	LArmWeld.Part0 = AnimPart
	LArmWeld.Parent = AnimPart

	RArmWeld = Instance.new("Motor6D")
	RArmWeld.Name = "RightArm"
	RArmWeld.Part0 = AnimPart
	RArmWeld.Parent = AnimPart

	GunWeld = Instance.new("Motor6D")
	GunWeld.Name = "Handle"
	GunWeld.Parent = AnimPart

	ViewModel.Parent = cam

	maincf = AnimData.MainCFrame
	guncf = AnimData.GunCFrame

	if WeaponData.CrossHair then
		Services.TS
			:Create(Crosshair.Up, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 0 })
			:Play()
		Services.TS
			:Create(Crosshair.Down, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 0 })
			:Play()
		Services.TS
			:Create(Crosshair.Left, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 0 })
			:Play()
		Services.TS
			:Create(Crosshair.Right, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 0 })
			:Play()

		if WeaponData.Bullets > 1 then
			Crosshair.Up.Rotation = 90
			Crosshair.Down.Rotation = 90
			Crosshair.Left.Rotation = 90
			Crosshair.Right.Rotation = 90
		else
			Crosshair.Up.Rotation = 0
			Crosshair.Down.Rotation = 0
			Crosshair.Left.Rotation = 0
			Crosshair.Right.Rotation = 0
		end
	else
		Services.TS
			:Create(Crosshair.Up, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 })
			:Play()
		Services.TS
			:Create(Crosshair.Down, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 })
			:Play()
		Services.TS
			:Create(Crosshair.Left, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 })
			:Play()
		Services.TS
			:Create(Crosshair.Right, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 })
			:Play()
	end

	if WeaponData.CenterDot then
		Services.TS
			:Create(Crosshair.Center, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { ImageTransparency = 0 })
			:Play()
	else
		Services.TS
			:Create(Crosshair.Center, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { ImageTransparency = 1 })
			:Play()
	end

	LArm = ViewModel:WaitForChild("Left Arm")
	LArmWeld.Part1 = LArm
	LArmWeld.C0 = CFrame.new()
	LArmWeld.C1 = CFrame.new(1, -1, -5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)):inverse()

	RArm = ViewModel:WaitForChild("Right Arm")
	RArmWeld.Part1 = RArm
	RArmWeld.C0 = CFrame.new()
	RArmWeld.C1 = CFrame.new(-1, -1, -5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)):inverse()
	GunWeld.Part0 = RArm

	LArm.Anchored = false
	RArm.Anchored = false

	--setup weapon to camera
	ModTable.ZoomValue = WeaponData.Zoom
	ModTable.Zoom2Value = WeaponData.Zoom2
	ACSData.IREnable = WeaponData.InfraRed

	Services.CAS:BindAction("ReloadWeapon", handleAction, true, Enum.KeyCode.R, Enum.KeyCode.ButtonX)
	Services.CAS:BindAction("Fire", handleAction, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
	Services.CAS:BindAction("ADS", handleAction, true, Enum.UserInputType.MouseButton2, Enum.KeyCode.ButtonL2)
	Services.CAS:BindAction("CycleAimpart", handleAction, false, Enum.KeyCode.T)

	Services.CAS:BindAction("CycleLaser", handleAction, false, Enum.KeyCode.H)
	Services.CAS:BindAction("CycleLight", handleAction, false, Enum.KeyCode.J)
	Services.CAS:BindAction("CycleSuppressor", handleAction, false, Enum.KeyCode.U)

	Services.CAS:BindAction("CycleFiremode", handleAction, false, Enum.KeyCode.V)
	Services.CAS:BindAction("CheckMag", handleAction, false, Enum.KeyCode.M)

	Services.CAS:BindAction("ZeroDown", handleAction, false, Enum.KeyCode.LeftBracket)
	Services.CAS:BindAction("ZeroUp", handleAction, false, Enum.KeyCode.RightBracket)

	Services.CAS:SetTitle("Fire", "Shoot")
	Services.CAS:SetTitle("ADS", "ADS")
	Services.CAS:SetTitle("ReloadWeapon", "Ammo")

	Services.CAS:SetPosition("ReloadWeapon", UDim2.new(0.33, 0, 0.15, 0))
	Services.CAS:SetPosition("Fire", UDim2.new(0.5, 0, 0.15, 0))
	Services.CAS:SetPosition("ADS", UDim2.new(0.5, 0, 0, 0))

	loadAttachment(WeaponInHand)

	BSpread = math.min(WeaponData.MinSpread * ModTable.MinSpread, WeaponData.MaxSpread * ModTable.MaxSpread)
	RecoilPower = math.min(
		WeaponData.MinRecoilPower * ModTable.MinRecoilPower,
		WeaponData.MaxRecoilPower * ModTable.MaxRecoilPower
	)

	Ammo = WeaponData.AmmoInGun
	StoredAmmo = WeaponData.StoredAmmo
	ACSData.CurAimpart = WeaponInHand:FindFirstChild("AimPart")

	for _, Key in pairs(WeaponInHand:GetDescendants()) do
		if Key:IsA("BasePart") then
			Key.CanCollide = false
		end

		if Key:IsA("BasePart") and Key.Name == "FlashPoint" then
			ACSData.TorchAtt = true
		end
		if Key:IsA("BasePart") and Key.Name == "LaserPoint" then
			ACSData.LaserAtt = true
		end
		if string.find(Key.Name, "Suppressor") then
			ACSData.SuppressorAtt = true
			ACSData.Suppressor = true
		end
	end

	if WeaponData.EnableHUD then
		SE_GUI.GunHUD.Visible = true
	end

	UpdateGui()

	for _, key in pairs(WeaponInHand:GetChildren()) do
		if key:IsA("BasePart") and key.Name ~= "Handle" then
			if key.Name ~= "Bolt" and key.Name ~= "Lid" and key.Name ~= "Slide" then
				Mods.Ultil.Weld(WeaponInHand:WaitForChild("Handle"), key)
			end

			if key.Name == "Bolt" or key.Name == "Slide" then
				Mods.Ultil.WeldComplex(WeaponInHand:WaitForChild("Handle"), key, key.Name)
			end

			if key.Name == "Lid" then
				if WeaponInHand:FindFirstChild("LidHinge") then
					Mods.Ultil.Weld(key, WeaponInHand:WaitForChild("LidHinge"))
				else
					Mods.Ultil.Weld(key, WeaponInHand:WaitForChild("Handle"))
				end
			end
		end
	end

	for _, L_214_forvar2 in pairs(WeaponInHand:GetChildren()) do
		if L_214_forvar2:IsA("BasePart") then
			L_214_forvar2.Anchored = false
			L_214_forvar2.CanCollide = false
		end
	end

	if WeaponInHand:FindFirstChild("Nodes") then
		for _, L_214_forvar2 in pairs(WeaponInHand.Nodes:GetChildren()) do
			if L_214_forvar2:IsA("BasePart") then
				Mods.Ultil.Weld(WeaponInHand:WaitForChild("Handle"), L_214_forvar2)
				L_214_forvar2.Anchored = false
				L_214_forvar2.CanCollide = false
			end
		end
	end

	GunWeld.Part1 = WeaponInHand:WaitForChild("Handle")
	GunWeld.C1 = guncf

	WeaponInHand.Parent = ViewModel

	if Ammo <= 0 and WeaponData.Type == "Gun" then
		WeaponInHand.Handle.Slide.C0 = WeaponData.SlideEx:inverse()
	end

	EquipAnim()

	if WeaponData and WeaponData.Type ~= "Grenade" then
		RunCheck()
	end
end

local LeanSpring = {}
LeanSpring.cornerPeek = Mods.SpringMod.new(0)
LeanSpring.cornerPeek.d = 1
LeanSpring.cornerPeek.s = 20
LeanSpring.peekFactor = math.rad(-15)
LeanSpring.dirPeek = 0

function module.init()
	local L_150_ = {}

	function L_150_.Update()
		LeanSpring.cornerPeek.t = LeanSpring.peekFactor * Virar
		local NewLeanCF = CFrame.fromAxisAngle(Vector3.new(0, 0, 1), LeanSpring.cornerPeek.p)
		cam.CFrame = cam.CFrame * NewLeanCF
	end

	Services.Run:BindToRenderStep("Camera Update", 200, L_150_.Update)

	Services.CAS:BindAction("Run", handleAction, true, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3)

	Services.CAS:BindAction("Stand", handleAction, true, Enum.KeyCode.X, Enum.KeyCode.ButtonY)
	Services.CAS:BindAction("Crouch", handleAction, true, Enum.KeyCode.C, Enum.KeyCode.ButtonB)

	Services.CAS:BindAction("ToggleWalk", handleAction, false, Enum.KeyCode.Z)
	Services.CAS:BindAction("LeanLeft", handleAction, false, Enum.KeyCode.Q)
	Services.CAS:BindAction("LeanRight", handleAction, false, Enum.KeyCode.E)
	-- Services.CAS:BindAction("LeanLeft", handleAction, false, Enum.KeyCode.Q, Enum.KeyCode.DPadLeft)
	-- Services.CAS:BindAction("LeanRight", handleAction, false, Enum.KeyCode.E, Enum.KeyCode.DPadRight)

	Services.CAS:SetTitle("Run", "Sprint")
	Services.CAS:SetTitle("Stand", "Stand")
	Services.CAS:SetTitle("Crouch", "Crouch")
	Services.CAS:SetTitle("LeanLeft", "Lean Left")
	Services.CAS:SetTitle("LeanRight", "Lean Right")

	Services.CAS:SetPosition("Crouch", UDim2.new(0.16, 0, 0.82, 0))
	Services.CAS:SetPosition("Stand", UDim2.new(0.08, 0, 0.68, 0))
	Services.CAS:SetPosition("Run", UDim2.new(0.1, 0, 0.52, 0))
	Services.CAS:SetPosition("LeanLeft", UDim2.new(0.15, 0, 0.37, 0))
	Services.CAS:SetPosition("LeanRight", UDim2.new(0.25, 0, 0.24, 0))

	local elapsed = 0

	Services.Run.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.05 then
			return
		end
		elapsed = 0

		for bullet, bulletinfo in bulletCache do
			bulletPhysics(bullet, bulletinfo)
		end
	end)

	char.ChildAdded:Connect(function(Tool)
		if
			Tool:IsA("Tool")
			and Humanoid.Health > 0
			and not ACSData.ToolEquip
			and Tool:FindFirstChild("ACS_Settings") ~= nil
			and (
				require(Tool.ACS_Settings).Type == "Gun"
				or require(Tool.ACS_Settings).Type == "Melee"
				or require(Tool.ACS_Settings).Type == "Grenade"
			)
		then
			local L_370_ = true
			if
				char:WaitForChild("Humanoid").Sit and char.Humanoid.SeatPart:IsA("VehicleSeat")
				or char:WaitForChild("Humanoid").Sit and char.Humanoid.SeatPart:IsA("VehicleSeat")
			then
				L_370_ = false
			end

			if L_370_ then
				if not ACSData.ToolEquip then
					--pcall(function()
					setup(Tool)
					--end)
				elseif ACSData.ToolEquip then
					pcall(function()
						unset()
						setup(Tool)
					end)
				end
			end
		end
	end)

	char.ChildRemoved:Connect(function(Tool)
		if Tool == WeaponTool then
			if ACSData.ToolEquip then
				unset()
			end
		end
	end)

	Humanoid.Running:Connect(function(speed)
		ACSData.charspeed = speed
		if speed > 0.1 then
			ACSData.running = true
		else
			ACSData.running = false
		end
	end)

	Humanoid.Swimming:Connect(function(speed)
		if Swimming then
			ACSData.charspeed = speed
			if speed > 0.1 then
				ACSData.running = true
			else
				ACSData.running = false
			end
		end
	end)

	Humanoid.Died:Connect(function()
		Services.TS:Create(char.Humanoid, TweenInfo.new(1), { CameraOffset = Vector3.new(0, 0, 0) }):Play()
		ChangeStance = false
		Stand()
		Stances = 0
		Virar = 0
		CameraX = 0
		CameraY = 0
		Lean()
		unset()
		Engine.Evt.NVG:Fire(false)
	end)

	Humanoid.Seated:Connect(function(IsSeated, Seat)
		if IsSeated and Seat and (Seat:IsA("VehicleSeat")) then
			unset()
			Humanoid:UnequipTools()
			CanLean = false
			plr.CameraMaxZoomDistance = gameRules.VehicleMaxZoom
		else
			plr.CameraMaxZoomDistance = Services.StarterPlayer.CameraMaxZoomDistance
		end

		if IsSeated then
			Sentado = true
			Stances = 0
			Virar = 0
			CameraX = 0
			CameraY = 0
			Stand()
			Lean()
		else
			Sentado = false
			CanLean = true
		end
	end)

	Humanoid.Changed:Connect(function(Property)
		if not gameRules.AntiBunnyHop then
			return
		end
		if Property == "Jump" and Humanoid.Sit == true and Humanoid.SeatPart ~= nil then
			Humanoid.Sit = false
		elseif Property == "Jump" and Humanoid.Sit == false then
			if ACSData.JumpDelay then
				Humanoid.Jump = false
				return false
			end
			ACSData.JumpDelay = true
			task.delay(0, function()
				wait(gameRules.JumpCoolDown)
				ACSData.JumpDelay = false
			end)
		end
	end)

	Humanoid.StateChanged:Connect(function(_, state)
		if state == Enum.HumanoidStateType.Swimming then
			Swimming = true
			Stances = 0
			Virar = 0
			CameraX = 0
			CameraY = 0
			Stand()
			Lean()
		else
			Swimming = false
		end

		if gameRules.EnableFallDamage then
			if state == Enum.HumanoidStateType.Freefall and not falling then
				falling = true
				local curVel = 0
				local peak = 0

				while falling do
					curVel = HumanoidRootPart.Velocity.magnitude
					peak = peak + 1
					Mods.Thread:Wait()
				end

				local damage = (curVel - gameRules.MaxVelocity) * gameRules.DamageMult

				if damage > 5 and peak > 20 then
					cameraspring:accelerate(Vector3.new(-damage / 20, 0, math.random(-damage, damage) / 5))
					SwaySpring:accelerate(Vector3.new(math.random(-damage, damage) / 5, damage / 5, 0))

					local hurtSound = Engine.PastaFx.FallDamage:Clone()
					hurtSound.Parent = plr.PlayerGui
					hurtSound.Volume = damage / Humanoid.MaxHealth
					hurtSound:Play()
					Services.Debris:AddItem(hurtSound, hurtSound.TimeLength)

					Engine.Evt.Damage:InvokeServer(nil, nil, nil, nil, nil, nil, true, damage)
				end
			elseif state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Dead then
				falling = false
				SwaySpring:accelerate(Vector3.new(0, 2.5, 0))
			end
		end
	end)

	mouse.WheelBackward:Connect(function() -- fires when the wheel goes forwards
		if
			ACSData.ToolEquip
			and not ACSData.CheckingMag
			and not ACSData.aiming
			and not ACSData.reloading
			and not ACSData.runKeyDown
			and ACSData.AnimDebounce
			and WeaponData.Type == "Gun"
		then
			ACSData.mouse1down = false
			if ACSData.GunStance == 0 then
				ACSData.SafeMode = true
				ACSData.GunStance = -1
				UpdateGui()
				Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
				LowReady()
			elseif ACSData.GunStance == -1 then
				ACSData.SafeMode = true
				ACSData.GunStance = -2
				UpdateGui()
				Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
				Patrol()
			elseif ACSData.GunStance == 1 then
				ACSData.SafeMode = false
				ACSData.GunStance = 0
				UpdateGui()
				Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
				IdleAnim()
			end
		end

		if ACSData.ToolEquip and ACSData.aiming and ACSData.Sens > 5 then
			ACSData.Sens = ACSData.Sens - 5
			UpdateGui()
			game:GetService("UserInputService").MouseDeltaSensitivity = (ACSData.Sens / 100)
		end
	end)

	mouse.WheelForward:Connect(function() -- fires when the wheel goes backwards
		if
			ACSData.ToolEquip
			and not ACSData.CheckingMag
			and not ACSData.aiming
			and not ACSData.reloading
			and not ACSData.runKeyDown
			and ACSData.AnimDebounce
			and WeaponData.Type == "Gun"
		then
			ACSData.mouse1down = false
			if ACSData.GunStance == 0 then
				ACSData.SafeMode = true
				ACSData.GunStance = 1
				UpdateGui()
				Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
				HighReady()
			elseif ACSData.GunStance == -1 then
				ACSData.SafeMode = false
				ACSData.GunStance = 0
				UpdateGui()
				Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
				IdleAnim()
			elseif ACSData.GunStance == -2 then
				ACSData.SafeMode = true
				ACSData.GunStance = -1
				UpdateGui()
				Engine.Evt.GunStance:FireServer(ACSData.GunStance, AnimData)
				LowReady()
			end
		end

		if ACSData.ToolEquip and ACSData.aiming and ACSData.Sens < 100 then
			ACSData.Sens = ACSData.Sens + 5
			UpdateGui()
			game:GetService("UserInputService").MouseDeltaSensitivity = (ACSData.Sens / 100)
		end
	end)

	----------//Health HUD\\----------
	BloodScreen:Play()
	BloodScreenLowHP:Play()

	Humanoid.HealthChanged:Connect(function(Health)
		if Humanoid.Health > 0 then
			SE_GUI.Efeitos.Health.ImageTransparency = ((Health - (Humanoid.MaxHealth / 2)) / (Humanoid.MaxHealth / 2))
			SE_GUI.Efeitos.LowHealth.ImageTransparency = (Health / (Humanoid.MaxHealth / 2))
		else
			SE_GUI.Efeitos.Health.ImageTransparency = 1
			SE_GUI.Efeitos.LowHealth.ImageTransparency = 1
		end
	end)

	Humanoid.Died:Connect(function()
		SE_GUI.Efeitos.Health.ImageTransparency = 1
		SE_GUI.Efeitos.LowHealth.ImageTransparency = 1
	end)
	----------//Health HUD\\----------

	----------//Render Functions\\----------
	local runElapsed = 0

	Services.Run.RenderStepped:Connect(function(dt)
		runElapsed += dt

		if runElapsed > 0.1 then
			runElapsed = 0
			HeadMovement()
		end

		renderGunRecoil()
		renderCam()

		if ViewModel and LArm and RArm and WeaponInHand then --Check if the weapon and arms are loaded
			local mouseDelta = Services.User:GetMouseDelta()
			SwaySpring:accelerate(Vector3.new(mouseDelta.x / 60, mouseDelta.y / 60, 0))

			local swayVec = SwaySpring.p
			local XSSWY = swayVec.X
			local YSSWY = swayVec.Y
			local Sway = CFrame.Angles(YSSWY, XSSWY, XSSWY)

			if ACSData.BipodAtt then
				local rayParams = RaycastParams.new()
				rayParams.FilterType = Enum.RaycastFilterType.Exclude
				rayParams.FilterDescendantsInstances = Ignore_Model
				rayParams.IgnoreWater = true

				local rayResult =
					workspace:Raycast(ACSData.UnderBarrelAtt.Main.Position, Vector3.new(0, -1.75, 0), rayParams)

				local BipodHit, BipodPos

				if rayResult then
					BipodHit, BipodPos = rayResult.Instance, rayResult.Position
				end

				if BipodHit then
					ACSData.CanBipod = true
					if
						ACSData.CanBipod
						and ACSData.BipodActive
						and not ACSData.runKeyDown
						and (ACSData.GunStance == 0 or ACSData.GunStance == 2)
					then
						Services.TS
							:Create(
								SE_GUI.GunHUD.Att.Bipod,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear),
								{ ImageColor3 = Color3.fromRGB(255, 255, 255), ImageTransparency = 0.123 }
							)
							:Play()
						if not ACSData.aiming then
							ACSData.BipodCF = ACSData.BipodCF:Lerp(
								CFrame.new(
									0,
									((ACSData.UnderBarrelAtt.Main.Position - BipodPos).magnitude - 1) * -1.5,
									0
								),
								0.2
							)
						else
							ACSData.BipodCF = ACSData.BipodCF:Lerp(CFrame.new(), 0.2)
						end
					else
						ACSData.BipodActive = false
						ACSData.BipodCF = ACSData.BipodCF:Lerp(CFrame.new(), 0.2)
						Services.TS
							:Create(
								SE_GUI.GunHUD.Att.Bipod,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear),
								{ ImageColor3 = Color3.fromRGB(255, 255, 0), ImageTransparency = 0.5 }
							)
							:Play()
					end
				else
					ACSData.BipodActive = false
					ACSData.CanBipod = false
					ACSData.BipodCF = ACSData.BipodCF:Lerp(CFrame.new(), 0.2)
					Services.TS
						:Create(
							SE_GUI.GunHUD.Att.Bipod,
							TweenInfo.new(0.1, Enum.EasingStyle.Linear),
							{ ImageColor3 = Color3.fromRGB(255, 0, 0), ImageTransparency = 0.5 }
						)
						:Play()
				end
			end

			AnimPart.CFrame = cam.CFrame * ACSData.NearZ * ACSData.BipodCF * maincf * gunbobcf * aimcf

			if not AnimData.GunModelFixed then
				WeaponInHand:SetPrimaryPartCFrame(ViewModel.PrimaryPart.CFrame * guncf)
			end

			if ACSData.running then
				gunbobcf = gunbobcf:Lerp(
					CFrame.new(
						0.025 * (ACSData.charspeed / 10) * math.sin(tick() * 8),
						0.025 * (ACSData.charspeed / 10) * math.cos(tick() * 16),
						0
					)
						* CFrame.Angles(
							math.rad(1 * (ACSData.charspeed / 10) * math.sin(tick() * 16)),
							math.rad(1 * (ACSData.charspeed / 10) * math.cos(tick() * 8)),
							math.rad(0)
						),
					0.1
				)
			else
				gunbobcf =
					gunbobcf:Lerp(CFrame.new(0.005 * math.sin(tick() * 1.5), 0.005 * math.cos(tick() * 2.5), 0), 0.1)
			end

			if ACSData.CurAimpart and ACSData.aiming and ACSData.AnimDebounce and not ACSData.CheckingMag then
				if not plr.Character:GetAttribute("NVG") or WeaponInHand.AimPart:FindFirstChild("NVAim") == nil then
					if ACSData.AimPartMode == 1 then
						Services.TS:Create(cam, AimTween, { FieldOfView = ModTable.ZoomValue }):Play()
						maincf = maincf:Lerp(
							maincf
								* CFrame.new(0, 0, -0.5)
								* recoilcf
								* Sway:inverse()
								* ACSData.CurAimpart.CFrame:toObjectSpace(cam.CFrame),
							0.2
						)
					else
						Services.TS:Create(cam, AimTween, { FieldOfView = ModTable.Zoom2Value }):Play()
						maincf = maincf:Lerp(
							maincf
								* CFrame.new(0, 0, -0.5)
								* recoilcf
								* Sway:inverse()
								* ACSData.CurAimpart.CFrame:toObjectSpace(cam.CFrame),
							0.2
						)
					end
				else
					Services.TS:Create(cam, AimTween, { FieldOfView = 70 }):Play()
					maincf = maincf:Lerp(
						maincf
							* CFrame.new(0, 0, -0.5)
							* recoilcf
							* Sway:Inverse()
							* (WeaponInHand.AimPart.CFrame * WeaponInHand.AimPart.NVAim.CFrame):toObjectSpace(
								cam.CFrame
							),
						0.2
					)
				end
			else
				Services.TS:Create(cam, AimTween, { FieldOfView = 70 }):Play()
				maincf = maincf:Lerp(AnimData.MainCFrame * recoilcf * Sway:inverse(), 0.2)
			end

			for _, Part in pairs(WeaponInHand:GetDescendants()) do
				if Part:IsA("BasePart") and Part.Name == "SightMark" then
					local dist_scale = Part.CFrame:pointToObjectSpace(cam.CFrame.Position) / Part.Size
					local reticle = Part.SurfaceGui.Border.Scope
					reticle.Position = UDim2.new(0.5 + dist_scale.x, 0, 0.5 - dist_scale.y, 0)
				end
			end

			recoilcf = recoilcf:Lerp(
				CFrame.new()
					* CFrame.Angles(math.rad(RecoilSpring.p.X), math.rad(RecoilSpring.p.Y), math.rad(RecoilSpring.p.z)),
				0.2
			)

			if WeaponData.CrossHair then
				if ACSData.aiming then
					CHup = CHup:Lerp(UDim2.new(0.5, 0, 0.5, 0), 0.2)
					CHdown = CHdown:Lerp(UDim2.new(0.5, 0, 0.5, 0), 0.2)
					CHleft = CHleft:Lerp(UDim2.new(0.5, 0, 0.5, 0), 0.2)
					CHright = CHright:Lerp(UDim2.new(0.5, 0, 0.5, 0), 0.2)
				else
					local Normalized = (
						(
							WeaponData.CrosshairOffset
							+ BSpread
							+ (ACSData.charspeed * WeaponData.WalkMult * ModTable.WalkMult)
						) / 50
					) / 10

					CHup = CHup:Lerp(UDim2.new(0.5, 0, 0.5 - Normalized, 0), 0.5)
					CHdown = CHdown:Lerp(UDim2.new(0.5, 0, 0.5 + Normalized, 0), 0.5)
					CHleft = CHleft:Lerp(UDim2.new(0.5 - Normalized, 0, 0.5, 0), 0.5)
					CHright = CHright:Lerp(UDim2.new(0.5 + Normalized, 0, 0.5, 0), 0.5)
				end

				Crosshair.Position = UDim2.new(0, mouse.X, 0, mouse.Y)

				Crosshair.Up.Position = CHup
				Crosshair.Down.Position = CHdown
				Crosshair.Left.Position = CHleft
				Crosshair.Right.Position = CHright
			else
				CHup = CHup:Lerp(UDim2.new(0.5, 0, 0.5, 0), 0.2)
				CHdown = CHdown:Lerp(UDim2.new(0.5, 0, 0.5, 0), 0.2)
				CHleft = CHleft:Lerp(UDim2.new(0.5, 0, 0.5, 0), 0.2)
				CHright = CHright:Lerp(UDim2.new(0.5, 0, 0.5, 0), 0.2)

				Crosshair.Position = UDim2.new(0, mouse.X, 0, mouse.Y)

				Crosshair.Up.Position = CHup
				Crosshair.Down.Position = CHdown
				Crosshair.Left.Position = CHleft
				Crosshair.Right.Position = CHright
			end

			if BSpread then
				local currTime = time()
				if
					currTime - LastSpreadUpdate > (60 / WeaponData.ShootRate) * 2
					and not ACSData.shooting
					and BSpread > WeaponData.MinSpread * ModTable.MinSpread
				then
					BSpread = math.max(
						WeaponData.MinSpread * ModTable.MinSpread,
						BSpread - WeaponData.AimInaccuracyDecrease * ModTable.AimInaccuracyDecrease
					)
				end
				if
					currTime - LastSpreadUpdate > (60 / WeaponData.ShootRate) * 1.5
					and not ACSData.shooting
					and RecoilPower > WeaponData.MinRecoilPower * ModTable.MinRecoilPower
				then
					RecoilPower = math.max(
						WeaponData.MinRecoilPower * ModTable.MinRecoilPower,
						RecoilPower - WeaponData.RecoilPowerStepAmount * ModTable.RecoilPowerStepAmount
					)
				end
			end

			if ACSData.LaserActive and ACSData.Pointer ~= nil then
				if plr.Character:GetAttribute("NVG") then
					ACSData.Pointer.Transparency = 0
					ACSData.Pointer.Beam.Enabled = true
				else
					if not gameRules.RealisticLaser then
						ACSData.Pointer.Beam.Enabled = true
					else
						ACSData.Pointer.Beam.Enabled = false
					end
					if ACSData.IRmode then
						ACSData.Pointer.Transparency = 1
					else
						ACSData.Pointer.Transparency = 0
					end
				end

				for _, Key in pairs(WeaponInHand:GetDescendants()) do
					if Key:IsA("BasePart") and Key.Name == "LaserPoint" then
						local rayParams = RaycastParams.new()
						rayParams.FilterType = Enum.RaycastFilterType.Exclude
						rayParams.FilterDescendantsInstances = Ignore_Model
						rayParams.IgnoreWater = true

						local rayResult = workspace:Raycast(Key.Position, Key.CFrame.LookVector * 1000, rayParams)

						if not rayResult then
							break
						end

						local Hit, Pos, Normal = rayResult.Instance, rayResult.Position, rayResult.Normal

						if Hit then
							ACSData.Pointer.CFrame = CFrame.new(Pos, Pos + Normal)
						else
							ACSData.Pointer.CFrame =
								CFrame.new(cam.CFrame.Position + Key.CFrame.LookVector * 2000, Key.CFrame.LookVector)
						end

						if HalfStep and gameRules.ReplicatedLaser then
							Engine.Evt.SVLaser:FireServer(Pos, 1, ACSData.Pointer.Color, ACSData.IRmode, WeaponTool)
						end
						break
					end
				end
			end
		end
	end)
end

return module
