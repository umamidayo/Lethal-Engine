local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0.03,-0.85)
self.SlideLock 		= false

self.canAim 		= true
self.Zoom 			= 40
self.Zoom2 			= 30

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = true
self.Ammo 			= 20
self.StoredAmmo 	= 140
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 140
self.CanCheckMag 	= true
self.MagCount		= true
self.ShellInsert	= false
self.ShootRate 		= 450
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 3				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = true;		
	Semi = true;
	Burst = false;
	Auto = true;}

self.LimbDamage 	= {20,25}
self.TorsoDamage 	= {60,70}
self.HeadDamage 	= {120,160} 
self.DamageFallOf 	= 0.85
self.MinDamage 		= 35
self.IgnoreProtection = false
self.BulletPenetration = 75

self.adsTime 		= 2

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {19,23}
	,camRecoilTilt 	= {11,21}
	,camRecoilLeft 	= {13,16}
	,camRecoilRight = {13,16}
}

self.gunRecoil = {
	gunRecoilUp 	= {20,25}
	,gunRecoilTilt 	= {13,23}
	,gunRecoilLeft 	= {13,16}
	,gunRecoilRight = {13,16}
}

self.AimRecoilReduction 		= 3
self.AimSpreadReduction 		= 2

self.MinRecoilPower 			= .7
self.MaxRecoilPower 			= 1.3
self.RecoilPowerStepAmount 		= .1

self.MinSpread 					= 0
self.MaxSpread 					= 0.1					
self.AimInaccuracyStepAmount 	= 0
self.AimInaccuracyDecrease 		= 0
self.WalkMult 					= 0

self.EnableZeroing 				= true
self.MaxZero 					= 400
self.ZeroIncrement 				= 100
self.CurrentZero 				= 100

self.BulletType 				= "7.62x51mm"
self.MuzzleVelocity 			= 1000 --m/s
self.BulletDrop 				= 0.1 --Between 0 - 1
self.Tracer						= true
self.BulletFlare 				= true
self.TracerColor				= Color3.fromRGB(255, 171, 171)
self.RandomTracer				= {
	Enabled = true
	,Chance = 20 -- 0-100%
}
self.TracerEveryXShots			= 0
self.RainbowMode 				= false
self.InfraRed 					= false

self.CanBreak	= false
self.Jammed		= false

-- RCM Settings V

self.WeaponWeight		= 3 -- Weapon weight must be enabled in the Config module

self.ShellEjectionMod	= true

self.Holster			= true
self.HolsterPoint		= "Torso"
self.HolsterCFrame		= CFrame.new(1.2,-0.3,0.65) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(90))

self.FlashChance = 5 -- 0 = no muzzle flash, 10 = Always muzzle flash

self.ADSEnabled 		= { -- Ignore this setting if not using an ADS Mesh
	true, -- Enabled for primary sight
	false} -- Enabled for secondary sight (T)

self.ExplosiveAmmo		= false -- Enables explosive ammo
self.ExplosionRadius	= 70 -- Radius of explosion damage in studs
self.ExplosionType		= "Default" -- Which explosion effect is used from the HITFX Explosion folder
self.IsLauncher			= true -- For RPG style rocket launchers

self.EjectionOverride	= nil -- Don't touch unless you know what you're doing with Vector3s

return self