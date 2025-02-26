--disable
local RS 			= game:GetService("ReplicatedStorage")
local PlayersService= game:GetService("Players")

--// Variables
local L_1_ = PlayersService.LocalPlayer

--// Functions
function UpdateTag(plr)
	if plr == L_1_ or not plr.Character or not plr.Character:FindFirstChild("TeamTagUI") then return; end;
	local Tag = plr.Character:FindFirstChild("TeamTagUI");
	if plr.Team == L_1_.Team then
		Tag.Enabled = true;
		if plr.Character:FindFirstChild("ACS_Client") and plr.Character.ACS_Client:FindFirstChild("FireTeam") and plr.Character.ACS_Client.FireTeam.SquadName.Value ~= "" then
			Tag.Frame.Icon.ImageColor3 = plr.Character.ACS_Client.FireTeam.SquadColor.Value;
		else
			Tag.Frame.Icon.ImageColor3 = Color3.fromRGB(255,255,255);
		end;
		return;
	end;
		Tag.Enabled = false;
	return;
end

--// Player Events

game:GetService("RunService").Heartbeat:connect(function()
	for _,v in pairs(game.Players:GetPlayers()) do
		UpdateTag(v);
	end;
end)