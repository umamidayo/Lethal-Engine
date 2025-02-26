local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("RemotesLegacy")
local Jobs_Event = Remotes.Jobs

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui: ScreenGui = playerGui:WaitForChild("JournalGui")
local main: Frame = gui:WaitForChild("Main")
local container: Frame = main:WaitForChild("Container")
local header: Frame = main:WaitForChild("Header")
local tabs: Frame = header:WaitForChild("Tabs")

local function hidePagesExcept(frame: GuiObject)
	frame.Visible = true

	for _,page: GuiObject in container:GetChildren() do
		if not (page:IsA("Frame") or page:IsA("ScrollingFrame")) then continue end
		if page.Name == frame.Name then continue end
		page.Visible = false
	end
end

for i,tab: TextButton in tabs:GetChildren() do
	if not tab:IsA("TextButton") then continue end
    
    tab.MouseEnter:Connect(function()
        tab.TextTransparency = 0.5
    end)

    tab.MouseLeave:Connect(function()
        tab.TextTransparency = 0
    end)

	tab.MouseButton1Click:Connect(function()
		hidePagesExcept(container[tab.Name])
	end)
end

-- Jobs / Tasks

type Job = {
    Name: string,
    Description: string,
    Type: string,
    Item: string,
    CashReward: number
}

local playerJobs: {Job} = {}
local taskSample: Frame = ReplicatedStorage:WaitForChild("UI"):WaitForChild("JournalTask")
local taskFrames: {Frame} = {}
local backpackConnection: RBXScriptConnection

function module.init()
    Jobs_Event.OnClientEvent:Connect(function(jobs: {Job})
        playerJobs = jobs

        for i,_ in ipairs(playerJobs) do
            local frame = taskSample:Clone()
            frame.Heading.Text = playerJobs[i].Name .. " ($" .. playerJobs[i].CashReward .. ")"
            frame.Paragraph.Text = playerJobs[i].Description
            frame.Parent = container.Tasks
            table.insert(taskFrames, frame)
        end
    end)

    player.CharacterAdded:Connect(function()
        if backpackConnection then backpackConnection:Disconnect() end
        backpackConnection = player.Backpack.ChildAdded:Connect(function(child)
            for i,job in ipairs(playerJobs) do
                if job.Type ~= "Item" then continue end
                if child.Name ~= job.Item then continue end
                Jobs_Event:FireServer(job.Name)
                taskFrames[i].Visible = false
            end
        end)
    end)

    backpackConnection = player.Backpack.ChildAdded:Connect(function(child)
        for i,job in ipairs(playerJobs) do
            if job.Type ~= "Item" then continue end
            if child.Name ~= job.Item then continue end
            Jobs_Event:FireServer(job.Name)
            taskFrames[i].Visible = false
        end
    end)
end

return module
