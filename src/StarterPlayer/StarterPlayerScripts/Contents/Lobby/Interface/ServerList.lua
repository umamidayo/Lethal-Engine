local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

export type ServerData = {
	LastSent: number?,
	PlaceId: number?,
	ServerId: string?,
	ServerUptime: number?,
	UserIds: { number }?,
}

local Maid = require(ReplicatedStorage.Common.Libraries.Maid)
local Network = require(ReplicatedStorage.Common.Network)
local Notifier = require(ReplicatedStorage.Common.Libraries.Notifier)

local Components = ReplicatedStorage.UI.ServerList

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui or LocalPlayer:WaitForChild("PlayerGui")
local ServersGui: ScreenGui = PlayerGui:WaitForChild("ServersGui")
local List: ScrollingFrame = ServersGui.Frame.List
local Close: ImageButton = ServersGui.Frame.Close
local Refresh: ImageButton = ServersGui.Frame.Refresh
local maid = Maid.new()

local refreshDebounce = nil

local ServerList = {}

local function verifyServerData(server: ServerData)
	if not server.LastSent then
		return false
	end

	if not server.PlaceId then
		return false
	end

	if not server.ServerId then
		return false
	end

	if not server.ServerUptime then
		return false
	end

	if not server.UserIds then
		return false
	end

	return true
end

function ServerList.getPlayerName(userId: number): string
	local success, response = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)

	if not success then
		warn("Failed to get player name: " .. response)
	else
		return response
	end
end

function ServerList.formatSecondsToDate(seconds: number)
	local days = math.floor(seconds / 86400)
	local hours = math.floor(seconds % 86400 / 3600)
	local minutes = math.floor(seconds % 3600 / 60)

	return `{days} DAYS, {hours} HOURS, {minutes} MINUTES`
end

function ServerList.createServers(servers: { ServerData })
	if not servers or next(servers) == nil then
		warn("An issue occurred while fetching servers.")
		warn(`Servers: {servers}`)
		return
	end

	local serverId = 1
	for _, server in servers do
		if not verifyServerData(server) then
			continue
		end

		if #server.UserIds <= 0 then
			continue
		end

		local uptimeText = ServerList.formatSecondsToDate(server.ServerUptime)

		local component = Components.Server:Clone()
		component.ServerId.Text = `SERVER #{serverId}`
		component.ServerUptime.Text = `DURATION: {uptimeText}`
		component.PlayerCount.Text = `{#server.UserIds}/16 PLAYERS`
		component.Round.Text = `ROUND {server.Round}`

		component.Join.MouseButton1Click:Connect(function()
			SoundService:PlayLocalSound(SoundService.UI.Click)
			local success, response =
				Network.invokeServerAsync(Network.RemoteFunctions.RequestTeleport, "JoinServer", server.ServerId)
			if not success then
				warn("Failed to teleport: " .. response)
			end
		end)

		component.Join.MouseEnter:Connect(function()
			component.Join.TextColor3 = Color3.fromRGB(179, 179, 179)
			SoundService:PlayLocalSound(SoundService.UI.Hover)
		end)

		component.Join.MouseLeave:Connect(function()
			component.Join.TextColor3 = Color3.fromRGB(255, 255, 255)
		end)

		for _, userId in server.UserIds do
			local playerName = ServerList.getPlayerName(userId)
			local playerComponent = Components.PlayerName:Clone()
			playerComponent.Text = playerName
			if LocalPlayer:IsFriendsWith(userId) then
				playerComponent.TextColor3 = Color3.fromRGB(119, 231, 134)
			end
			playerComponent.Parent = component.Players
		end

		component.Parent = List
		serverId += 1
		List.CanvasSize = UDim2.new(0, 0, 0, List.UIListLayout.AbsoluteContentSize.Y)

		maid:GiveTask(component)
	end
end

function ServerList.toggle(enabled: boolean)
	ServersGui.Enabled = enabled
end

function ServerList.updateServerList(delayTime: number?)
	ServerList.toggle(true)

	if refreshDebounce and tick() - refreshDebounce < 1 then
		local waitTime = math.ceil(1 - (tick() - refreshDebounce))
		Notifier.new(`Wait another {waitTime} seconds before refreshing the server list.`)
		return
	else
		refreshDebounce = tick()
	end

	task.delay(delayTime or 0, function()
		local success, servers = Network.invokeServerAsync(Network.RemoteFunctions.RequestServerListing)
		if not success then
			warn(`Failed to get servers: {servers}`)
			Notifier.new(`Failed to get servers: {servers}`, Color3.fromRGB(255, 0, 0), 10)
		else
			maid:DoCleaning()
			task.spawn(ServerList.createServers, servers)
		end
	end)
end

function ServerList.init()
	Close.MouseButton1Click:Connect(function()
		SoundService:PlayLocalSound(SoundService.UI.Click)
		ServerList.toggle(false)
	end)

	Close.MouseEnter:Connect(function()
		SoundService:PlayLocalSound(SoundService.UI.Hover)
		Close.ImageColor3 = Color3.fromRGB(117, 54, 54)
	end)

	Close.MouseLeave:Connect(function()
		Close.ImageColor3 = Color3.fromRGB(150, 58, 58)
	end)

	Refresh.MouseButton1Click:Connect(function()
		SoundService:PlayLocalSound(SoundService.UI.Click)
		ServerList.updateServerList()
	end)

	Refresh.MouseEnter:Connect(function()
		Refresh.ImageColor3 = Color3.fromRGB(179, 179, 179)
		SoundService:PlayLocalSound(SoundService.UI.Hover)
	end)

	Refresh.MouseLeave:Connect(function()
		Refresh.ImageColor3 = Color3.fromRGB(255, 255, 255)
	end)
end

return ServerList
