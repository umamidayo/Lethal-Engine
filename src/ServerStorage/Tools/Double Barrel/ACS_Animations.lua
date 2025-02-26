local TS = game:GetService('TweenService')
local self = {}

self.MainCFrame 	= CFrame.new(0.5,-.85,-0.75)

self.GunModelFixed 	= true
self.GunCFrame 		= CFrame.new(0.15, -.2, 1) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))
self.LArmCFrame 	= CFrame.new(-.6,-0.4,-0.8) * CFrame.Angles(math.rad(110),math.rad(15),math.rad(15))
self.RArmCFrame 	= CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))

self.EquipAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(-1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.25)
	TS:Create(objs[1], TweenInfo.new(.35,Enum.EasingStyle.Sine), {C1 = self.RArmCFrame:Inverse()}):Play()
	TS:Create(objs[2], TweenInfo.new(.35,Enum.EasingStyle.Sine), {C1 = self.LArmCFrame:Inverse()}):Play()
	wait(.35)
end;

self.IdleAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = self.RArmCFrame:Inverse()}):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = self.LArmCFrame:Inverse()}):Play()
end;

self.LowReady = function(objs)
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0.05,-0.15,1) * CFrame.Angles(math.rad(65), math.rad(0), math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-.6,-0.75,-.25) * CFrame.Angles(math.rad(85),math.rad(15),math.rad(15))):inverse() }):Play()
	wait(0.25)	
end;

self.HighReady = function(objs)
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0.35,-0.75,1) * CFrame.Angles(math.rad(135), math.rad(0), math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-.2,-0.15,0.25) * CFrame.Angles(math.rad(155),math.rad(35),math.rad(15))):inverse() }):Play()
	wait(0.25)	
end;

self.Patrol = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(.75,-0.15,0) * CFrame.Angles(math.rad(90),math.rad(20),math.rad(-75))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.15,-0.75,0.4) * CFrame.Angles(math.rad(90),math.rad(20),math.rad(25))):inverse() }):Play()	
	wait(.25)	
end;

self.SprintAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(.75,-0.15,0) * CFrame.Angles(math.rad(90),math.rad(20),math.rad(-75))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.15,-0.75,0.4) * CFrame.Angles(math.rad(90),math.rad(20),math.rad(25))):inverse() }):Play()	
	wait(.25)
end;

self.ReloadAnim = function(objs)
	objs[4].Handle.AimUp:Play()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(105),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.6,0.4,-0.8) * CFrame.Angles(math.rad(110),math.rad(15),math.rad(15))):inverse() }):Play()
	wait(.3)

	TS:Create(objs[1], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(85),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.6,-0.4,-0.8) * CFrame.Angles(math.rad(60),math.rad(-5),math.rad(15))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(-45),math.rad(0),math.rad(0))):inverse() }):Play()
	objs[4].Handle.LidDown:Play()
	objs[4].Lid.Shell1.Transparency = 1

	wait(.05)
	objs[4].Handle.MagOut:Play()
	objs[4].Handle.Chamber.Shells:Emit(1)
	objs[4].Handle.Chamber.Smoke:Emit(3)
	wait(.35)
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.6,0.15,0.65) * CFrame.Angles(math.rad(135),math.rad(-45),math.rad(30))):inverse() }):Play()
	wait(.3)
	objs[4].Handle.MagIn:Play()
	objs[4].Handle.ShellCasing:Play()
	objs[4].Handle.AimUp:Play()
	objs[4].Lid.Shell1.Transparency = 0
	objs[4].Lid.Shell2.Transparency = 0
	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(80),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.6,0.1,0.30) * CFrame.Angles(math.rad(135),math.rad(-45),math.rad(30))):inverse() }):Play()
	objs[4].Handle.AimUp:Play()
	wait(.25)
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.6,-0.4,-0.8) * CFrame.Angles(math.rad(60),math.rad(-5),math.rad(15))):inverse() }):Play()
	wait(.25)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(105),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.6,-0.4,-0.8) * CFrame.Angles(math.rad(135),math.rad(15),math.rad(15))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	objs[4].Handle.LidDown.TimePosition = 1.63
	wait(0.35)
	objs[4].Handle.LidDown:Stop()
end;

self.TacticalReloadAnim = function(objs)
	objs[4].Handle.AimUp:Play()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(105),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.6,0.4,-0.8) * CFrame.Angles(math.rad(110),math.rad(15),math.rad(15))):inverse() }):Play()
	wait(.3)

	TS:Create(objs[1], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(85),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.6,-0.4,-0.8) * CFrame.Angles(math.rad(60),math.rad(-5),math.rad(15))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(-45),math.rad(0),math.rad(0))):inverse() }):Play()
	objs[4].Handle.LidDown:Play()

	wait(.05)
	objs[4].Handle.MagOut:Play()
	objs[4].Lid.Shell1.Transparency = 1
	objs[4].Lid.Shell2.Transparency = 1
	objs[4].Handle.Chamber.Shells:Emit(2)
	wait(.35)
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.6,0.15,0.65) * CFrame.Angles(math.rad(135),math.rad(-45),math.rad(30))):inverse() }):Play()
	wait(.3)
	objs[4].Handle.MagIn:Play()
	objs[4].Handle.ShellCasing:Play()
	objs[4].Handle.AimUp:Play()
	objs[4].Lid.Shell1.Transparency = 0
	objs[4].Lid.Shell2.Transparency = 0
	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(80),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.6,0.1,0.30) * CFrame.Angles(math.rad(135),math.rad(-45),math.rad(30))):inverse() }):Play()
	objs[4].Handle.AimUp:Play()
	wait(.25)
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.6,-0.4,-0.8) * CFrame.Angles(math.rad(60),math.rad(-5),math.rad(15))):inverse() }):Play()
	wait(.25)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(105),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.6,-0.4,-0.8) * CFrame.Angles(math.rad(135),math.rad(15),math.rad(15))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	objs[4].Handle.LidDown.TimePosition = 1.63
	wait(0.35)
	objs[4].Handle.LidDown:Stop()
end;

self.JammedAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = self.RArmCFrame:Inverse()}):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.8,0.1,0) * CFrame.Angles(math.rad(115),math.rad(-25),math.rad(30))):inverse() }):Play()
	wait(.25)
	objs[4].Bolt.SlidePull:Play()
	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.4):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.8,0.1,0.4) * CFrame.Angles(math.rad(115),math.rad(-25),math.rad(30))):inverse() }):Play()
	wait(.35)
	objs[4].Bolt.SlideRelease:Play()
	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.05,Enum.EasingStyle.Linear), {C0 =  CFrame.new():inverse() }):Play()
end;

self.PumpAnim = function(objs)
	
end;

self.MagCheck = function(objs)
	objs[4].Handle.AimUp:Play()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(105),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.6,0.4,-0.8) * CFrame.Angles(math.rad(110),math.rad(15),math.rad(15))):inverse() }):Play()
	wait(.3)

	TS:Create(objs[1], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(85),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.6,-0.4,-0.8) * CFrame.Angles(math.rad(60),math.rad(-5),math.rad(15))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(-45),math.rad(0),math.rad(0))):inverse() }):Play()
	objs[4].Handle.LidDown:Play()
	wait(0.35)
	objs[4].Handle.LidDown:Pause()
	wait(1.25)
	objs[4].Handle.LidDown:Resume()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(105),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.6,-0.4,-0.8) * CFrame.Angles(math.rad(135),math.rad(15),math.rad(15))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	objs[4].Handle.LidDown.TimePosition = 1.63
	wait(0.35)
	objs[4].Handle.LidDown:Stop()
end;

self.meleeAttack = function(objs)
	
end;

self.GrenadeReady = function(objs)
	
end;

self.GrenadeThrow = function(objs)
	
end;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--//Server Animations
------//Idle Position
self.SV_GunPos 		= CFrame.new(-.3, -1, -0.4) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))

self.SV_RightArmPos = CFrame.new(-0.575, 0.65, -1.185) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))
self.SV_LeftArmPos 	= CFrame.new(1.15,-0.1,-1.65) * CFrame.Angles(math.rad(-120),math.rad(20),math.rad(-25))

------//High Ready Animations
self.RightHighReady = CFrame.new(-1, -.5, -1.25) * CFrame.Angles(math.rad(-160), math.rad(0), math.rad(0));
self.LeftHighReady 	= CFrame.new(.85,-0.35,-1.15) * CFrame.Angles(math.rad(-170),math.rad(60),math.rad(15));

------//Low Ready Animations
self.RightLowReady 	= CFrame.new(-1, 0.85, -1.15) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0));
self.LeftLowReady 	= CFrame.new(.95,.75,-1.35) * CFrame.Angles(math.rad(-60),math.rad(35),math.rad(-25));

------//Patrol Animations
self.RightPatrol 	= CFrame.new(-1, 1.5, -0.45) * CFrame.Angles(math.rad(-30), math.rad(0), math.rad(0));
self.LeftPatrol 	= CFrame.new(1,1.35,-0.75) * CFrame.Angles(math.rad(-30),math.rad(35),math.rad(-25));

------//Aim Animations
self.RightAim 		= CFrame.new(-.575, 1, -.65) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0));
self.LeftAim 		= CFrame.new(1.3,0.35,-1.45) * CFrame.Angles(math.rad(-120),math.rad(35),math.rad(-25));

------//Sprinting Animations
self.RightSprint 	= CFrame.new(-1, 1.5, -0.45) * CFrame.Angles(math.rad(-30), math.rad(0), math.rad(0));
self.LeftSprint 	= CFrame.new(1,1.35,-0.75) * CFrame.Angles(math.rad(-30),math.rad(35),math.rad(-25));

return self