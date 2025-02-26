local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.4)
self.SlideLock 		= false

self.canAim 		= true
self.Zoom 			= 50
self.Zoom2 			= 30

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = true
self.Ammo 			= 100
self.StoredAmmo 	= 700 --500
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 700 --500
self.CanCheckMag 	= true
self.MagCount		= true
self.ShellInsert	= false
self.ShootRate 		= 780
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 3				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = false;
	Burst = false;
	Auto = true;}

self.LimbDamage 	= {70,80}
self.TorsoDamage 	= {110,120}
self.HeadDamage 	= {180,190} 
self.DamageFallOf 	= 0.7
self.MinDamage 		= 20
self.IgnoreProtection = false
self.BulletPenetration = 75

self.adsTime 		= 2

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = "M240 Bipod"
self.OtherAtt 		= "AN PEQ"

self.camRecoil = {
	camRecoilUp 	= {15,20}
	,camRecoilTilt 	= {10,15}
	,camRecoilLeft 	= {7,11}
	,camRecoilRight = {7,11}
}

self.gunRecoil = {
	gunRecoilUp 	= {15,20}
	,gunRecoilTilt 	= {10,15}
	,gunRecoilLeft 	= {7,11}
	,gunRecoilRight = {7,11}
}

self.AimRecoilReduction 		= 3
self.AimSpreadReduction 		= 1.5

self.MinRecoilPower 			= .5
self.MaxRecoilPower 			= 2.5
self.RecoilPowerStepAmount 		= .1

self.MinSpread 					= 0
self.MaxSpread 					= 0.1					
self.AimInaccuracyStepAmount 	= 0
self.AimInaccuracyDecrease 		= 0
self.WalkMult 					= 0

self.EnableZeroing 				= true
self.MaxZero 					= 1500
self.ZeroIncrement 				= 100
self.CurrentZero 				= 100

self.BulletType 				= "7.62x51mm"
self.MuzzleVelocity 			= 1000 --m/s
self.BulletDrop 				= 0.1 --Between 0 - 1
self.Tracer						= true
self.BulletFlare 				= true
self.TracerColor				= Color3.fromRGB(255, 171, 171)
self.RandomTracer				= {
	Enabled = false
	,Chance = 25 -- 0-100%
}
self.TracerEveryXShots			= 0
self.RainbowMode 				= false
self.InfraRed 					= false

self.CanBreak	= false
self.Jammed		= false

-- RCM Settings V

self.WeaponWeight		= 5 -- Weapon weight must be enabled in the Config module

self.ShellEjectionMod	= true

self.Holster			= true
self.HolsterPoint		= "Torso"
self.HolsterCFrame		= CFrame.new(1.15,-1.25,1.25) * CFrame.Angles(math.rad(-10),math.rad(0),math.rad(0))

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