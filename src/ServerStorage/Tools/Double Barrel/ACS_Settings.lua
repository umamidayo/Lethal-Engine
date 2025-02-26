local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.3)
self.SlideLock 		= true

self.canAim 		= true
self.Zoom 			= 70
self.Zoom2 			= 70

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = false
self.Ammo 			= 2
self.StoredAmmo 	= 20
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 20
self.CanCheckMag 	= true
self.MagCount		= false
self.ShellInsert	= false
self.ShootRate 		= 600
self.Bullets 		= 8
self.BurstShot 		= 2
self.ShootType 		= 1				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = true;
	Burst = true;
	Auto = false;}

self.LimbDamage 	= {50,60}
self.TorsoDamage 	= {90,100}
self.HeadDamage 	= {170,180} 
self.DamageFallOf 	= 1
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 65

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= true

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {120,160}
	,camRecoilTilt 	= {90,100}
	,camRecoilLeft 	= {40,45}
	,camRecoilRight = {40,45}
}

self.gunRecoil = {
	gunRecoilUp 	= {150,200}
	,gunRecoilTilt 	= {50,75}
	,gunRecoilLeft 	= {100,175}
	,gunRecoilRight = {100,175}
}

self.AimRecoilReduction 		= 1
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= 1.5
self.MaxRecoilPower 			= 2
self.RecoilPowerStepAmount 		= .1

self.MinSpread 					= 15
self.MaxSpread 					= 35		
self.AimInaccuracyStepAmount 	= 5.75
self.AimInaccuracyDecrease 		= 1
self.WalkMult 					= 0

self.EnableZeroing 				= false
self.MaxZero 					= 500
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= "12 Gauge"
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

return self