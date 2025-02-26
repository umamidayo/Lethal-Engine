--[[
    A lightweight networking module that allows you to handle events without boilerplate or setup.

    Written by @umamidayo
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local FOLDER_NAME = "QuickNetEvents"
local FOLDER_PATH = ReplicatedStorage.LethalEngine

local NetworkFolder: Folder? = nil

local QuickNet = {}

function QuickNet.getSignal(signalName: string, signalType: string)
	if not NetworkFolder then
		NetworkFolder = FOLDER_PATH:WaitForChild(FOLDER_NAME)
	end

	local signal = NetworkFolder:FindFirstChild(signalName)
	if not signal then
		signal = Instance.new(signalType)
		signal.Name = signalName
		signal.Parent = NetworkFolder
	end

	return signal
end

function QuickNet.init()
	if RunService:IsServer() then
		NetworkFolder = Instance.new("Folder")
		NetworkFolder.Name = FOLDER_NAME
		NetworkFolder.Parent = FOLDER_PATH
	else
		NetworkFolder = FOLDER_PATH:WaitForChild(FOLDER_NAME)
	end
end

QuickNet.init()

return QuickNet
