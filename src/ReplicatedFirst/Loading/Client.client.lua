--disable
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Network"))
Network.startClientAsync()

local player = Players.LocalPlayer
local PlayerScripts = script.Parent

local directories = {
	PlayerScripts:WaitForChild("Contents"):WaitForChild("Game"),
	PlayerScripts:WaitForChild("Contents"):WaitForChild("Universal"),
	ReplicatedStorage:WaitForChild("Common"):WaitForChild("Shared"):WaitForChild("Universal"),
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

-- Loads character modules when character is added
local function onCharacterAdded()
	local character = player.Character or player.CharacterAdded:Wait()

	-- Wait a short time to ensure character is fully loaded
	task.wait(0.2)

	-- Clean up any existing character modules
	if character:FindFirstChild("CharacterModules") then
		character.CharacterModules:Destroy()
	end

	local contents = ReplicatedStorage:WaitForChild("Client"):WaitForChild("CharacterModules"):Clone()
	contents.Parent = character

	local characterDirectories = {
		contents:WaitForChild("Game", 5),
		contents:WaitForChild("Universal", 5),
	}
	local characterModules = {}

	if next(characterDirectories) == nil then
		warn("Failed to retrieve character directories, retrying...")
		task.delay(1, onCharacterAdded)
		return
	end

	for _, directory in pairs(characterDirectories) do
		setup(directory, characterModules)
	end

	table.sort(characterModules, function(module1, module2)
		return (module1.priority or 10) < (module2.priority or 10)
	end)

	for _, module in pairs(characterModules) do
		if typeof(module) == "table" and module.init then
			local success, result = pcall(function()
				task.spawn(module.init)
			end)

			if not success then
				warn(`Failed to initialize module {module.Name}: {result}`)
				continue
			end
		end
	end
end

loadModules(directories, playerModules)

if player.Character then
	onCharacterAdded()
end

player.CharacterAdded:Connect(onCharacterAdded)
