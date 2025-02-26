local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Common.Network)
local Util = require(ReplicatedStorage.Common.Vehicles.Util)

local module = {}

Util.InstanceTagged("Vehicle", function(taggedInstance)
	local chassis = taggedInstance.Chassis
	local vehicle = chassis.Parent

	local driverSeat = chassis:FindFirstChild("VehicleSeat")

	local driver = Instance.new("ObjectValue")
	driver.Name = "Driver"
	driver.Parent = driverSeat

	-- local target = Instance.new("ObjectValue")
	-- target.Name = "Target"
	-- target.Value = vehicle
	-- target.Parent = client

	driverSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
		local occupant = driverSeat.Occupant
		if occupant then
			module.driverJoined(occupant, driver, driverSeat)
			local player = Players:GetPlayerFromCharacter(occupant.Parent)
			assert(player, "Player not found")
			Network.fireAllClients(Network.RemoteEvents.VehicleEvent, player, "enter", vehicle)
			return
		end
		module.driverLeft(driverSeat, driver)
		Network.fireAllClients(Network.RemoteEvents.VehicleEvent, "exit", vehicle)
	end)

	-- module.updateWheelPhysicalProperties(chassis)
end)

function module.driverLeft(driverSeat, driver)
	driverSeat:SetNetworkOwner(nil)
	driverSeat:SetNetworkOwnershipAuto()

	local player = driver.Value
	if not player then
		return
	end

	driver.Value = nil
end

function module.driverJoined(occupant, driver, driverSeat)
	local character = occupant.Parent
	if not character then
		return
	end

	local player = Players:FindFirstChild(character.Name)
	if not player then
		return
	end

	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end

	driverSeat:SetNetworkOwner(player)
	driver.Value = player
end

function module.updateWheelPhysicalProperties(chassis)
	local properties = {
		density = 0.7, -- Wheel weight
		friction = 0.3, -- Higher values = less drifting/sliding, Lower values = more drifting/sliding
		elasticity = 0.5, -- 0.5
		frictionWeight = 1, -- 1
		elasticityWeight = 1, -- 1
	}

	for _, name in pairs({ "FL", "FR", "RL", "RR" }) do
		chassis.Wheels:FindFirstChild(name).CustomPhysicalProperties = PhysicalProperties.new(
			properties.density,
			properties.friction,
			properties.elasticity,
			properties.frictionWeight,
			properties.elasticityWeight
		)
	end
end

Network.connectEvent(Network.RemoteEvents.VehicleEvent, function(player: Player, action: string, ...)
	if action == "brake" then
		Network.fireAllClients(Network.RemoteEvents.VehicleEvent, "brake", ...)
	elseif action == "neutralbrake" then
		Network.fireAllClients(Network.RemoteEvents.VehicleEvent, "neutralbrake", ...)
	elseif action == "reverse" then
		Network.fireAllClients(Network.RemoteEvents.VehicleEvent, "reverse", ...)
	elseif action == "reverseOff" then
		Network.fireAllClients(Network.RemoteEvents.VehicleEvent, "reverseOff", ...)
	end
end, Network.t.instanceOf("Player"), Network.t.string, Network.t.any)

return module
