local TS = game:GetService('TweenService')
local self = {}

self.MainCFrame 	= CFrame.new(0.5,-.85,-0.75)

self.GunModelFixed 	= true
self.GunCFrame 		= CFrame.new(0.15, -.2, .85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))
self.LArmCFrame 	= CFrame.new(-.6,-0.25,-0.55) * CFrame.Angles(math.rad(110),math.rad(15),math.rad(15))
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
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-.5,-0.85,-.25) * CFrame.Angles(math.rad(85),math.rad(15),math.rad(15))):inverse() }):Play()
	wait(0.25)	
end;

self.HighReady = function(objs)
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0.35,-0.75,1) * CFrame.Angles(math.rad(135), math.rad(0), math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-.1,-0.15,0.15) * CFrame.Angles(math.rad(155),math.rad(35),math.rad(15))):inverse() }):Play()
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
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0.35,-0.5,0.3) * CFrame.Angles(math.rad(100), math.rad(0), math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-.15,-0.4,-1) * CFrame.Angles(math.rad(110),math.rad(35),math.rad(15))):inverse() }):Play()
	wait(.2)

	local Weld = Instance.new("WeldConstraint",objs[4])
	Weld.Part0 = objs[4].Handle
	Weld.Part1 = objs[5]["Left Arm"]

	objs[3].Part0 = nil

	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.6,-0.2,.3) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(90))):inverse() }):Play()
	objs[4].Bolt.SlidePull:Play()
	wait(.2)

	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.6,-0.7,.5) * CFrame.Angles(math.rad(175),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Back),{C1 = (CFrame.new(-.15,-0.4,-1) * CFrame.Angles(math.rad(115),math.rad(35),math.rad(15))):inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.6):inverse() }):Play()	
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0.6) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(90))):inverse() }):Play()
	objs[4].Mag1.Transparency = 1

	wait(.2)
	TS:Create(objs[1], TweenInfo.new(.4,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.6,-1,3) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Back),{C1 = (CFrame.new(-.15,-0.4,-1) * CFrame.Angles(math.rad(110),math.rad(35),math.rad(15))):inverse() }):Play()
	wait(1)
	TS:Create(objs[1], TweenInfo.new(.4,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.50,0.1,.15) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.2)
	objs[4].Handle.MagIn:Play()
	objs[4].Mag.Transparency = 0
	objs[4].Clip.Transparency = 0
	wait(.2)
	objs[4].Mag.Transparency = 1
	objs[4].Mag1.Transparency = 0
	
	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.45,-0.2,.15) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.15)
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Back),{C1 = (CFrame.new(-.15,-0.5,-0.9) * CFrame.Angles(math.rad(105),math.rad(35),math.rad(15))):inverse() }):Play()
	wait(.15)
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Back),{C1 = (CFrame.new(-.15,-0.4,-1) * CFrame.Angles(math.rad(110),math.rad(35),math.rad(15))):inverse() }):Play()
	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.6,-0.7,.5) * CFrame.Angles(math.rad(175),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.25)
	
	local FakeClip = objs[4]:WaitForChild("Clip"):Clone()
	FakeClip:ClearAllChildren()
	FakeClip.Transparency = 0
	FakeClip.Parent = objs[4]
	FakeClip.Anchored = false
	FakeClip.CanCollide = true
	FakeClip.RotVelocity = Vector3.new(0,45,0)
	FakeClip.Velocity = (FakeClip.CFrame.LookVector * 20)
	game.Debris:AddItem(FakeClip,5)
	objs[4].Clip.Transparency = 1
	
	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.6,-0.2,.3) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	objs[4].Bolt.SlideRelease:Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new():inverse() }):Play()	
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(90))):inverse() }):Play()

	wait(.2)
	TS:Create(objs[1],TweenInfo.new(.2,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0.35,-0.5,0.3) * CFrame.Angles(math.rad(100), math.rad(0), math.rad(0))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.2)
	objs[4].Mag1.Transparency = 1

	objs[3].Part0 = objs[5]["Right Arm"]
	Weld:Destroy()
end;

self.TacticalReloadAnim = function(objs)
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0.35,-0.5,0.3) * CFrame.Angles(math.rad(100), math.rad(0), math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-.15,-0.4,-1) * CFrame.Angles(math.rad(110),math.rad(35),math.rad(15))):inverse() }):Play()
	wait(.2)

	local Weld = Instance.new("WeldConstraint",objs[4])
	Weld.Part0 = objs[4].Handle
	Weld.Part1 = objs[5]["Left Arm"]

	objs[3].Part0 = nil

	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.6,-0.2,.3) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(90))):inverse() }):Play()
	objs[4].Bolt.SlidePull:Play()
	wait(.2)

	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.6,-0.7,.5) * CFrame.Angles(math.rad(175),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Back),{C1 = (CFrame.new(-.15,-0.4,-1) * CFrame.Angles(math.rad(115),math.rad(35),math.rad(15))):inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.6):inverse() }):Play()	
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0.6) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(90))):inverse() }):Play()
	objs[4].Mag1.Transparency = 1

	wait(.2)
	TS:Create(objs[1], TweenInfo.new(.4,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.6,-1,3) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Back),{C1 = (CFrame.new(-.15,-0.4,-1) * CFrame.Angles(math.rad(110),math.rad(35),math.rad(15))):inverse() }):Play()
	wait(1)
	TS:Create(objs[1], TweenInfo.new(.4,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.50,0.1,.15) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.2)
	objs[4].Handle.MagIn:Play()
	objs[4].Mag.Transparency = 0
	objs[4].Clip.Transparency = 0
	wait(.2)
	objs[4].Mag.Transparency = 1
	objs[4].Mag1.Transparency = 0

	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.45,-0.2,.15) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.15)
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Back),{C1 = (CFrame.new(-.15,-0.5,-0.9) * CFrame.Angles(math.rad(105),math.rad(35),math.rad(15))):inverse() }):Play()
	wait(.15)
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Back),{C1 = (CFrame.new(-.15,-0.4,-1) * CFrame.Angles(math.rad(110),math.rad(35),math.rad(15))):inverse() }):Play()
	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.6,-0.7,.5) * CFrame.Angles(math.rad(175),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.25)

	local FakeClip = objs[4]:WaitForChild("Clip"):Clone()
	FakeClip:ClearAllChildren()
	FakeClip.Transparency = 0
	FakeClip.Parent = objs[4]
	FakeClip.Anchored = false
	FakeClip.CanCollide = true
	FakeClip.RotVelocity = Vector3.new(0,45,0)
	FakeClip.Velocity = (FakeClip.CFrame.LookVector * 20)
	game.Debris:AddItem(FakeClip,5)
	objs[4].Clip.Transparency = 1

	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.6,-0.2,.3) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	objs[4].Bolt.SlideRelease:Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new():inverse() }):Play()	
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(90))):inverse() }):Play()

	wait(.2)
	TS:Create(objs[1],TweenInfo.new(.2,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0.35,-0.5,0.3) * CFrame.Angles(math.rad(100), math.rad(0), math.rad(0))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.2)
	objs[4].Mag1.Transparency = 1

	objs[3].Part0 = objs[5]["Right Arm"]
	Weld:Destroy()
end;

self.JammedAnim = function(objs)

end;

self.PumpAnim = function(objs)
	TS:Create(objs[2], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = self.LArmCFrame:Inverse()}):Play()

	wait(.2)

	local Weld = Instance.new("WeldConstraint",objs[4])
	Weld.Part0 = objs[4].Handle
	Weld.Part1 = objs[5]["Left Arm"]

	objs[3].Part0 = nil
	
	TS:Create(objs[1], TweenInfo.new(.1,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.275,-0.4,.9) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(0.1)
	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.275,0.05,.9) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(90))):inverse() }):Play()
	objs[4].Bolt.SlidePull:Play()	
	wait(.2)

	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.275,-0.35,.9) * CFrame.Angles(math.rad(175),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.6):inverse() }):Play()	
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0.6) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(90))):inverse() }):Play()

	wait(.25)

	objs[4].Bolt.SlideRelease:Play()
	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.275,0.05,.9) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new():inverse() }):Play()	
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(90))):inverse() }):Play()
	wait(.2)
	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.275,-0.4,.9) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[4].Handle.LidHinge, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.2)
	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = self.RArmCFrame:Inverse()}):Play()
	wait(.2)

	objs[3].Part0 = objs[5]["Right Arm"]
	Weld:Destroy()
end;

self.MagCheck = function(objs)
	objs[4].Handle.AimUp:Play()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.5,-0.15,0) * CFrame.Angles(math.rad(100),math.rad(0),math.rad(-45))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(-1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(2.5)
	objs[4].Handle.AimDown:Play()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.5,-0.15,0) * CFrame.Angles(math.rad(160),math.rad(60),math.rad(-45))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(-1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(2.5)
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