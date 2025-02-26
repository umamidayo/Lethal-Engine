local debounce = nil

script.Parent.Activated:Connect(function()
	local character = script.Parent.Parent
	local humanoid: Humanoid = character:FindFirstChild("Humanoid")
	
	if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Swimming then
		if debounce then return end
		debounce = true
		local waterbottle = game.ServerStorage.Tools["Dirty Water Bottle"]:Clone()
		local player = game.Players:GetPlayerFromCharacter(character)
		local fillsound = script.WaterSound:Clone()
		fillsound.Parent = character.PrimaryPart
		fillsound:Play()
		game.Debris:AddItem(fillsound, fillsound.TimeLength)
		script.Parent.Parent = nil
		waterbottle.Parent = player.Backpack
		humanoid:EquipTool(waterbottle)
		script.Parent:Destroy()
	end
end)