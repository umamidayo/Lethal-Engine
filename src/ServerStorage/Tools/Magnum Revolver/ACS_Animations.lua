local TS = game:GetService('TweenService')
local Player = game.Players.LocalPlayer
local Character = Player.Character
local Tool = script.Parent
local self = {}

self.MainCFrame 	= CFrame.new(0.5,-.85,-0.75)

self.GunModelFixed 	= true
self.GunCFrame 		= CFrame.new(0.15, -.2, 1) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))
self.LArmCFrame 	= CFrame.new(-.6,-0.3,0) * CFrame.Angles(math.rad(90),math.rad(25),math.rad(15))
self.RArmCFrame 	= CFrame.new(0,-0.15,0) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))

self.EquipAnim = function(objs)
	if Tool:FindFirstChild("Spin") then
		local Spin = Tool:FindFirstChild("Spin")
	else
		local Spin = Instance.new("IntValue", Tool)
		Spin.Name = "Spin"
		Spin.Value = 0
	end
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
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0,-0.15,0.1) * CFrame.Angles(math.rad(70), math.rad(0), math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-.55,-0.45,0) * CFrame.Angles(math.rad(75),math.rad(25),math.rad(15))):inverse() }):Play()
	wait(0.25)	
end;

self.HighReady = function(objs)
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0.15,-0.1,0.5) * CFrame.Angles(math.rad(145), math.rad(0), math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-.2,-0.25,0) * CFrame.Angles(math.rad(155),math.rad(55),math.rad(15))):inverse() }):Play()
	wait(0.25)	
end;

self.Patrol = function(objs)
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0,-0.15,0.5) * CFrame.Angles(math.rad(55), math.rad(0), math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-.55,-0.45,0.4) * CFrame.Angles(math.rad(60),math.rad(25),math.rad(15))):inverse() }):Play()	
	wait(.25)	
end;

self.SprintAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(.5,-0.15,0) * CFrame.Angles(math.rad(175),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()	
	wait(.25)
end;

self.ReloadAnim = function(objs)
	objs[4].Bullet1.Transparency = 1
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.80,-0.35,-0.15) * CFrame.Angles(math.rad(90),math.rad(60),math.rad(30))):inverse() }):Play()
	wait(0.2)
	objs[4].Handle.AimUp:Play()
	TS:Create(objs[1], TweenInfo.new(.35,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(90),math.rad(50),math.rad(0))):inverse() }):Play()
	TS:Create(objs[1], TweenInfo.new(.35,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(90),math.rad(-10),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.80,-0.55,-0.05) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(90))):inverse() }):Play()
	wait(0.1)
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.25,-2.75,.85) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(90))):inverse() }):Play()
	objs[4].Bolt.SlidePull:Play()
	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,0):inverse() }):Play()
	TS:Create(objs[4].Handle.Cylinder, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 =  CFrame.new(0,0,-0.22):inverse() }):Play()
	wait(.15)
	--TS:Create(objs[1], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	--wait(.15)
	TS:Create(objs[1], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.6) * CFrame.Angles(math.rad(120),math.rad(-25),math.rad(0))):inverse() }):Play()
	objs[4].Handle.AimDown:Play()
	wait(.3)
	TS:Create(objs[1], TweenInfo.new(.1,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(120),math.rad(25),math.rad(0))):inverse() }):Play()
	objs[4].Handle.AimUp:Play()
	wait(0.12)
	
	objs[4].Handle.MagOut:Play()
	objs[4].Handle.MagOut2:Play()
	objs[4].Handle.MagOut3:Play()
	objs[4].Mag.Transparency = 1
	
	local FakeMag = objs[4]:WaitForChild("Shells"):Clone()
	FakeMag:ClearAllChildren()
	FakeMag.Transparency = 0
	FakeMag.Parent = objs[4]
	FakeMag.Anchored = false
	FakeMag.RotVelocity = Vector3.new(0,0,0)
	FakeMag.Velocity = (FakeMag.CFrame.UpVector * -5)
	
	wait(.45)
	objs[4].Handle.AimUp:Play()
	TS:Create(objs[1], TweenInfo.new(.35,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))):inverse() }):Play()
    
	wait(.15) --New Mag
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.25,-2.75,.85) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(90))):inverse() }):Play()
	wait(0.15)
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.80,-0.45,0.5) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(105))):inverse() }):Play()
	TS:Create(objs[4].Handle.SpeedLoader, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 =  CFrame.new(0,0,0.4):inverse() }):Play()
	TS:Create(objs[4].Handle.MagSL, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 =  CFrame.new(-0.4,0,0):inverse() }):Play()
	wait(.15)
	objs[4].MagSL.Transparency = 0
	objs[4].SpeedLoader.Transparency = 0
	wait(0.05)
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.80,-0.45,-0.05) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(105))):inverse() }):Play()
	TS:Create(objs[4].Handle.MagSL, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 =  CFrame.new():inverse() }):Play()
	TS:Create(objs[4].Handle.SpeedLoader, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 =  CFrame.new():inverse() }):Play()
	
	wait(.15) -- Load Anim
	objs[4].Handle.MagIn:Play()
	objs[4].MagSL.Transparency = 1
	wait(0.1)
	objs[4].Mag.Transparency = 0
	wait(.1)
	TS:Create(objs[1], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))):inverse() }):Play()

	wait(.15)
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.80,-0.45,0.5) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(105))):inverse() }):Play()
	TS:Create(objs[4].Handle.SpeedLoader, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 =  CFrame.new(0,0,0.4):inverse() }):Play()
	wait(0.15)
	objs[4].Handle.AimUp:Play()
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.1,0,0.5) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(105))):inverse() }):Play()
	TS:Create(objs[4].Handle.SpeedLoader, TweenInfo.new(.33,Enum.EasingStyle.Sine), {C1 =  CFrame.new(-2,1.2,0.4):inverse() }):Play()
	TS:Create(objs[4].Handle.MagSL, TweenInfo.new(.33,Enum.EasingStyle.Sine), {C1 =  CFrame.new(-1.4,1.2,0):inverse() }):Play()
	wait(.2)
	objs[4].SpeedLoader.Transparency = 1
	TS:Create(objs[4].Handle.SpeedLoader, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 =  CFrame.new():inverse() }):Play()
	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C0 =  CFrame.new():inverse() }):Play()
	TS:Create(objs[4].Handle.Cylinder, TweenInfo.new(.15,Enum.EasingStyle.Linear), {C1 =  CFrame.new():inverse() }):Play()
	objs[4].Bolt.SlideRelease:Play()
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.80,-0.35,0.4) * CFrame.Angles(math.rad(90),math.rad(60),math.rad(30))):inverse() }):Play()
	wait(0.25)
end;

self.TacticalReloadAnim = function(objs)
	objs[4].Bullet1.Transparency = 1
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.80,-0.35,-0.15) * CFrame.Angles(math.rad(90),math.rad(60),math.rad(30))):inverse() }):Play()
	wait(0.2)
	objs[4].Handle.AimUp:Play()
	TS:Create(objs[1], TweenInfo.new(.35,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(90),math.rad(50),math.rad(0))):inverse() }):Play()
	TS:Create(objs[1], TweenInfo.new(.35,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(90),math.rad(-10),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.80,-0.55,-0.05) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(90))):inverse() }):Play()
	wait(0.1)
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.25,-2.75,.85) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(90))):inverse() }):Play()
	objs[4].Bolt.SlidePull:Play()
	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,0):inverse() }):Play()
	TS:Create(objs[4].Handle.Cylinder, TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 =  CFrame.new(0,0,-0.22):inverse() }):Play()
	wait(.15)
	--TS:Create(objs[1], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
	--wait(.15)
	TS:Create(objs[1], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.6) * CFrame.Angles(math.rad(120),math.rad(-25),math.rad(0))):inverse() }):Play()
	objs[4].Handle.AimDown:Play()
	wait(.3)
	TS:Create(objs[1], TweenInfo.new(.1,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(120),math.rad(25),math.rad(0))):inverse() }):Play()
	objs[4].Handle.AimUp:Play()
	wait(0.12)

	objs[4].Handle.MagOut:Play()
	objs[4].Handle.MagOut2:Play()
	objs[4].Handle.MagOut3:Play()
	objs[4].Mag.Transparency = 1

	local FakeMag = objs[4]:WaitForChild("Shells"):Clone()
	FakeMag:ClearAllChildren()
	FakeMag.Transparency = 0
	FakeMag.Parent = objs[4]
	FakeMag.Anchored = false
	FakeMag.RotVelocity = Vector3.new(0,0,0)
	FakeMag.Velocity = (FakeMag.CFrame.UpVector * -5)

	wait(.45)
	objs[4].Handle.AimUp:Play()
	TS:Create(objs[1], TweenInfo.new(.35,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))):inverse() }):Play()

	wait(.15) --New Mag
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.25,-2.75,.85) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(90))):inverse() }):Play()
	wait(0.15)
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.80,-0.45,0.5) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(105))):inverse() }):Play()
	TS:Create(objs[4].Handle.SpeedLoader, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 =  CFrame.new(0,0,0.4):inverse() }):Play()
	TS:Create(objs[4].Handle.MagSL, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 =  CFrame.new(-0.4,0,0):inverse() }):Play()
	wait(.15)
	objs[4].MagSL.Transparency = 0
	objs[4].SpeedLoader.Transparency = 0
	wait(0.05)
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.80,-0.45,-0.05) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(105))):inverse() }):Play()
	TS:Create(objs[4].Handle.MagSL, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 =  CFrame.new():inverse() }):Play()
	TS:Create(objs[4].Handle.SpeedLoader, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 =  CFrame.new():inverse() }):Play()

	wait(.15) -- Load Anim
	objs[4].Handle.MagIn:Play()
	objs[4].MagSL.Transparency = 1
	wait(0.1)
	objs[4].Mag.Transparency = 0
	wait(.1)
	TS:Create(objs[1], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))):inverse() }):Play()

	wait(.15)
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.80,-0.45,0.5) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(105))):inverse() }):Play()
	TS:Create(objs[4].Handle.SpeedLoader, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 =  CFrame.new(0,0,0.4):inverse() }):Play()
	wait(0.15)
	objs[4].Handle.AimUp:Play()
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.1,0,0.5) * CFrame.Angles(math.rad(80),math.rad(60),math.rad(105))):inverse() }):Play()
	TS:Create(objs[4].Handle.SpeedLoader, TweenInfo.new(.33,Enum.EasingStyle.Sine), {C1 =  CFrame.new(-2,1.2,0.4):inverse() }):Play()
	TS:Create(objs[4].Handle.MagSL, TweenInfo.new(.33,Enum.EasingStyle.Sine), {C1 =  CFrame.new(-1.4,1.2,0):inverse() }):Play()
	wait(.2)
	objs[4].SpeedLoader.Transparency = 1
	TS:Create(objs[4].Handle.SpeedLoader, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 =  CFrame.new():inverse() }):Play()
	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C0 =  CFrame.new():inverse() }):Play()
	TS:Create(objs[4].Handle.Cylinder, TweenInfo.new(.15,Enum.EasingStyle.Linear), {C1 =  CFrame.new():inverse() }):Play()
	objs[4].Bolt.SlideRelease:Play()
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.80,-0.35,0.4) * CFrame.Angles(math.rad(90),math.rad(60),math.rad(30))):inverse() }):Play()
	wait(0.25)
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
	if Tool:FindFirstChild("Spin") then
		local Spin = Tool:FindFirstChild("Spin")
		local Cylinder = objs[4].Cylinder
		if Spin.Value == 0 then
			TS:Create(objs[4].Handle.Cylinder, TweenInfo.new(.15,Enum.EasingStyle.Linear), {C1 = (CFrame.new() * CFrame.Angles(math.rad(60),math.rad(0),math.rad(0))):inverse() }):Play()
			Spin.Value = 1
		elseif Spin.Value == 1 then
			TS:Create(objs[4].Handle.Cylinder, TweenInfo.new(.15,Enum.EasingStyle.Linear), {C1 = (CFrame.new() * CFrame.Angles(math.rad(120),math.rad(0),math.rad(0))):inverse() }):Play()
			Spin.Value = 2
		elseif Spin.Value == 2 then
			TS:Create(objs[4].Handle.Cylinder, TweenInfo.new(.15,Enum.EasingStyle.Linear), {C1 = (CFrame.new() * CFrame.Angles(math.rad(180),math.rad(0),math.rad(0))):inverse() }):Play()
			Spin.Value = 3
		elseif Spin.Value == 3 then
			TS:Create(objs[4].Handle.Cylinder, TweenInfo.new(.15,Enum.EasingStyle.Linear), {C1 = (CFrame.new() * CFrame.Angles(math.rad(240),math.rad(0),math.rad(0))):inverse() }):Play()
			Spin.Value = 4
		elseif Spin.Value == 4 then
			TS:Create(objs[4].Handle.Cylinder, TweenInfo.new(.15,Enum.EasingStyle.Linear), {C1 = (CFrame.new() * CFrame.Angles(math.rad(300),math.rad(0),math.rad(0))):inverse() }):Play()
			Spin.Value = 5
		elseif Spin.Value == 5 then
			TS:Create(objs[4].Handle.Cylinder, TweenInfo.new(.15,Enum.EasingStyle.Linear), {C1 = (CFrame.new() * CFrame.Angles(math.rad(360),math.rad(0),math.rad(0))):inverse() }):Play()
			Spin.Value = 0
		end
		wait(0.15)
	end
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