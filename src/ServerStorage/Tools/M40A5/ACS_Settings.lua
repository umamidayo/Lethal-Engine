local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.2)
self.SlideLock 		= false

self.canAim 		= true
self.Zoom 			= 15
self.Zoom2 			= 5

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = false
self.Ammo 			= 10
self.StoredAmmo 	= 70
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 70
self.CanCheckMag 	= false
self.MagCount		= true
self.ShellInsert	= false
self.ShootRate 		= 800
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 5				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = false;
	Burst = false;
	Auto = false;}

self.LimbDamage 	= {150,150}
self.TorsoDamage 	= {350,350}
self.HeadDamage 	= {750,750} 
self.DamageFallOf 	= .5
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 90

self.adsTime 		= 0.8

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= "M40A5 Scope"
self.BarrelAtt		= ""
self.UnderBarrelAtt = "M40A5 Bipod"
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {25,35}
	,camRecoilTilt 	= {20,40}
	,camRecoilLeft 	= {25,35}
	,camRecoilRight = {25,35}
}

self.gunRecoil = {
	gunRecoilUp 	= {25,35}
	,gunRecoilTilt 	= {20,40}
	,gunRecoilLeft 	= {25,35}
	,gunRecoilRight = {25,35}
}

self.AimRecoilReduction 		= 1
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= 1
self.MaxRecoilPower 			= 1
self.RecoilPowerStepAmount 		= 1

self.MinSpread 					= 0
self.MaxSpread 					= 0.1					
self.AimInaccuracyStepAmount 	= 0
self.AimInaccuracyDecrease 		= 0
self.WalkMult 					= 0

self.EnableZeroing 				= true
self.MaxZero 					= 2000
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= ".308"
self.MuzzleVelocity 			= 1000 --m/s
self.BulletDrop 				= 0.1 --Between 0 - 1
self.Tracer						= true
self.BulletFlare 				= true
self.TracerColor				= Color3.fromRGB(255, 171, 171)
self.RandomTracer				= {
	Enabled = true
	,Chance = 100 -- 0-100%
}
self.TracerEveryXShots			= 0
self.RainbowMode 				= false
self.InfraRed 					= false

self.CanBreak	= false
self.Jammed		= false

return self