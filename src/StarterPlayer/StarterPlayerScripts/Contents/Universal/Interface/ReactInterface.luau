local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Common.Network)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Store = require(ReplicatedStorage.Common.Store)

local Components = ReplicatedStorage.Components

local element = React.createElement

local directories = {
	Components:WaitForChild("Game"),
	Components:WaitForChild("Universal"),
}

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local interface = Instance.new("ScreenGui")
interface.Name = "ReactInterface"
interface.ResetOnSpawn = false
interface.IgnoreGuiInset = true
interface.Parent = PlayerGui

local root = ReactRoblox.createRoot(interface)

local ReactInterface = {}

function ReactInterface.init()
	local state = Store:getState() or {}
	local components = {}
	for _, directory in directories do
		local modules = directory:GetChildren()
		if #modules == 0 then
			continue
		end

		for _, module in modules do
			if module:IsA("ModuleScript") then
				local component = require(module)
				table.insert(
					components,
					element(component, {
						state = state,
					})
				)
			end
		end
	end

	root:render(element(React.Fragment, {}, components))
end

Network.connectBindableEvent(Network.BindableEvents.StoreClientUpdate, function()
	ReactInterface.init()
end, Network.t.none)

return ReactInterface
