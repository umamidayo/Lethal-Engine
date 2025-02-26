local RunService = game:GetService("RunService")

local Scheduler = {
	priority = 1,
}
Scheduler.__index = Scheduler

local Schedulers = {}
local Renderers = {}

--[[
    Creates a new scheduler
]]
function Scheduler.newScheduler(name: string, tick: number)
	if table.find(Schedulers, name) then
		return table.find(Schedulers, name)
	end

	local scheduler = {
		Name = name,
		Tick = tick,
		Elapsed = 0,
		Tasks = {},
	}
	table.insert(Schedulers, scheduler)
	return setmetatable(scheduler, Scheduler)
end

--[[
    Waits for a scheduler to exist
]]
function Scheduler.WaitForScheduler(name: string, timeout: number)
	local startTick = tick()
	local getScheduler
	repeat
		task.wait()
		for _, scheduler in Schedulers do
			if scheduler.Name == name then
				getScheduler = scheduler
				break
			end
		end
	until getScheduler or tick() - startTick >= timeout

	return getScheduler
end

--[[
    Adds a task to a scheduler
]]
function Scheduler.AddToScheduler(schedulerName: string, taskRef: any, callback: (number) -> nil)
	local scheduler = Scheduler.WaitForScheduler(schedulerName, 3)
	if not scheduler then
		warn(script.Name .. " - '" .. schedulerName .. "' schedule does not exist")
		return
	else
		scheduler.Tasks[taskRef] = callback
	end
end

--[[
    Removes a task from a scheduler
]]
function Scheduler.RemoveFromScheduler(name: string, taskRef: any)
	local scheduler = Scheduler.WaitForScheduler(name, 3)
	if not scheduler then
		warn(script.Name .. " - '" .. name .. "' schedule does not exist")
		return
	else
		if not scheduler.Tasks[taskRef] then
			return
		end
		scheduler.Tasks[taskRef] = nil
	end
end

--[[
    Creates a new renderer
]]
function Scheduler.newRenderer(name: string)
	if table.find(Renderers, name) then
		return table.find(Renderers, name)
	end

	local renderer = {
		Name = name,
		Tasks = {},
	}
	table.insert(Renderers, renderer)
	return setmetatable(renderer, Scheduler)
end

--[[
    Waits for a renderer to exist
]]
function Scheduler.WaitForRenderer(name: string, timeout: number)
	local startTick = tick()
	local getRenderer
	repeat
		task.wait()
		for _, renderer in Renderers do
			if renderer.Name == name then
				getRenderer = renderer
				break
			end
		end
	until getRenderer or tick() - startTick >= timeout

	return getRenderer
end

--[[
    Adds a task to a renderer
]]
function Scheduler.AddToRenderer(name: string, taskRef: any, callback: (number) -> nil)
	local renderer = Scheduler.WaitForRenderer(name, 3)
	if not renderer then
		warn(script.Name .. " - '" .. name .. "' schedule does not exist")
		return
	else
		renderer.Tasks[taskRef] = callback
	end
end

--[[
    Removes a task from a renderer
]]
function Scheduler.RemoveFromRenderer(name: string, taskRef: any)
	local renderer = Scheduler.WaitForRenderer(name, 3)
	if not renderer then
		warn(script.Name .. " - '" .. name .. "' schedule does not exist")
		return
	else
		if not renderer.Tasks[taskRef] then
			return
		end
		renderer.Tasks[taskRef] = nil
	end
end

--[[
    Cleans up the scheduler or renderer from the Schedulers or Renderers table
]]
function Scheduler:Destroy()
	local index = table.find(Schedulers, self)
	if index then
		table.remove(Schedulers, index)
	end

	index = table.find(Renderers, self)
	if index then
		table.remove(Renderers, index)
	end

	setmetatable(self, nil)
end

if RunService:IsClient() then
	Scheduler.newRenderer("Render")
end

Scheduler.newScheduler("Interval_10s", 10)
Scheduler.newScheduler("Interval_1s", 1)
Scheduler.newScheduler("Interval_0.2", 0.2)
Scheduler.newScheduler("Interval_5", 5)
Scheduler.newScheduler("Interval_0.5", 0.5)
Scheduler.newScheduler("Interval_0.05", 0.05)
Scheduler.newScheduler("Interval_0.1", 0.1)

RunService.Heartbeat:Connect(function(dt)
	for _, scheduler in Schedulers do
		task.spawn(function()
			scheduler.Elapsed += dt
			if scheduler.Elapsed < scheduler.Tick then
				return
			end
			scheduler.Elapsed = 0

			for _, schedTask in scheduler.Tasks do
				task.spawn(function()
					schedTask(dt)
				end)
			end
		end)
	end
end)

if RunService:IsClient() then
	RunService.RenderStepped:Connect(function(dt)
		for _, renderer in Renderers do
			task.spawn(function()
				for _, schedTask in renderer.Tasks do
					task.spawn(function()
						schedTask(dt)
					end)
				end
			end)
		end
	end)
end

return Scheduler
