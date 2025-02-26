local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.3)
self.SlideLock 		= true

self.canAim 		= true
self.Zoom 			= 50
self.Zoom2 			= 40

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
self.ShootRate 		= 400
self.Bullets 		= 6
self.BurstShot 		= 3
self.ShootType 		= 4				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = false;
	Burst = false;
	Auto = false;}

self.LimbDamage 	= {40,50}
self.TorsoDamage 	= {140,150} 
self.HeadDamage 	= {290,300} 
self.DamageFallOf 	= 1
self.MinDamage 		= 15
self.IgnoreProtection = false
self.BulletPenetration = 90

self.CrossHair 		= false
self.CenterDot 		= true
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {20,30}
	,camRecoilTilt 	= {10,20}
	,camRecoilLeft 	= {10,15}
	,camRecoilRight = {10,15}
}

self.gunRecoil = {
	gunRecoilUp 	= {100,105}
	,gunRecoilTilt 	= {25,40}
	,gunRecoilLeft 	= {10,15}
	,gunRecoilRight = {10,15}
}

self.AimRecoilReduction 		= 1
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= 1
self.MaxRecoilPower 			= 1.5
self.RecoilPowerStepAmount 		= .1

self.MinSpread 					= 40
self.MaxSpread 					= 50					
self.AimInaccuracyStepAmount 	= 0
self.AimInaccuracyDecrease 		= 1
self.WalkMult 					= 0

self.EnableZeroing 				= false
self.MaxZero 					= 500
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= "Radiation"
self.MuzzleVelocity 			= 1000 --m/s
self.BulletDrop 				= 0.1 --Between 0 - 1
self.Tracer						= true
self.BulletFlare 				= true
self.TracerColor				= Color3.fromRGB(130, 216, 106)
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