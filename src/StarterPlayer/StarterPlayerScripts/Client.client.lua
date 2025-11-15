local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"))
Network.startClientAsync()

local player = Players.LocalPlayer
local PlayerScripts = player:WaitForChild("PlayerScripts")

local directories = {
	PlayerScripts:WaitForChild("Systems"),
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Systems"),
}

local playerModules = {}
-- Requires all modules in a directory
local function setup(directory, container: {})
	for _, moduleScript in pairs(directory:GetDescendants()) do
		if moduleScript:IsA("ModuleScript") then
			local success, result = pcall(function()
				container[moduleScript.Name] = require(moduleScript)
			end)

			if not success then
				warn(`Failed to require module {moduleScript.Name} from {directory.Name}: {result}`)
				continue
			end
		end
	end
end

-- Calls .init() for modules that haven't been initialized yet
local function initialize(container: {})
	for _, module in pairs(container) do
		if typeof(module) == "table" and (module.init and not module.__initialized) then
			local success, result = pcall(function()
				task.spawn(module.init)
				module.__initialized = true
			end)

			if not success then
				warn(`Failed to initialize module {module.Name}: {result}`)
				continue
			end
		elseif module.__initialized then
			warn(`Module {module.Name} is already initialized`)
			continue
		end
	end
end

-- Requires, sorts, and initializes the directories of modules
local function loadModules(moduleDirectories, container: {})
	for _, directory in pairs(moduleDirectories) do
		setup(directory, container)
	end

	table.sort(container, function(module1, module2)
		return (module1.priority or 10) < (module2.priority or 10)
	end)

	initialize(container)
end

loadModules(directories, playerModules)
