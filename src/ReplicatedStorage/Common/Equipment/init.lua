local module = {
	AttachPoints = {
		R15 = {
			Vest = "UpperTorso",
			Face = "Head",
			Helmet = "Head",
			Belt = "LowerTorso",
		},
		R6 = {
			Vest = "Torso",
			Backpack = "Torso",
			Face = "Head",
			Wrap = "Head",
			Mask = "Head",
			Helmet = "Head",
			Nods = "Head",
			Belt = "Torso",
		}
	}
}

module.RecursiveWeld = function(Parent:Instance, RootPart:BasePart)
	for k,v: BasePart in pairs(Parent:GetChildren()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.Massless = true	
			local w = Instance.new("Weld")
			w.Part0 = RootPart
			w.Part1 = v
			w.C1 = v.CFrame:toObjectSpace(RootPart.CFrame)
			w.Parent = RootPart
			v.Anchored = false
			v.CanCollide = false
		elseif v:IsA("Model") and v.Name ~= "Up" then
			module.RecursiveWeld(v, RootPart)
		elseif v:IsA("ClickDetector") then
			v:Destroy()
		end
	end
end

module.Equip = function(Equipment:Model, Character:Model, AttachType)
	if not Equipment then return end
	
	Equipment = Equipment:Clone()
	module.RecursiveWeld(Equipment, Equipment.Middle)
	
	local weld = Instance.new("Weld")
	weld.Part0 = Character[module.AttachPoints[Character.Humanoid.RigType.Name][AttachType]]
	weld.Part1 = Equipment.Middle
	weld.Parent = weld.Part0

	Equipment.Parent = Character
end

module.Unequip = function(AttachType:string, Character:Model)
	if not AttachType then return end
	
	if Character:FindFirstChild(AttachType) then
		Character[AttachType]:Destroy()
	end
end

module.AddProtection = function(player: Player, attachType: string, item: Model)
	if not item:GetAttribute("Protection") then return end
	
	local protection = player.Character:GetAttribute("Protection")
	if protection == nil then protection = 0 end

	protection += item:GetAttribute("Protection")
	player.Character:SetAttribute("Protection", protection)
end

module.RemoveProtection = function(player: Player, attachType: string, item: Model)
	if not item:GetAttribute("Protection") then return end
	
	local protection = player.Character:GetAttribute("Protection")
	protection -= item:GetAttribute("Protection")
	player.Character:SetAttribute("Protection", protection)
end

module.ConfigureNVGs = function(model: Model)
	local up = model:FindFirstChild("Up")
	local down = model:FindFirstChild("Down")

	if up and down then
		module.RecursiveWeld(up, up.PrimaryPart)
		local nvgjoint = Instance.new("Motor6D")
		nvgjoint.Part0 = model.Middle
		nvgjoint.Part1 = up.PrimaryPart

		local upvalue = Instance.new("CFrameValue")
		local downvalue = Instance.new("CFrameValue")

		upvalue.Name = "upvalue"
		downvalue.Name = "downvalue"

		upvalue.Value = model.Middle.CFrame:inverse() * up.PrimaryPart.CFrame
		downvalue.Value = model.Middle.CFrame:inverse() * down.PrimaryPart.CFrame

		upvalue.Parent = up
		downvalue.Parent = up

		nvgjoint.Name = "twistjoint"
		nvgjoint.C0 = upvalue.Value
		nvgjoint.Parent = up

		down:Destroy()

		local autoconfig = script:WaitForChild("AUTO_CONFIG"):Clone()
		autoconfig.Parent = up
	else
		print("Missing NVG models 'up' or 'down', check your NVG models.")
	end
end

return module
