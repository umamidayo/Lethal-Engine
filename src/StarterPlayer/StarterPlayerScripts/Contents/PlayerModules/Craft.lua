local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SelectTween = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
local Entities: Folder = ReplicatedStorage:WaitForChild("Entities")
local ResourceHighlight: Highlight = Entities:WaitForChild("Highlights"):WaitForChild("ResourceHighlight")
local RemotesLegacy: Folder = ReplicatedStorage:WaitForChild("RemotesLegacy")
local LocalPlayer = game.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function isResource(part: BasePart)
	if part.Parent == nil then return end
	if part.Parent == workspace.Resources then return part end
	
	local model = part
	local timeout = tick()

	repeat
		task.wait()
		model = model.Parent
		if model == nil then return end
	until model:FindFirstAncestorWhichIsA("Folder") or model:FindFirstAncestorWhichIsA("Workspace") or tick() - timeout > 0.1

	if model.Parent ~= workspace.Resources then return end

	return model
end

local function onMouseMove()
	if Mouse.Target and LocalPlayer:DistanceFromCharacter(Mouse.Target.Position) < 10 then
		local topParent = isResource(Mouse.Target)
		
		if topParent then
			TweenService:Create(ResourceHighlight, SelectTween, {OutlineTransparency = 0}):Play()
			ResourceHighlight.Adornee = topParent
		end
	else
		TweenService:Create(ResourceHighlight, SelectTween, {OutlineTransparency = 1}):Play()
		ResourceHighlight.Adornee = nil
	end
end

local function onClick()
	if Mouse.Target and LocalPlayer:DistanceFromCharacter(Mouse.Target.Position) < 10 then
		if isResource(Mouse.Target) then
			RemotesLegacy.CraftEvent:FireServer({"Pickup", Mouse.Target})
		end
	end
end

function module.init()
    Mouse.Move:Connect(onMouseMove)
    Mouse.Button1Down:Connect(onClick)
end

return module
