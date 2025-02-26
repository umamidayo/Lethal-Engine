local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Network = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Network"))
local Prettify = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Libraries"):WaitForChild("Prettify"))

local leaderboardStorage: Folder = ReplicatedStorage:WaitForChild("UI"):WaitForChild("Leaderboard")
local leaderboard: Model = workspace:WaitForChild("KillLeaderboard")
local frame: Frame = leaderboard:WaitForChild("Part"):WaitForChild("SurfaceGui"):WaitForChild("Frame")

local updateTick: number? = nil

local leaderboardData = {}

local module = {}

local function getUserData(data)
	local username = Players:GetNameFromUserIdAsync(data["key"])
	local avatar =
		Players:GetUserThumbnailAsync(data["key"], Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
	return username, avatar
end

local function updateLeaderboard()
	if updateTick and tick() - updateTick < 60 then
		return
	else
		updateTick = tick()
	end

	for _, v in frame:GetChildren() do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end

	for i, data in leaderboardData do
		task.spawn(function()
			local username, avatar = getUserData(data)
			if not username or not avatar then
				return
			end

			local tempFrame: Frame = leaderboardStorage.Frame:Clone()
			local gradient = leaderboardStorage.UIGradient:Clone()
			gradient.Parent = tempFrame

			tempFrame.LayoutOrder = i
			tempFrame.Rank.Text = i
			tempFrame.Username.Text = username
			tempFrame.Stat.Text = `{Prettify.FormatThousands(data["value"])} KILLS`
			tempFrame.Avatar.Image = avatar
			tempFrame.Parent = frame
		end)
	end
end

local function fetchLeaderboardData()
	Network.fireServer(Network.RemoteEvents.LeaderboardEvent, "fetch")
end

function module.init()
	Network.connectEvent(Network.RemoteEvents.LeaderboardEvent, function(newLeaderboardData)
		leaderboardData = newLeaderboardData
		updateLeaderboard()
	end, Network.t.any)

	fetchLeaderboardData()
end

return module
