local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.3)
self.SlideLock 		= false

self.canAim 		= true
self.Zoom 			= 60
self.Zoom2 			= 50

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = true
self.Ammo 			= 900
self.StoredAmmo 	= 0
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 900
self.CanCheckMag 	= true
self.MagCount		= true
self.ShellInsert	= false
self.ShootRate 		= 1100
self.Bullets 		= 1
self.BurstShot 		= 2
self.ShootType 		= 3				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = false;
	Burst = false;
	Auto = true;}

self.LimbDamage 	= {70,80}
self.TorsoDamage 	= {120,130} 
self.HeadDamage 	= {250,260}
self.DamageFallOf 	= 1
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 90

self.adsTime 		= 0.8

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= ""
self.BarrelAtt		= "PEQ-15"
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {5,10}
	,camRecoilTilt 	= {5,10}
	,camRecoilLeft 	= {1,5}
	,camRecoilRight = {1,5}
}

self.gunRecoil = {
	gunRecoilUp 	= {5,10}
	,gunRecoilTilt 	= {5,10}
	,gunRecoilLeft 	= {1,5}
	,gunRecoilRight = {1,5}
}

self.AimRecoilReduction 		= 6
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= .5
self.MaxRecoilPower 			= 1.2
self.RecoilPowerStepAmount 		= .05

self.MinSpread 					= 0
self.MaxSpread 					= 8					
self.AimInaccuracyStepAmount 	= .95
self.AimInaccuracyDecrease 		= .25
self.WalkMult 					= 0

self.EnableZeroing 				= true
self.MaxZero 					= 500
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= "7.62x51mm NATO"
self.MuzzleVelocity 			= 1000 -- 600 m/s
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