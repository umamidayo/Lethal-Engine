script.Parent.AncestryChanged:Once(function()
	local PlayerRadioEvent = game.ReplicatedStorage.RemotesLegacy.PlayerRadioEvent
	
	script.Parent.MeshPart.ProximityPrompt.Enabled = true
	
	script.Parent.MeshPart.ProximityPrompt.Triggered:Connect(function(player)
		PlayerRadioEvent:FireClient(player, script.Parent)
	end)
end)