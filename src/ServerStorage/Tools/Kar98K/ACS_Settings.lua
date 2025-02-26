local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.2)
self.SlideLock 		= false

self.canAim 		= true
self.Zoom 			= 40
self.Zoom2 			= 30

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = false
self.Ammo 			= 5
self.StoredAmmo 	= 35
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 35
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

self.LimbDamage 	= {35,45}
self.TorsoDamage 	= {80,90} 
self.HeadDamage 	= {320,340} 
self.DamageFallOf 	= .5
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 75

self.adsTime 		= 0.8

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {35,45}
	,camRecoilTilt 	= {100,100}
	,camRecoilLeft 	= {40,50}
	,camRecoilRight = {40,50}
}

self.gunRecoil = {
	gunRecoilUp 	= {150,175}
	,gunRecoilTilt 	= {25,50}
	,gunRecoilLeft 	= {75,150}
	,gunRecoilRight = {75,150}
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

self.BulletType 				= "7.92x57mm"
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

return self