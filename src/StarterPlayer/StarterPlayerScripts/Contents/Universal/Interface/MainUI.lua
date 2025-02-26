local module = {}

local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Remotes = ReplicatedStorage:WaitForChild("RemotesLegacy")
local Common = ReplicatedStorage:WaitForChild("Common")

local Network = require(Common:WaitForChild("Network"))
local Notifier = require(Common.Libraries.Notifier)
local Prettify = require(Common.Libraries.Prettify)
local TopBarPlus = require(ReplicatedStorage.Dependencies.Icon)
local ui_animation = require(Common.Libraries.UIAnimations)
local ZombieTextColors = require(Common.ZombieTextColors)
local SoundManager = require(Common.Shared.Universal.SoundManager)

local NotifyEvent: RemoteEvent = Remotes:WaitForChild("Notifier")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("Main")

local serverInfo = ReplicatedStorage:WaitForChild("ServerInfo")
local region = serverInfo:WaitForChild("Region")
local country = serverInfo:WaitForChild("Country")
local roundSeconds = serverInfo:WaitForChild("RoundSeconds")
local serverinfoGui = gui:WaitForChild("ServerInfo")
local round_seconds

local playerinfoGui = gui:WaitForChild("PlayerInfo")
local statsGlow = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local gainColor = Color3.fromRGB(108, 255, 97)
local lossColor = Color3.fromRGB(255, 90, 90)
local defaultColor = Color3.fromRGB(220, 220, 220)

local lastCash, lastKills, lastMats

local optionsImageSize = gui.IconBar.Options.ImageButton.Size
local options = {
	HideUI = false,
	MuteRadio = false,
	PlayerHighlight = true,
	PlayerTags = true,
}

local muteConnection: RBXScriptConnection
local uiIcon: GuiObject

local journalGui = playerGui:WaitForChild("JournalGui")
local journalIcon = gui.IconBar.Journal
local journalIconSize = journalIcon.ImageButton.Size

local perksGui = player.PlayerGui:WaitForChild("PlayerClassGui")
local perksIcon = gui.IconBar.Perks
local perksIconSize = perksIcon.ImageButton.Size

local roundCounter = gui:WaitForChild("RoundCounter")
local roundEvent = Remotes:WaitForChild("RoundEvent")
local roundTween = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local killCounterEvent = Remotes:WaitForChild("KillCounter")
local label = ReplicatedStorage:WaitForChild("UI"):WaitForChild("KillCounterLabel")

local killTween = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local killCounter = gui:WaitForChild("KillCounter")

local function Format(Int)
	return string.format("%02i", Int)
end

local function convertToHMS(Seconds)
	local Minutes = (Seconds - Seconds % 60) / 60
	Seconds = Seconds - Minutes * 60
	local Hours = (Minutes - Minutes % 60) / 60
	Minutes = Minutes - Hours * 60
	return Format(Hours) .. ":" .. Format(Minutes) .. ":" .. Format(Seconds)
end

local function toggleGamepadMapping(bool)
	gui.IconBar.Journal.KeybindLabel.Visible = not bool
	gui.IconBar.Options.KeybindLabel.Visible = not bool
	gui.IconBar.Flashlight.KeybindLabel.Visible = not bool

	if bool then
		local keybindImage = UserInputService:GetImageForKeyCode(Enum.KeyCode.DPadDown)
		gui.IconBar.Flashlight.KeybindImage.Image = keybindImage

		gui.IconBar.Flashlight.KeybindImage.Visible = bool
	else
		gui.IconBar.Flashlight.KeybindImage.Visible = bool
	end
end

local function getCurrentRound()
	Network.fireServer(Network.RemoteEvents.PlayerJoinedEvent, "getCurrentRound")
end

local keybinds = {
	["P"] = function()
		gui.Options.Visible = not gui.Options.Visible
	end,

	-- ["J"] = function()
	-- 	journalGui.Enabled = not journalGui.Enabled
	-- end,
}

function module.init()
	region.Changed:Connect(function()
		serverinfoGui.Location.Text = "SERVER LOCATION: "
			.. string.upper(region.Value)
			.. ", "
			.. string.upper(country.Value)
	end)

	Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
		serverinfoGui.WorldTime.Text = "TIME OF DAY: " .. Lighting.TimeOfDay
	end)

	roundSeconds.Changed:Connect(function()
		roundSeconds.Value = math.clamp(roundSeconds.Value, 0, 3600)
		round_seconds = convertToHMS(roundSeconds.Value)
		serverinfoGui.RoundSeconds.Text = "ROUND ENDS IN: " .. round_seconds
	end)

	serverinfoGui.Location.Text = "SERVER LOCATION: "
		.. string.upper(region.Value)
		.. ", "
		.. string.upper(country.Value)
	serverinfoGui.WorldTime.Text = "TIME OF DAY: " .. Lighting.TimeOfDay

	round_seconds = convertToHMS(roundSeconds.Value)
	serverinfoGui.RoundSeconds.Text = "ROUND ENDS IN: " .. round_seconds

	local waitTick = tick()

	repeat
		task.wait()
	until player:GetAttribute("Cash") ~= nil
			and player:GetAttribute("Kills") ~= nil
			and player:GetAttribute("Materials") ~= nil
		or tick() - waitTick >= 5

	lastCash = player:GetAttribute("Cash")
	lastKills = player:GetAttribute("Kills")
	lastMats = player:GetAttribute("Materials")

	player:GetAttributeChangedSignal("Cash"):Connect(function()
		playerinfoGui.Cash.Cash.Text = "$" .. Prettify.FormatThousands(player:GetAttribute("Cash"))

		if lastCash ~= nil then
			if player:GetAttribute("Cash") > lastCash then
				TweenService:Create(playerinfoGui.Cash.Cash, statsGlow, { TextColor3 = gainColor }):Play()
			else
				TweenService:Create(playerinfoGui.Cash.Cash, statsGlow, { TextColor3 = lossColor }):Play()
			end

			task.wait(1)
			TweenService:Create(playerinfoGui.Cash.Cash, statsGlow, { TextColor3 = defaultColor }):Play()
		end

		lastCash = player:GetAttribute("Cash")
	end)

	player:GetAttributeChangedSignal("Kills"):Connect(function()
		playerinfoGui.Kills.Kills.Text = Prettify.FormatThousands(player:GetAttribute("Kills"))

		if lastKills ~= nil then
			if player:GetAttribute("Kills") > lastKills then
				TweenService:Create(playerinfoGui.Kills.Kills, statsGlow, { TextColor3 = gainColor }):Play()
			else
				TweenService:Create(playerinfoGui.Kills.Kills, statsGlow, { TextColor3 = lossColor }):Play()
			end

			task.wait(1)
			TweenService:Create(playerinfoGui.Kills.Kills, statsGlow, { TextColor3 = defaultColor }):Play()
		end

		lastKills = player:GetAttribute("Kills")
	end)

	player:GetAttributeChangedSignal("Materials"):Connect(function()
		playerinfoGui.Materials.Materials.Text = Prettify.FormatThousands(player:GetAttribute("Materials"))

		if lastMats ~= nil then
			if player:GetAttribute("Materials") > lastMats then
				TweenService:Create(playerinfoGui.Materials.Materials, statsGlow, { TextColor3 = gainColor }):Play()
			else
				TweenService:Create(playerinfoGui.Materials.Materials, statsGlow, { TextColor3 = lossColor }):Play()
			end

			task.wait(1)
			TweenService:Create(playerinfoGui.Materials.Materials, statsGlow, { TextColor3 = defaultColor }):Play()
		end

		lastMats = player:GetAttribute("Materials")
	end)

	playerinfoGui.Cash.Cash.Text = "$" .. Prettify.FormatThousands(player:GetAttribute("Cash"))
	playerinfoGui.Kills.Kills.Text = Prettify.FormatThousands(player:GetAttribute("Kills"))
	playerinfoGui.Materials.Materials.Text = Prettify.FormatThousands(player:GetAttribute("Materials"))

	roundEvent.OnClientEvent:Connect(function(eventType: string, data: { any })
		if eventType == "endGame" then
			gui.EndGame.TextLabel.TextTransparency = 1
			gui.EndGame.TextLabel.Text = "DEFEATED"
			SoundService:WaitForChild("DaySound"):WaitForChild("EndGame"):Play()
			TweenService:Create(gui.EndGame.TextLabel, roundTween, { TextTransparency = 0 }):Play()
			task.wait(5)
			TweenService:Create(gui.EndGame.TextLabel, roundTween, { TextTransparency = 1 }):Play()
		elseif eventType == "newRound" then
			playerinfoGui.Round.Round.Text = data.round
			roundCounter.TextLabel.Text = "ROUND " .. data.round
			roundCounter.TextLabel.TextTransparency = 1
			SoundService:WaitForChild("DaySound"):WaitForChild("HorrorHit"):Play()
			TweenService:Create(roundCounter.TextLabel, roundTween, { TextTransparency = 0 }):Play()
			task.wait(5)
			TweenService:Create(roundCounter.TextLabel, roundTween, { TextTransparency = 1 }):Play()
		end
	end)

	getCurrentRound()

	local function getZombies()
		local zombies = {}
		for _, zombie in workspace.Zombies:GetChildren() do
			table.insert(zombies, zombie)
		end
		for _, zombie in workspace.MotionSensorZombies:GetChildren() do
			table.insert(zombies, zombie)
		end
		return zombies
	end

	workspace:WaitForChild("Zombies").ChildAdded:Connect(function()
		local zombies = getZombies()
		playerinfoGui.Zombies.Zombies.Text = #zombies
	end)

	workspace:WaitForChild("MotionSensorZombies").ChildAdded:Connect(function()
		local zombies = getZombies()
		playerinfoGui.Zombies.Zombies.Text = #zombies
	end)

	workspace:WaitForChild("Zombies").ChildRemoved:Connect(function()
		local zombies = getZombies()
		playerinfoGui.Zombies.Zombies.Text = #zombies
	end)

	workspace:WaitForChild("MotionSensorZombies").ChildRemoved:Connect(function()
		local zombies = getZombies()
		playerinfoGui.Zombies.Zombies.Text = #zombies
	end)

	local zombies = getZombies()
	playerinfoGui.Zombies.Zombies.Text = #zombies

	killCounterEvent.OnClientEvent:Connect(function(class, reward)
		local newlabel = label:Clone()
		newlabel.TextTransparency = 1
		newlabel.TextColor3 = ZombieTextColors[class]
		newlabel.Text = class .. " +" .. reward
		newlabel.LayoutOrder = 999 - #killCounter:GetChildren()
		newlabel.Parent = killCounter

		TweenService:Create(newlabel, killTween, { TextTransparency = 0 }):Play()
		task.wait(3)
		TweenService:Create(newlabel, killTween, { TextTransparency = 1 }):Play()
		Debris:AddItem(newlabel, 1)
	end)

	NotifyEvent.OnClientEvent:Connect(function(message: string, color: Color3, seconds: number)
		Notifier.new(message, color, seconds)
	end)

	Network.connectEvent(Network.RemoteEvents.NotifierEvent, function(message: string, color: Color3, seconds: number)
		Notifier.new(message, color, seconds)
	end, Network.t.string, Network.t.Color3, Network.t.number)

	gui.IconBar.Options.MouseEnter:Connect(function()
		ui_animation.TabEnter(gui.IconBar.Options, gui.IconBar.Options.ImageButton, optionsImageSize)
	end)

	gui.IconBar.Options.MouseLeave:Connect(function()
		ui_animation.TabLeave(gui.IconBar.Options, gui.IconBar.Options.ImageButton, optionsImageSize)
	end)

	gui.IconBar.Options.ImageButton.MouseButton1Click:Connect(function()
		gui.Options.Visible = not gui.Options.Visible
	end)

	gui.Options.CloseButton.MouseButton1Click:Connect(function()
		gui.Options.Visible = false
	end)

	gui.Options.CloseButton.MouseEnter:Connect(function()
		gui.Options.CloseButton.ImageTransparency = 0.5
	end)

	gui.Options.CloseButton.MouseLeave:Connect(function()
		gui.Options.CloseButton.ImageTransparency = 0
	end)

	gui.Options.Container.HideUI.ToggleFrame.TextButton.MouseButton1Click:Connect(function()
		if not options.HideUI then
			options.HideUI = true
			player:SetAttribute("HideUI", true)
			ui_animation.Slide(gui.Options.Container.HideUI.ToggleFrame.TextButton, UDim2.new(0.5, 0, 0.5, 0))

			if not uiIcon then
				uiIcon = TopBarPlus.new()
				uiIcon:setImage("rbxassetid://11413045091")
				uiIcon:setOrder(3)
				-- uiIcon:setLabel("SETTINGS", "hovering")

				uiIcon.selected:Connect(function()
					uiIcon:deselect()
					gui.Options.Visible = not gui.Options.Visible
				end)
			else
				uiIcon:setEnabled(true)
			end

			gui.IconBar.Visible = false
			gui.PlayerInfo.Visible = false
			gui.Food.Visible = false
			gui.ServerInfo.Visible = false
			gui.RoundCounter.Visible = false
			gui.EndGame.Visible = false
			gui.KillCounter.Visible = false
			gui.Notifications.Visible = false
			gui.BodyTemp.Visible = false
			player.PlayerGui.RadioGui.Enabled = false

			if player.PlayerGui:FindFirstChild("StatusUI") then
				player.PlayerGui.StatusUI.Enabled = false
			end
		else
			options.HideUI = false
			player:SetAttribute("HideUI", false)
			ui_animation.Slide(gui.Options.Container.HideUI.ToggleFrame.TextButton, UDim2.new(0, 0, 0.5, 0))

			uiIcon:setEnabled(false)

			gui.IconBar.Visible = true
			gui.PlayerInfo.Visible = true
			gui.Food.Visible = true
			gui.ServerInfo.Visible = true
			gui.EndGame.Visible = true
			gui.RoundCounter.Visible = true
			gui.KillCounter.Visible = true
			gui.Notifications.Visible = true
			gui.BodyTemp.Visible = true
			player.PlayerGui.RadioGui.Enabled = true

			if player.PlayerGui:FindFirstChild("StatusUI") then
				player.PlayerGui.StatusUI.Enabled = true
			end
		end
	end)

	player.CharacterAdded:Connect(function()
		if options.HideUI then
			player.PlayerGui:WaitForChild("StatusUI").Enabled = false
		end
	end)

	gui.Options.Container.MuteRadio.ToggleFrame.TextButton.MouseButton1Click:Connect(function()
		if not options.MuteRadio then
			options.MuteRadio = true
			ui_animation.Slide(gui.Options.Container.MuteRadio.ToggleFrame.TextButton, UDim2.new(0.5, 0, 0.5, 0))

			local playerBuilds = workspace.Buildables:FindFirstChild("Player")
			if playerBuilds then
				for _, radio in workspace.Buildables.Player:GetChildren() do
					if radio.Name ~= "Radio" then
						continue
					end
					radio:WaitForChild("MeshPart"):WaitForChild("PlayerRadioSound").Volume = 0
				end

				muteConnection = workspace.Buildables.Player.ChildAdded:Connect(function(child)
					if child.Name ~= "Radio" then
						return
					end
					child:WaitForChild("MeshPart"):WaitForChild("PlayerRadioSound").Volume = 0
				end)
			end

			-- If it's the lobby music, mute it
			if game.PlaceId == 11614561669 then
				local lobbyMusic = SoundManager.getSound("Why")
				if lobbyMusic then
					lobbyMusic.Sound.Volume = 0
				end
			end
		else
			options.MuteRadio = false
			ui_animation.Slide(gui.Options.Container.MuteRadio.ToggleFrame.TextButton, UDim2.new(0, 0, 0.5, 0))

			if muteConnection then
				muteConnection:Disconnect()
			end

			local playerBuilds = workspace.Buildables:FindFirstChild("Player")
			if playerBuilds then
				for _, radio in workspace.Buildables.Player:GetChildren() do
					if radio.Name ~= "Radio" then
						continue
					end
					radio:WaitForChild("MeshPart"):WaitForChild("PlayerRadioSound").Volume = 0.5
				end
			end

			-- If it's the lobby music, unmute it
			if game.PlaceId == 11614561669 then
				local lobbyMusic = SoundManager.getSound("Why")
				if lobbyMusic then
					lobbyMusic.Sound.Volume = 0.2
				end
			end
		end
	end)

	gui.Options.Container.PlayerHighlight.ToggleFrame.TextButton.MouseButton1Click:Connect(function()
		if not options.PlayerHighlight then
			options.PlayerHighlight = true
			ui_animation.Slide(gui.Options.Container.PlayerHighlight.ToggleFrame.TextButton, UDim2.new(0.5, 0, 0.5, 0))
			ReplicatedStorage.Entities.Highlights.PlayerHighlight.Enabled = true
		else
			options.PlayerHighlight = false
			ui_animation.Slide(gui.Options.Container.PlayerHighlight.ToggleFrame.TextButton, UDim2.new(0, 0, 0.5, 0))
			ReplicatedStorage.Entities.Highlights.PlayerHighlight.Enabled = false
		end
	end)

	gui.Options.Container.PlayerTags.ToggleFrame.TextButton.MouseButton1Click:Connect(function()
		if not options.PlayerTags then
			options.PlayerTags = true
			ui_animation.Slide(gui.Options.Container.PlayerTags.ToggleFrame.TextButton, UDim2.new(0.5, 0, 0.5, 0))
			player:SetAttribute("ShowPlayerTags", true)
		else
			options.PlayerTags = false
			ui_animation.Slide(gui.Options.Container.PlayerTags.ToggleFrame.TextButton, UDim2.new(0, 0, 0.5, 0))
			player:SetAttribute("ShowPlayerTags", false)
		end
	end)

	player:SetAttribute("ShowPlayerTags", true)

	journalIcon.MouseEnter:Connect(function()
		ui_animation.TabEnter(journalIcon, journalIcon.ImageButton, journalIconSize)
	end)

	journalIcon.MouseLeave:Connect(function()
		ui_animation.TabLeave(journalIcon, journalIcon.ImageButton, journalIconSize)
	end)

	journalIcon.ImageButton.MouseButton1Click:Connect(function()
		journalGui.Enabled = not journalGui.Enabled
	end)

	journalGui.Main.CloseButton.MouseButton1Click:Connect(function()
		journalGui.Enabled = false
	end)

	journalGui.Main.CloseButton.MouseEnter:Connect(function()
		journalGui.Main.CloseButton.ImageTransparency = 0.5
	end)

	journalGui.Main.CloseButton.MouseLeave:Connect(function()
		journalGui.Main.CloseButton.ImageTransparency = 0
	end)

	perksIcon.MouseEnter:Connect(function()
		ui_animation.TabEnter(perksIcon, perksIcon.ImageButton, perksIconSize)
	end)

	perksIcon.MouseLeave:Connect(function()
		ui_animation.TabLeave(perksIcon, perksIcon.ImageButton, perksIconSize)
	end)

	perksIcon.ImageButton.MouseButton1Click:Connect(function()
		perksGui.Enabled = not perksGui.Enabled
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard then
			if not keybinds[input.KeyCode.Name] then
				return
			end
			keybinds[input.KeyCode.Name]()
		end
	end)

	if UserInputService.GamepadEnabled then
		toggleGamepadMapping(true)
	end

	if not UserInputService.KeyboardEnabled then
		gui.IconBar.Journal.KeybindLabel.Visible = false
		gui.IconBar.Options.KeybindLabel.Visible = false
		gui.IconBar.Flashlight.KeybindLabel.Visible = false
	else
		gui.IconBar.Journal.KeybindLabel.Visible = true
		gui.IconBar.Options.KeybindLabel.Visible = true
		gui.IconBar.Flashlight.KeybindLabel.Visible = true
	end

	UserInputService.GamepadConnected:Connect(function()
		toggleGamepadMapping(true)
	end)

	UserInputService.GamepadDisconnected:Connect(function()
		toggleGamepadMapping(false)
	end)

	-- Social Service

	if SocialService:CanSendGameInviteAsync(player) then
		local InviteIcon = TopBarPlus.new()
		InviteIcon:setImage("rbxassetid://11893826115")
		InviteIcon:setOrder(99)
		-- InviteIcon:setLabel("INVITE FRIENDS", "hovering")

		InviteIcon.selected:Connect(function()
			InviteIcon:deselect()
			SocialService:PromptGameInvite(player)
		end)
	end
end

return module
