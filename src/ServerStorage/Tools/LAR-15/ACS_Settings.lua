local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.3)
self.SlideLock 		= false

self.canAim 		= true
self.Zoom 			= 50
self.Zoom2 			= 30

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = true
self.Ammo 			= 30
self.StoredAmmo 	= 210 --210
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 210 --210
self.CanCheckMag 	= true
self.MagCount		= true
self.ShellInsert	= false
self.ShootRate 		= 735
self.Bullets 		= 1
self.BurstShot 		= 2
self.ShootType 		= 3				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = true;		
	Semi = true;
	Burst = false;
	Auto = true;}

self.LimbDamage 	= {70,85}
self.TorsoDamage 	= {100,135} 
self.HeadDamage 	= {170,180} 
self.DamageFallOf 	= 0.7
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 75

self.adsTime 		= 0.8

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= "LAR-15 T1"
self.BarrelAtt		= "Suppressor"
self.UnderBarrelAtt = ""
self.OtherAtt 		= "Surefire"

self.camRecoil = {
	camRecoilUp 	= {10,12}
	,camRecoilTilt 	= {7,12}
	,camRecoilLeft 	= {8,12}
	,camRecoilRight = {7,11}
}

self.gunRecoil = {
	gunRecoilUp 	= {10,15}
	,gunRecoilTilt 	= {10,20}
	,gunRecoilLeft 	= {18,25}
	,gunRecoilRight = {18,25}
}

self.AimRecoilReduction 		= 6
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= .5
self.MaxRecoilPower 			= 1.2
self.RecoilPowerStepAmount 		= .05

self.MinSpread 					= 0
self.MaxSpread 					= 1					
self.AimInaccuracyStepAmount 	= 0
self.AimInaccuracyDecrease 		= 0
self.WalkMult 					= 0

self.EnableZeroing 				= true
self.MaxZero 					= 500
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= "5.56×45mm"
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
self.InfraRed 					= true

self.CanBreak	= false
self.Jammed		= false

return self