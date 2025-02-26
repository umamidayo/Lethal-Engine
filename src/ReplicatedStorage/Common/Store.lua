local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Network = require(ReplicatedStorage.Common.Network)
local Rodux = require(ReplicatedStorage.Packages.Rodux)

local Reducers: Folder = ReplicatedStorage.Common.Reducers

local reducers = {}
for _, reducer in Reducers:GetChildren() do
	if reducer:IsA("ModuleScript") then
		reducers[reducer.Name] = require(reducer)
	end
end

local rootReducer = Rodux.combineReducers(reducers)

local initialStates = {}
for reducerName, _ in reducers do
	initialStates[reducerName] = {}
end

local function simpleLogger(nextDispatch, store)
	if not RunService:IsStudio() then
		return nextDispatch
	end

	return function(action)
		print(`Dispatched {action.type}:`, action)

		return nextDispatch(action)
	end
end

local function replicationMiddleware(nextDispatch, store)
	if RunService:IsClient() then
		return nextDispatch
	end

	return function(action)
		Network.fireAllClients(Network.RemoteEvents.StoreUpdate, action)
		return nextDispatch(action)
	end
end

local function clientUpdateMiddleware(nextDispatch, store)
	if not RunService:IsClient() then
		return nextDispatch
	end

	return function(action)
		local result = nextDispatch(action)
		Network.fireBindableEvent(Network.BindableEvents.StoreClientUpdate)
		return result
	end
end

return Rodux.Store.new(rootReducer, initialStates, {
	replicationMiddleware,
	clientUpdateMiddleware,
	RunService:IsStudio() and Rodux.loggerMiddleware or nil,
})
