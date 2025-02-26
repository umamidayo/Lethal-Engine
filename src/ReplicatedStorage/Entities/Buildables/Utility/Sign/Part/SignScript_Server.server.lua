local ChatService = game:GetService("Chat")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sign_Event = ReplicatedStorage.RemotesLegacy.Sign_Event
local SignGui = ReplicatedStorage.UI.SignGui

local debounce = {}
local cooldown = 1

script.Parent.ClickDetector.MouseClick:Connect(function(player)
	if script.Parent.Parent:GetAttribute("Owner") ~= player.Name then return end
	
	if player.PlayerGui:FindFirstChild("SignGui") then
		player.PlayerGui.SignGui:Destroy()
	end
	
	local signGui = SignGui:Clone()
	signGui.Sign.Value = script.Parent.Parent
	signGui.Parent = player.PlayerGui
end)

Sign_Event.OnServerEvent:Connect(function(player, sign, text)
	if not sign or not text then return end
	if debounce[sign] ~= nil and (tick() - debounce[sign]) < cooldown then return end
	
	if sign:GetAttribute("Owner") == player.Name then
		if player:DistanceFromCharacter(sign.PrimaryPart.Position) < 10 then
			debounce[sign] = tick()
			text = string.sub(text, 1, 200)
			local filteredText = ChatService:FilterStringForBroadcast(text, player)
			sign.PrimaryPart.SurfaceGui.TextLabel.Text = filteredText
			Sign_Event:FireClient(player)
		end
	end
end)