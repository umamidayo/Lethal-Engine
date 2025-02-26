local TS = game:GetService('TweenService')
local self = {}

self.MainCFrame 	= CFrame.new(0.5,-.85,-0.75)

self.GunModelFixed 	= true
self.GunCFrame 		= CFrame.new(0.15, -.2, .85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))
self.LArmCFrame 	= CFrame.new(-.65,-0.15,-.35) * CFrame.Angles(math.rad(110),math.rad(15),math.rad(15))
self.RArmCFrame 	= CFrame.new(0.05,-0.15,1) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))

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
	objs[4].Handle.AimDown:Play()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-1,0.5) * CFrame.Angles(math.rad(105),math.rad(-5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.5,-0.25,.75) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	wait(.3)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.9,0.5) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0.75,.5) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))):inverse() }):Play()
	objs[4].Handle.LidUp:Play()
	wait(.3)
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.25,-0.5,.25) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	wait(.3)
	objs[4].Handle.MagOut:Play()
	objs[4].Mag.Transparency = 1
	objs[4].Bullets.Transparency = 1

	local MagC = objs[4]:WaitForChild("Mag"):clone()
	objs[4].Mag.Transparency = 1
	MagC.Parent = objs[4]
	MagC.Name = "MagC"
	MagC.Transparency = 0			

	local MagCW = Instance.new("Motor6D")
	MagCW.Part0 = MagC
	MagCW.Part1 = objs[2].Parent.Parent:WaitForChild("Left Arm")
	MagCW.Parent = MagC
	MagCW.C1 = MagC.CFrame:toObjectSpace(objs[3].Parent.Parent:WaitForChild("Left Arm").CFrame)
	TS:Create(MagCW, TweenInfo.new(0), {C1 = (CFrame.new(0.3,-0.2,-1) * CFrame.Angles(math.rad(-90),math.rad(180),math.rad(0))):inverse() }):Play()

	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.25,-0.5,.25) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(-10))):inverse() }):Play()
	TS:Create(objs[1], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.9,0.5) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(-5))):inverse() }):Play()
	wait(.3)
	TS:Create(objs[2], TweenInfo.new(.5,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.25,-3.5,.25) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	TS:Create(objs[1], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.9,0.5) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(0))):inverse() }):Play()
	wait(1.2)
	
	objs[4].Handle.AimUp:Play()
	TS:Create(objs[2], TweenInfo.new(.4,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.25,-0.5,.25) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(-15))):inverse() }):Play()
	wait(.45)
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.25,-0.5,.25) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	wait(.2)
	objs[4].Handle.MagIn:Play()
	objs[4].Mag.Transparency = 0
	objs[4].Bullets.Transparency = 0
	MagC:Destroy()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.9,0.5) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(5))):inverse() }):Play()
	wait(.1)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.9,0.5) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(0))):inverse() }):Play()
	wait(.1)
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0.75,.5) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	wait(.3)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-1.4,0.5) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.5,-0.5,.75) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	objs[4].Handle.LidDown:Play()
	wait(.3)
	objs[4].Handle.LidClick:Play()
end;

self.TacticalReloadAnim = function(objs)
	objs[4].Handle.AimDown:Play()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-1,0.5) * CFrame.Angles(math.rad(105),math.rad(-5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,-0.5,-.5) * CFrame.Angles(math.rad(125),math.rad(10),math.rad(15))):inverse() }):Play()
	wait(0.3)
	local Weld = Instance.new("WeldConstraint",objs[4])
	Weld.Part0 = objs[4].Handle
	Weld.Part1 = objs[5]["Left Arm"]
	
	objs[3].Part0 = nil
	
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.35,-0.6,0.5) * CFrame.Angles(math.rad(105),math.rad(-5),math.rad(0))):inverse() }):Play()
	wait(0.3)

	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.35,-0.8,1.5) * CFrame.Angles(math.rad(105),math.rad(-5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.7):inverse() }):Play()
	objs[4].Bolt.SlidePull:Play()

	wait(0.3)
	
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.35,-0.6,0.5) * CFrame.Angles(math.rad(105),math.rad(-5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new():inverse() }):Play()	
	objs[4].Bolt.SlideRelease:Play()
	
	wait(0.35)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-1,0.5) * CFrame.Angles(math.rad(105),math.rad(-5),math.rad(0))):inverse() }):Play()
	wait(0.3)
	
	objs[3].Part0 = objs[5]["Right Arm"]
	Weld:Destroy()
	
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.5,-0.25,.75) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	wait(.3)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.9,0.5) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0.75,.5) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))):inverse() }):Play()
	objs[4].Handle.LidUp:Play()
	wait(.3)
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.25,-0.5,.25) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	wait(.3)
	objs[4].Handle.MagOut:Play()
	objs[4].Mag.Transparency = 1
	objs[4].Bullets.Transparency = 1

	local MagC = objs[4]:WaitForChild("Mag"):clone()
	objs[4].Mag.Transparency = 1
	MagC.Parent = objs[4]
	MagC.Name = "MagC"
	MagC.Transparency = 0			

	local MagCW = Instance.new("Motor6D")
	MagCW.Part0 = MagC
	MagCW.Part1 = objs[2].Parent.Parent:WaitForChild("Left Arm")
	MagCW.Parent = MagC
	MagCW.C1 = MagC.CFrame:toObjectSpace(objs[3].Parent.Parent:WaitForChild("Left Arm").CFrame)
	TS:Create(MagCW, TweenInfo.new(0), {C1 = (CFrame.new(0.3,-0.2,-1) * CFrame.Angles(math.rad(-90),math.rad(180),math.rad(0))):inverse() }):Play()

	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.25,-0.5,.25) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(-10))):inverse() }):Play()
	TS:Create(objs[1], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.9,0.5) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(-5))):inverse() }):Play()
	wait(.3)
	TS:Create(objs[2], TweenInfo.new(.5,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.25,-3.5,.25) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	TS:Create(objs[1], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.9,0.5) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(0))):inverse() }):Play()
	wait(2.3)

	objs[4].Handle.AimUp:Play()
	TS:Create(objs[2], TweenInfo.new(.4,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.25,-0.5,.25) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(-15))):inverse() }):Play()
	wait(.45)
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.25,-0.5,.25) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	wait(.2)
	objs[4].Handle.MagIn:Play()
	objs[4].Mag.Transparency = 0
	objs[4].Bullets.Transparency = 0
	MagC:Destroy()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.9,0.5) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(5))):inverse() }):Play()
	wait(.1)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.9,0.5) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(0))):inverse() }):Play()
	wait(.1)
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0.75,.5) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	wait(.3)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-1.4,0.5) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.5,-0.5,.75) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	objs[4].Handle.LidDown:Play()
	wait(.3)
	objs[4].Handle.LidClick:Play()
end;

self.JammedAnim = function(objs)
	objs[4].Handle.AimDown:Play()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-1,0.5) * CFrame.Angles(math.rad(105),math.rad(-5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,-0.5,-.5) * CFrame.Angles(math.rad(125),math.rad(10),math.rad(15))):inverse() }):Play()
	wait(0.3)
	
	local Weld = Instance.new("WeldConstraint",objs[4])
	Weld.Part0 = objs[4].Handle
	Weld.Part1 = objs[5]["Left Arm"]
	
	objs[3].Part0 = nil
	
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.35,-0.6,0.5) * CFrame.Angles(math.rad(105),math.rad(-5),math.rad(0))):inverse() }):Play()
	wait(0.3)
	
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.35,-0.8,1.5) * CFrame.Angles(math.rad(105),math.rad(-5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.4):inverse() }):Play()
	objs[4].Bolt.SlidePull:Play()
	
	wait(0.3)
	
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.35,-0.6,0.5) * CFrame.Angles(math.rad(105),math.rad(-5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new():inverse() }):Play()	
	objs[4].Bolt.SlideRelease:Play()
	
	wait(0.35)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-1,0.5) * CFrame.Angles(math.rad(105),math.rad(-5),math.rad(0))):inverse() }):Play()
	wait(0.3)
	
	objs[3].Part0 = objs[5]["Right Arm"]
	Weld:Destroy()
	
	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = self.RArmCFrame:Inverse()}):Play()
	TS:Create(objs[2], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = self.LArmCFrame:Inverse()}):Play()
end;

self.PumpAnim = function(objs)

end;

self.MagCheck = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-1.4,0.5) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.5,-0.25,.5) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	wait(.3)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.75,0.5) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0.75,.3) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))):inverse() }):Play()
	objs[4].Handle.LidUp:Play()
	wait(3)
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.5,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out), {C1 = (CFrame.new() * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(0.1)
	objs[4].Handle.LidClick:Play()
	wait(.5)
	objs[4].Handle.AimUp:Play()
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
self.SV_GunPos         = CFrame.new(-.3, -1, -0.4) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0));
self.SV_RightArmPos = CFrame.new(-0.85, 0.1, -1.2) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0));
self.SV_LeftArmPos     = CFrame.new(1.05,0.9,-1.4) * CFrame.Angles(math.rad(-100),math.rad(25),math.rad(-20));

------//High Ready Animations
self.RightHighReady = CFrame.new(-1, -1, -1.5) * CFrame.Angles(math.rad(-160), math.rad(0), math.rad(0));
self.LeftHighReady     = CFrame.new(.85,-0.35,-1.15) * CFrame.Angles(math.rad(-170),math.rad(60),math.rad(15));

------//Low Ready Animations
self.RightLowReady     = CFrame.new(-1, 0.5, -1.25) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0));
self.LeftLowReady     = CFrame.new(1.25,1.15,-1.35) * CFrame.Angles(math.rad(-60),math.rad(35),math.rad(-25));

------//Patrol Animations
self.RightPatrol     = CFrame.new(-1, -.35, -1.5) * CFrame.Angles(math.rad(-80), math.rad(-80), math.rad(0));
self.LeftPatrol     = CFrame.new(1,1.25,-.75) * CFrame.Angles(math.rad(-90),math.rad(-45),math.rad(-25));

------//Aim Animations
self.RightAim         = CFrame.new(-.575, 0.1, -1) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0));
self.LeftAim         = CFrame.new(1.4,0.25,-1.45) * CFrame.Angles(math.rad(-120),math.rad(35),math.rad(-25));

------//Sprinting Animations
self.RightSprint     = CFrame.new(-1, 0.5, -1.25) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0));
self.LeftSprint     = CFrame.new(1.25,1.15,-1.35) * CFrame.Angles(math.rad(-60),math.rad(35),math.rad(-25));

return self