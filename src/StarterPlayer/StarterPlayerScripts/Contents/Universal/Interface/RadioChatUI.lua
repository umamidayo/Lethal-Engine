local module = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local textService = game:GetService("TextService")
local textChatService = game:GetService("TextChatService")

local radio_event = ReplicatedStorage:WaitForChild("RemotesLegacy"):WaitForChild("Radio_Event")
local player = Players.LocalPlayer
local radioGui: ScreenGui = player:WaitForChild("PlayerGui"):WaitForChild("RadioGui")
local holder: Frame = radioGui:WaitForChild("Holder")
local logFrame = holder:WaitForChild("LogFrame")
local buttonFrame: Frame = holder:WaitForChild("ButtonFrame")
local channelFrame: Frame = holder:WaitForChild("ChannelFrame")
local logs: ScrollingFrame = logFrame:WaitForChild("Logs")
local messageLabel: TextLabel = ReplicatedStorage:WaitForChild("UI"):WaitForChild("RadioMessage")
local RadioSound: Sound = SoundService:WaitForChild("RadioChat"):WaitForChild("RadioSound")

local talk = false
local mute = false

local onColor = Color3.fromRGB(41, 90, 36)
local offColor = Color3.fromRGB(25, 25, 25)

local messages: {TextLabel} = {}
local maxMessages = 50

local channels = {
	["Channel1"] = {
		channelName = "CH.1",
		enabled = true,
		frequency = 100,
		textColor = Color3.fromRGB(105, 255, 105)
	},

	["Channel2"] = {
		channelName = "CH.2",
		enabled = false,
		frequency = math.random(1, 9999),
		textColor = Color3.fromRGB(255, 239, 116)
	},

	["Channel3"] = {
		channelName = "CH.3",
		enabled = false,
		frequency = math.random(1, 9999),
		textColor = Color3.fromRGB(25, 148, 255)
	},
}

local function scaleLog()
	local ySize = 0

	for _,v in pairs(messages) do
		ySize += v.AbsoluteSize.Y
	end

	logs.CanvasSize = UDim2.new(0, 0, 0, ySize + 5)
	logs.CanvasPosition = Vector2.new(0, logs.AbsoluteCanvasSize.Y)

	ySize = nil
end

local function clearOlderMessages()
	if #messages > maxMessages then
		messages[1]:Destroy()
		table.remove(messages, 1)
	end

	for i = 1, maxMessages do
		for _,message in ipairs(messages) do
			message.LayoutOrder = i
		end
	end

	scaleLog()
end

local function systemMessage(message)
	local newMessageLabel = messageLabel:Clone()
	local logFrameSize = textService:GetTextSize(message, newMessageLabel.TextSize, newMessageLabel.Font, radioGui.Holder.LogFrame.Logs.AbsoluteSize)
	newMessageLabel.Text = message
	newMessageLabel.Size = UDim2.new(1, -2, 0, logFrameSize.Y)
	newMessageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	newMessageLabel.TextWrapped = true
	newMessageLabel.Parent = radioGui.Holder.LogFrame.Logs
	table.insert(messages, newMessageLabel)
	newMessageLabel.LayoutOrder = #messages

	if mute == false then
		RadioSound:Play()
	end

	clearOlderMessages()

	newMessageLabel = nil
	logFrameSize = nil
end

local function newMessage(message, sender, channelName)
	local newMessageLabel = messageLabel:Clone()
	local logFrameSize = textService:GetTextSize(message, newMessageLabel.TextSize, newMessageLabel.Font, radioGui.Holder.LogFrame.Logs.AbsoluteSize)
	newMessageLabel.Text = "[" .. channels[channelName]["channelName"] .. "] " .. sender.DisplayName ..": " .. message
	newMessageLabel.Size = UDim2.new(1, -2, 0, logFrameSize.Y)
	newMessageLabel.TextColor3 = channels[channelName]["textColor"]
	newMessageLabel.TextWrapped = true
	newMessageLabel.Parent = radioGui.Holder.LogFrame.Logs
	table.insert(messages, newMessageLabel)
	newMessageLabel.LayoutOrder = #messages

	if mute == false then
		RadioSound:Play()
	end

	clearOlderMessages()

	newMessageLabel = nil
	logFrameSize = nil
end

local function toggleTalk()
	if talk == true then
		talk = false
		buttonFrame.BroadcastButton.BackgroundColor3 = offColor
	else
		talk = true
		buttonFrame.BroadcastButton.BackgroundColor3 = onColor
	end
end

local function toggleHide()
	if radioGui.Holder.LogFrame.Visible == true then
		radioGui.Holder.LogFrame.Visible = false
		buttonFrame.HideButton.BackgroundColor3 = offColor
	else
		radioGui.Holder.LogFrame.Visible = true
		buttonFrame.HideButton.BackgroundColor3 = onColor
	end
end

local function toggleMute()
	if mute == true then
		mute = false
		buttonFrame.MuteButton.BackgroundColor3 = offColor
	else
		mute = true
		buttonFrame.MuteButton.BackgroundColor3 = onColor
	end
end

local function toggleChannels()
	if radioGui.Holder.ChannelFrame.Visible == true then
		radioGui.Holder.ChannelFrame.Visible = false
		buttonFrame.ChannelButton.BackgroundColor3 = offColor
	else
		radioGui.Holder.ChannelFrame.Visible = true
		buttonFrame.ChannelButton.BackgroundColor3 = onColor
	end
end

local function updateChannel(channelName, channelData, value)
	channels[channelName][channelData] = value

	channelFrame:FindFirstChild(channelName).TextBox.Text = tostring(channels[channelName]["frequency"])

	if channels[channelName]["enabled"] == true then
		channelFrame:FindFirstChild(channelName).ChannelButton.BackgroundColor3 = onColor
	else
		channelFrame:FindFirstChild(channelName).ChannelButton.BackgroundColor3 = offColor
	end
end

local function resetChannels()
	updateChannel("Channel1", "frequency", 100)
	updateChannel("Channel2", "frequency", math.random(1, 9999))
	updateChannel("Channel3", "frequency", math.random(1, 9999))
	systemMessage("Channels have been reset.")
end

function module.init()
    textChatService.MessageReceived:Connect(function(textChatMessage)
        if not textChatMessage then return end
        if not textChatMessage.TextSource then return end
		if string.sub(textChatMessage.Text, 1, 1) == "/" then return end

        if textChatMessage.TextSource.Name == player.Name then
            if talk == false then return end
            radio_event:FireServer(textChatMessage.Text, textChatMessage.TextSource.Name, channels)
        end
    end)

    radio_event.OnClientEvent:Connect(function(message, sender, senderChannels)
        for channelName,channelData in pairs(channels) do
            for senderChannelName, senderChannelData in pairs(senderChannels) do
                if channelName == senderChannelName then
                    if channelData["frequency"] == senderChannelData["frequency"] then
                        if senderChannelData["enabled"] == true then
                            newMessage(message, sender, senderChannelName)
                        end
                    end
                end
            end
        end
    end)

    buttonFrame.BroadcastButton.MouseButton1Click:Connect(function()
        toggleTalk()
    end)

    buttonFrame.HideButton.MouseButton1Click:Connect(function()
        toggleHide()
    end)

    buttonFrame.MuteButton.MouseButton1Click:Connect(function()
        toggleMute()
    end)

    buttonFrame.ChannelButton.MouseButton1Click:Connect(function()
        toggleChannels()
    end)

    buttonFrame.ResetButton.MouseButton1Click:Connect(function()
        resetChannels()
    end)

	local hovered = false

    holder.MouseEnter:Connect(function()
        if not logFrame.Visible then return end
        channelFrame.BackgroundTransparency = 0.3
        logFrame.BackgroundTransparency = 0.3
        buttonFrame.BackgroundTransparency = 0.3
		hovered = true
    end)

    holder.MouseLeave:Connect(function()
        channelFrame.BackgroundTransparency = 0.9
        logFrame.BackgroundTransparency = 0.9
        buttonFrame.BackgroundTransparency = 0.9
    end)

    for i,v in pairs(channelFrame:GetChildren()) do
        if v:IsA("Frame") then
            v.ChannelButton.MouseButton1Click:Connect(function()
                if channels[v.Name]["enabled"] == true then
                    channels[v.Name]["enabled"] = false
                    v.ChannelButton.BackgroundColor3 = offColor
                else
                    channels[v.Name]["enabled"] =  true
                    v.ChannelButton.BackgroundColor3 = onColor
                end
            end)

            v.TextBox.FocusLost:Connect(function()
                if not tonumber(v.TextBox.Text) then
                    v.TextBox.Text = channels[v.Name]["frequency"]
                    return
                end

                updateChannel(v.Name, "frequency", tonumber(v.TextBox.Text))
                systemMessage("Updated " .. channels[v.Name]["channelName"] .. " frequency to " .. tostring(channels[v.Name]["frequency"]) .. "Hz.")
            end)
        end
    end

    toggleTalk()
    toggleHide()

	task.delay(4, function()
		if hovered then return end
		channelFrame.BackgroundTransparency = 0.9
        logFrame.BackgroundTransparency = 0.9
        buttonFrame.BackgroundTransparency = 0.9
	end)

    for i,v in pairs(channels) do
        updateChannel(i, "frequency", channels[i]["frequency"])
        updateChannel(i, "enabled", channels[i]["enabled"])
    end
end

return module
