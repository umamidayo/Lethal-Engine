local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.3)
self.SlideLock 		= true

self.canAim 		= true
self.Zoom 			= 60
self.Zoom2 			= 50

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = true
self.Ammo 			= 9
self.StoredAmmo 	= 180
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 180
self.CanCheckMag 	= true
self.MagCount		= true
self.ShellInsert	= false
self.ShootRate 		= 700
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 1				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = false;
	Burst = false;
	Auto = false;}

self.LimbDamage 	= {10,15}
self.TorsoDamage 	= {20,30}
self.HeadDamage 	= {110,120} 
self.DamageFallOf 	= 0.7
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 95

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {5,10}
	,camRecoilTilt 	= {5,10}
	,camRecoilLeft 	= {5,10}
	,camRecoilRight = {5,10}
}

self.gunRecoil = {
	gunRecoilUp 	= {20,40}
	,gunRecoilTilt 	= {10,20}
	,gunRecoilLeft 	= {10,20}
	,gunRecoilRight = {10,20}
}

self.AimRecoilReduction 		= 1
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= 1
self.MaxRecoilPower 			= 1.5
self.RecoilPowerStepAmount 		= .1

self.MinSpread 					= 0
self.MaxSpread 					= 0.1					
self.AimInaccuracyStepAmount 	= 0
self.AimInaccuracyDecrease 		= 0
self.WalkMult 					= 0

self.EnableZeroing 				= false
self.MaxZero 					= 500
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= ".45 ACP"
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