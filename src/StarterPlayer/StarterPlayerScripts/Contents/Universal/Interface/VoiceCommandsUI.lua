local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Network = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Network"))
local ui_animation = require(ReplicatedStorage.Common.Libraries.UIAnimations)
local CharacterLibrary = require(ReplicatedStorage.Common.Libraries.CharacterLibrary)

local Voices = SoundService:WaitForChild("Voices")
local VoiceCommandsShared = ReplicatedStorage:WaitForChild("UI"):WaitForChild("VoiceCommands")

-- Ping
local PingPrefab: Part = VoiceCommandsShared:WaitForChild("Ping")
local PingFadeTween = TweenInfo.new(5, Enum.EasingStyle.Linear)
local PingSound: Sound = SoundService:WaitForChild("Pings"):WaitForChild("PingSound")

-- LocalPlayer Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer.PlayerGui or LocalPlayer:WaitForChild("PlayerGui")
local VoiceCommandsUI: ScreenGui = PlayerGui:WaitForChild("VoiceCommands")
local CategoryFrame: Frame = VoiceCommandsUI:WaitForChild("CategoryFrame")
local CategoryList: Frame = CategoryFrame:WaitForChild("CategoryList")
local VoiceList: Frame = CategoryFrame:WaitForChild("VoiceList")

-- UI
local SampleButton: TextButton =
	ReplicatedStorage:WaitForChild("UI"):WaitForChild("VoiceCommands"):WaitForChild("SampleButton")
local IconBar: Frame = PlayerGui:WaitForChild("Main"):WaitForChild("IconBar")
local VoiceIcon: Frame = IconBar:WaitForChild("Voice")
local VoiceIconImageSize: UDim2 = VoiceIcon:WaitForChild("ImageButton").Size

-- States / Connections
local CurrentActor = "Harry"
local ButtonConnections: { RBXScriptConnection } = {}

local activePings = {}

local module = {}

local function DisconnectConnections()
	for _, Connection in pairs(ButtonConnections) do
		Connection:Disconnect()
	end

	ButtonConnections = {}

	for _, Button in CategoryList:GetChildren() do
		if not Button:IsA("ImageButton") then
			continue
		end
		Button:Destroy()
	end

	for _, Button in VoiceList:GetChildren() do
		if not Button:IsA("ImageButton") then
			continue
		end
		Button:Destroy()
	end
end

--[[
    Populates the voice list with the given category's voices

    @param Category: Folder
]]
local function populateVoiceList(Category: Folder)
	if not Category then
		return
	end

	DisconnectConnections()
	CategoryList.Visible = false

	for _, Voice in Category:GetChildren() do
		local VoiceButton = SampleButton:Clone()
		VoiceButton.Name = Voice.Name
		VoiceButton.TextLabel.Text = Voice.Name
		VoiceButton.Parent = VoiceList
		VoiceButton.Visible = true
		ButtonConnections[VoiceButton] = VoiceButton.MouseButton1Click:Connect(function()
			Network.fireServer(Network.RemoteEvents.VoiceCommand, CurrentActor, Voice.Name)
			VoiceCommandsUI.Enabled = false
			DisconnectConnections()
		end)

		VoiceButton.MouseEnter:Connect(function()
			VoiceButton.TextLabel.TextTransparency = 0.5
		end)

		VoiceButton.MouseLeave:Connect(function()
			VoiceButton.TextLabel.TextTransparency = 0
		end)
	end

	VoiceList.Visible = true
	VoiceList.CanvasPosition = Vector2.new(0, 0)
end

--[[
    Populates the category list with the current actor's categories

    @return nil
]]
local function populateCategoryList()
	if not Voices:FindFirstChild(CurrentActor) then
		return
	end

	if VoiceCommandsUI.Enabled then
		VoiceCommandsUI.Enabled = not VoiceCommandsUI.Enabled
		return
	else
		VoiceCommandsUI.Enabled = not VoiceCommandsUI.Enabled
	end

	DisconnectConnections()
	VoiceList.Visible = false

	for _, Category in Voices[CurrentActor]:GetChildren() do
		local CategoryButton = SampleButton:Clone()
		CategoryButton.Name = Category.Name
		CategoryButton.TextLabel.Text = Category.Name
		CategoryButton.Parent = CategoryList
		CategoryButton.Visible = true
		ButtonConnections[CategoryButton] = CategoryButton.MouseButton1Click:Connect(function()
			populateVoiceList(Category)
		end)

		CategoryButton.MouseEnter:Connect(function()
			CategoryButton.TextLabel.TextTransparency = 0.5
		end)

		CategoryButton.MouseLeave:Connect(function()
			CategoryButton.TextLabel.TextTransparency = 0
		end)
	end

	CategoryList.Visible = true
	CategoryList.CanvasPosition = Vector2.new(0, 0)
end

--[[
    Fires the mouse ping event with the current actor, zombie model, and mouse position
]]
local function mousePing()
	if not Mouse.Target then
		return
	end

	local Model = Mouse.Target:FindFirstAncestorWhichIsA("Model")

	if Model and Model.Parent == workspace.Zombies then
		Network.fireServer(Network.RemoteEvents.MousePing, CurrentActor, Model, Mouse.Hit.Position)
	else
		Network.fireServer(Network.RemoteEvents.MousePing, CurrentActor, nil, Mouse.Hit.Position)
	end
end

--[[
    Plays the sound from the character's HumanoidRootPart

    @param character: Model
    @param actorName: string
    @param voiceName: string
    @return nil
]]
local function PlayVoiceFromRootPart(character: Model, actorName: string, voiceName: string)
	if not character or not actorName or not voiceName then
		return
	end

	local Actor = Voices:FindFirstChild(actorName)
	if not Actor then
		return
	end

	local Voice = Actor:FindFirstChild(voiceName, true)
	if not Voice then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	Voice = Voice:Clone()
	Voice.Parent = humanoidRootPart
	Voice:Play()
	Debris:AddItem(Voice, 5)
end

--[[
    Creates a ping at the given position or at the given model's head

    @param player: Player
    @param PingSource: Vector3 | Model
]]
local function createPing(player: Player, PingSource: Vector3 | Model)
	if activePings[player] then
		activePings[player]:Destroy()
	end
	local Ping = PingPrefab:Clone()
	activePings[player] = Ping
	Debris:AddItem(Ping, 5)
	local BillboardGui = Ping:FindFirstChildWhichIsA("BillboardGui")
	assert(BillboardGui, script.Name .. " - BillboardGui not found in PingPrefab")

	local Frame = BillboardGui:FindFirstChildWhichIsA("Frame")
	local DisplayText: TextLabel = Frame:FindFirstChild("DisplayName")
	local DisplayImage: ImageLabel = Frame:FindFirstChild("Marker")
	local PlayerIcon: ImageLabel = Frame:FindFirstChild("PlayerIcon")
	local avatar =
		Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	assert(
		Frame and DisplayText and DisplayImage,
		script.Name .. " - DisplayText or DisplayImage not found in PingPrefab"
	)

	DisplayText.Text = player.DisplayName
	PlayerIcon.Image = avatar

	Ping.Parent = workspace.Pings

	if typeof(PingSource) == "Vector3" then
		Ping.CFrame = CFrame.new(PingSource)
	else
		BillboardGui.Adornee = PingSource.Head
		BillboardGui.ExtentsOffsetWorldSpace = Vector3.new(0, 4, 0)
		Debris:AddItem(BillboardGui, 5)
	end

	local HumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
	assert(HumanoidRootPart, script.Name .. " - HumanoidRootPart not found in " .. player.DisplayName .. "'s character")

	local PingSoundClone = PingSound:Clone()
	PingSoundClone.Parent = HumanoidRootPart
	PingSoundClone:Play()
	Debris:AddItem(PingSoundClone, 3)

	TweenService:Create(DisplayText, PingFadeTween, { TextTransparency = 1 }):Play()
	TweenService:Create(DisplayImage, PingFadeTween, { ImageTransparency = 1 }):Play()
	TweenService:Create(PlayerIcon, PingFadeTween, { ImageTransparency = 1, BackgroundTransparency = 1 }):Play()
end

local Keybinds: { [string]: () -> nil } = {
	[Enum.KeyCode.V.Name] = populateCategoryList,
	[Enum.KeyCode.DPadRight.Name] = populateCategoryList,
	[Enum.UserInputType.MouseButton3.Name] = mousePing,
}

function module.init()
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if CharacterLibrary.IsDead(LocalPlayer) then
			return
		end
		if gameProcessedEvent then
			return
		end

		if Keybinds[input.KeyCode.Name] then
			Keybinds[input.KeyCode.Name]()
		elseif Keybinds[input.UserInputType.Name] then
			Keybinds[input.UserInputType.Name]()
		end
	end)

	VoiceIcon.MouseEnter:Connect(function()
		ui_animation.TabEnter(VoiceIcon, VoiceIcon.ImageButton, VoiceIconImageSize)
	end)

	VoiceIcon.MouseLeave:Connect(function()
		ui_animation.TabLeave(VoiceIcon, VoiceIcon.ImageButton, VoiceIconImageSize)
	end)

	VoiceIcon.ImageButton.MouseButton1Click:Connect(function()
		populateCategoryList()
	end)

	CategoryFrame.CloseButton.MouseButton1Click:Connect(function()
		populateCategoryList()
	end)

	CategoryFrame.CloseButton.MouseEnter:Connect(function()
		CategoryFrame.CloseButton.ImageTransparency = 0.5
	end)

	CategoryFrame.CloseButton.MouseLeave:Connect(function()
		CategoryFrame.CloseButton.ImageTransparency = 0
	end)

	Network.connectEvent(
		Network.RemoteEvents.VoiceCommand,
		function(player: Player, actorName: string, voiceName: string)
			PlayVoiceFromRootPart(player.Character, actorName, voiceName)
		end,
		Network.t.instanceOf("Player"),
		Network.t.string,
		Network.t.string
	)

	Network.connectEvent(
		Network.RemoteEvents.MousePing,
		function(player: Player, actorName: string, PingSource: Model | Vector3)
			if typeof(PingSource) == "Instance" then
				PlayVoiceFromRootPart(player.Character, actorName, PingSource.Name)
				createPing(player, PingSource)
			else
				createPing(player, PingSource)
			end
		end,
		Network.t.instanceOf("Player"),
		Network.t.string,
		Network.t.any
	)
end

return module
