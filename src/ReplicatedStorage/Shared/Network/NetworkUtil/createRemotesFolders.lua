--!strict

--[[
	Creates folders for RemoteFunctions and RemoteEvents used by
	Network. These folders are then populated with new RemoteEvents
	and RemoteFunctions for each name specified in the RemoteNames constants module.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEventName = require(ReplicatedStorage.Shared.Network.RemoteName.RemoteEventName)
local RemoteFunctionName = require(ReplicatedStorage.Shared.Network.RemoteName.RemoteFunctionName)
local UnreliableRemoteEventName = require(ReplicatedStorage.Shared.Network.RemoteName.UnreliableRemoteEventName)
local BindableEventName = require(ReplicatedStorage.Shared.Network.RemoteName.BindableEventName)
local RemoteFolderName = require(ReplicatedStorage.Shared.Network.RemoteFolderName)
local createInstanceTree = require(ReplicatedStorage.Shared.Network.NetworkUtil.createInstanceTree)
local getInstance = require(ReplicatedStorage.Shared.Network.NetworkUtil.getInstance)

type PropertiesTable = { [string]: any }

local function createRemotes(remoteFolder: Folder)
	local remoteEventsFolder: Folder = getInstance(remoteFolder, RemoteFolderName.RemoteEvents)

	for eventName in pairs(RemoteEventName) do
		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = eventName
		remoteEvent.Parent = remoteEventsFolder
	end

	local remoteFunctionsFolder: Folder = getInstance(remoteFolder, RemoteFolderName.RemoteFunctions)

	for functionName in pairs(RemoteFunctionName) do
		local remoteFunction = Instance.new("RemoteFunction")
		remoteFunction.Name = functionName
		remoteFunction.Parent = remoteFunctionsFolder
	end

	local unreliableRemoteEventsFolder: Folder = getInstance(remoteFolder, RemoteFolderName.UnreliableRemoteEvents)

	for eventName in pairs(UnreliableRemoteEventName) do
		local unreliableRemoteEvent = Instance.new("UnreliableRemoteEvent")
		unreliableRemoteEvent.Name = eventName
		unreliableRemoteEvent.Parent = unreliableRemoteEventsFolder
	end

	local bindableEventsFolder: Folder = getInstance(remoteFolder, RemoteFolderName.BindableEvents)

	for eventName in pairs(BindableEventName) do
		local bindableEvent = Instance.new("BindableEvent")
		bindableEvent.Name = eventName
		bindableEvent.Parent = bindableEventsFolder
	end
end

local function createRemotesFolders(rootFolderName: string): Folder
	local folder = createInstanceTree({
		className = "Folder",
		properties = {
			Name = rootFolderName,
		},
		children = {
			{
				className = "Folder",
				properties = {
					Name = RemoteFolderName.RemoteFunctions,
				} :: PropertiesTable,
			},
			{
				className = "Folder",
				properties = {
					Name = RemoteFolderName.RemoteEvents,
				} :: PropertiesTable,
			},
			{
				className = "Folder",
				properties = {
					Name = RemoteFolderName.UnreliableRemoteEvents,
				} :: PropertiesTable,
			},
			{
				className = "Folder",
				properties = {
					Name = RemoteFolderName.BindableEvents,
				} :: PropertiesTable,
			},
		},
	})

	createRemotes(folder)

	return folder
end

return createRemotesFolders
