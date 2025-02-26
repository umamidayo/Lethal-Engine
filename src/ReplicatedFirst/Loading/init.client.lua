local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Client = script.Client:Clone()

if RunService:IsStudio() then
	Client.Parent = Player.PlayerScripts
	Client.Disabled = false
	return
end

repeat
	task.wait(0.1)
until game:IsLoaded()
local Assets = {
	unpack(SoundService:GetDescendants()),
	unpack(ReplicatedStorage.Entities:GetDescendants()),
}

local assetsToPreload = {}
for _, asset in pairs(Assets) do
	if asset:IsA("Sound") or asset:IsA("Decal") or asset:IsA("Texture") then
		table.insert(assetsToPreload, asset)
	end
end

local LoadingGui = script.LoadingGui:Clone()
LoadingGui.Parent = PlayerGui

local Body = LoadingGui.Body
local Title = Body.Contents.Title
local LoadBar = LoadingGui.Body.Contents.LoadBar
local LoadBarStroke = LoadBar.UIStroke
local LoadFill = LoadBar.LoadFill
local LoadText = Body.Contents.LoadText
LoadFill.Size = UDim2.new(0, 0, 1, 0)

local LoadCompleteTexts = {
	"LOCKED & LOADED",
	"GOOD TO GO",
	"OPERATIONAL CHECK GOOD",
	"KILL THEM ALL",
	"STANDBY FOR DEPLOYMENT",
	"YOU ARE OSCAR MIKE",
}

local function FadeLoadingGui()
	local FadeTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	LoadText.Text = LoadCompleteTexts[math.random(1, #LoadCompleteTexts)]
	TweenService:Create(LoadText, FadeTweenInfo, { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	task.wait(1)

	TweenService:Create(LoadText, FadeTweenInfo, { TextTransparency = 1 }):Play()
	TweenService:Create(LoadFill, FadeTweenInfo, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(LoadBarStroke, FadeTweenInfo, { Transparency = 1 }):Play()
	TweenService:Create(LoadText, FadeTweenInfo, { TextTransparency = 1 }):Play()
	task.wait(1)
	TweenService:Create(Body, FadeTweenInfo, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(Title, FadeTweenInfo, { TextTransparency = 1 }):Play()
end

local function UpdateUI(i)
	LoadFill.Size = UDim2.fromScale(i / #assetsToPreload, 1)
	LoadText.Text = "LOADING " .. i .. " OUT OF " .. #assetsToPreload .. " IMPORTANT ASSETS"
end

local function LoadAssets()
	for i = 1, #assetsToPreload do
		local asset = assetsToPreload[i]
		ContentProvider:PreloadAsync({ asset }, function()
			UpdateUI(i)
		end)
	end
end

SoundService.Loading:Play()
LoadAssets()
SoundService.Loading:Stop()
SoundService:PlayLocalSound(SoundService.LoadComplete)
FadeLoadingGui()
Debris:AddItem(LoadingGui, 1)
Client.Parent = Player.PlayerScripts
Client.Disabled = false
