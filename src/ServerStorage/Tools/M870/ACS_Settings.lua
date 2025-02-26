local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.2)
self.SlideLock 		= false

self.canAim 		= true
self.Zoom 			= 50
self.Zoom2 			= 40

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = true
self.Ammo 			= 7
self.StoredAmmo 	= 49
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 49
self.CanCheckMag 	= false
self.MagCount		= false
self.ShellInsert	= true
self.ShootRate 		= 300
self.Bullets 		= 12
self.BurstShot 		= 3
self.ShootType 		= 4				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = false;
	Burst = false;
	Auto = false;}

self.LimbDamage 	= {20,30}
self.TorsoDamage 	= {40,50} 
self.HeadDamage 	= {80,90} 
self.DamageFallOf 	= 2
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 30

self.adsTime 		= 1

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= true

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {80,90}
	,camRecoilTilt 	= {50,60}
	,camRecoilLeft 	= {40,50}
	,camRecoilRight = {40,50}
}

self.gunRecoil = {
	gunRecoilUp 	= {190,200}
	,gunRecoilTilt 	= {190,200}
	,gunRecoilLeft 	= {190,200}
	,gunRecoilRight = {190,200}
}

self.AimRecoilReduction 		= 1
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= 1
self.MaxRecoilPower 			= 1
self.RecoilPowerStepAmount 		= 1

self.MinSpread 					= 63
self.MaxSpread 					= 120					
self.AimInaccuracyStepAmount 	= 1
self.AimInaccuracyDecrease 		= 1.5
self.WalkMult 					= 0

self.EnableZeroing 				= false
self.MaxZero 					= 500
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= "20 Gauge"
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