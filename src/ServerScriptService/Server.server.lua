local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Shared.Network)

local directories = {
	ServerScriptService.Systems,
	ReplicatedStorage.Shared.Systems,
}

local modules = {}

local function setup(directory)
	for _, module in directory:GetDescendants() do
		if module:IsA("ModuleScript") then
			modules[module.Name] = require(module)
		end
	end
end

local function initialize()
	for _, directory in directories do
		setup(directory)
	end

	table.sort(modules, function(module1, module2)
		return (module1.priority or 10) < (module2.priority or 10)
	end)

	for _, module in modules do
		if typeof(module) == "table" and module.init then
			task.spawn(module.init)
		end
	end
end

Network.startServer()
initialize()
