local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.4)
self.SlideLock 		= true

self.canAim 		= true
self.Zoom 			= 55
self.Zoom2 			= 45

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
self.ShootRate 		= 650
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 1 		--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = true;		
	Semi = true;
	Burst = false;
	Auto = true;}

self.LimbDamage 	= {10,15}
self.TorsoDamage 	= {90,100}
self.HeadDamage 	= {1000,1000} 
self.DamageFallOf 	= 1
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 99

self.adsTime 		= 1

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= ""
self.BarrelAtt		= "USP Suppressor"
self.UnderBarrelAtt = "Viridian Laser"
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {1,5}
	,camRecoilTilt 	= {1,5}
	,camRecoilLeft 	= {1,5}
	,camRecoilRight = {1,5}
}

self.gunRecoil = {
	gunRecoilUp 	= {1,5}
	,gunRecoilTilt 	= {1,5}
	,gunRecoilLeft 	= {1,5}
	,gunRecoilRight = {1,5}
}

self.AimRecoilReduction 		= 4
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= .5
self.MaxRecoilPower 			= 1.5
self.RecoilPowerStepAmount 		= .1

self.MinSpread 					= 0
self.MaxSpread 					= 1					
self.AimInaccuracyStepAmount 	= 0
self.AimInaccuracyDecrease 		= 1
self.WalkMult 					= 0

self.EnableZeroing 				= true
self.MaxZero 					= 500
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= "9mm x 19"
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