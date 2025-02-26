local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.3)
self.SlideLock 		= false

self.canAim 		= true
self.Zoom 			= 55
self.Zoom2 			= 45

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = true
self.Ammo 			= 30
self.StoredAmmo 	= 210
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 210
self.CanCheckMag 	= true
self.MagCount		= true
self.ShellInsert	= false
self.ShootRate 		= 800
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 3				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = true;		
	Semi = true;
	Burst = false;
	Auto = true;}

self.LimbDamage 	= {15,20}
self.TorsoDamage 	= {40,48}
self.HeadDamage 	= {75,85} 
self.DamageFallOf 	= 2
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 65

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= ""
self.BarrelAtt		= "Suppressor"
self.UnderBarrelAtt = "FlashlightNoVis"
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {10,14}
	,camRecoilTilt 	= {7,12}
	,camRecoilLeft 	= {5,9}
	,camRecoilRight = {5,9}
}

self.gunRecoil = {
	gunRecoilUp 	= {15,20}
	,gunRecoilTilt 	= {10,15}
	,gunRecoilLeft 	= {10,15}
	,gunRecoilRight = {10,15}
}

self.AimRecoilReduction 		= 4
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= .25
self.MaxRecoilPower 			= 1.5
self.RecoilPowerStepAmount 		= .05

self.MinSpread 					= 0
self.MaxSpread 					= 1					
self.AimInaccuracyStepAmount 	= 1
self.AimInaccuracyDecrease 		= .25
self.WalkMult 					= 0

self.EnableZeroing 				= true
self.MaxZero 					= 200
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= "9x19mm"
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