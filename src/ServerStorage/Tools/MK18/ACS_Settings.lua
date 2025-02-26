local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.4)
self.SlideLock 		= true

self.canAim 		= true
self.Zoom 			= 50
self.Zoom2 			= 35

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
self.ShootRate 		= 750
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 3				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = true;		
	Semi = true;
	Burst = false;
	Auto = true;}

self.LimbDamage 	= {60,75}
self.TorsoDamage 	= {150,175} 
self.HeadDamage 	= {200,240} 
self.DamageFallOf 	= .5
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 75

self.adsTime 		= 1

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= "XRK Operator"
self.BarrelAtt		= "Suppressor"
self.UnderBarrelAtt = "Magpul Stubby"
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {5,10}
	,camRecoilTilt 	= {5,10}
	,camRecoilLeft 	= {5,10}
	,camRecoilRight = {5,10}
}

self.gunRecoil = {
	gunRecoilUp 	= {5,10}
	,gunRecoilTilt 	= {5,10}
	,gunRecoilLeft 	= {5,10}
	,gunRecoilRight = {5,10}
}

self.AimRecoilReduction 		= 4
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= .5
self.MaxRecoilPower 			= 1.5
self.RecoilPowerStepAmount 		= .1

self.MinSpread 					= 0
self.MaxSpread 					= 30					
self.AimInaccuracyStepAmount 	= 0
self.AimInaccuracyDecrease 		= 1
self.WalkMult 					= 0

self.EnableZeroing 				= true
self.MaxZero 					= 500
self.ZeroIncrement 				= 50
self.CurrentZero 				= 400

self.BulletType 				= "5.56x45mm"
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