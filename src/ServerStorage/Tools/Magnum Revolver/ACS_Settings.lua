local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.Angles(math.rad(-20), 0, 0)
self.SlideLock 		= true

self.canAim 		= true
self.Zoom 			= 70
self.Zoom2 			= 55

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = false
self.Ammo 			= 6
self.StoredAmmo 	= 42
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 42
self.CanCheckMag 	= true
self.MagCount		= false
self.ShellInsert	= false
self.ShootRate 		= 100
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 4				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = false;
	Burst = false;
	Auto = false;}

self.LimbDamage 	= {120,130}
self.TorsoDamage 	= {250,260}
self.HeadDamage 	= {610,620}
self.DamageFallOf 	= 0
self.MinDamage 		= 30
self.IgnoreProtection = false
self.BulletPenetration = 95

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 10
self.CanBreachDoor 	= false

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {100,120}
	,camRecoilTilt 	= {25,50}
	,camRecoilLeft 	= {50,55}
	,camRecoilRight = {50,55}
}

self.gunRecoil = {
	gunRecoilUp 	= {150,150}
	,gunRecoilTilt 	= {25,50}
	,gunRecoilLeft 	= {20,25}
	,gunRecoilRight = {20,25}
}

self.AimRecoilReduction 		= 1
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= 1
self.MaxRecoilPower 			= 1.5
self.RecoilPowerStepAmount 		= .1

self.MinSpread 					= 0.5
self.MaxSpread 					= 10					
self.AimInaccuracyStepAmount 	= 1
self.AimInaccuracyDecrease 		= 1
self.WalkMult 					= 0

self.EnableZeroing 				= true
self.MaxZero 					= 800
self.ZeroIncrement 				= 50
self.CurrentZero 				= 600

self.BulletType 				= ".44 Magnum"
self.MuzzleVelocity 			= 1000 --m/s
self.BulletDrop 				= 0.1 --Between 0 - 1
self.Tracer						= true
self.BulletFlare 				= true
self.TracerColor				= Color3.fromRGB(255, 171, 171)
self.RandomTracer				= {
	Enabled = true
	,Chance = 100-- 0-100%
}
self.TracerEveryXShots			= 0
self.RainbowMode 				= false
self.InfraRed 					= false

self.CanBreak	= false
self.Jammed		= false

return self