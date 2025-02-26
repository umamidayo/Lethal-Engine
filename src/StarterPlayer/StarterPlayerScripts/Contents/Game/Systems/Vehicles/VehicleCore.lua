local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MotorVehicle = require(ReplicatedStorage.Common.Vehicles.MotorVehicle)
local MvTypes = require(ReplicatedStorage.Common.Vehicles.MotorVehicle)
local Maid = require(ReplicatedStorage.Common.Libraries.Maid)
local Network = require(ReplicatedStorage.Common.Network)
local VehicleManager = require(ReplicatedStorage.Common.Vehicles.VehicleManager)
local VehicleStats = require(ReplicatedStorage.Common.Vehicles.VehicleStats)
local Util = require(ReplicatedStorage.Common.Vehicles.Util)

local module = {}

local _vehicleMaids = {}

local LocalPlayer = Players.LocalPlayer

Util.InstanceTagged("Vehicle", function(taggedInstance)
	local chassis = taggedInstance:WaitForChild("Chassis")
	local vehicle = chassis.Parent
	local platform = chassis:WaitForChild("Platform")

	local cylinders = Util.getNamedChildren(platform.Cylinders)
	local attachments = Util.getNamedChildren(platform :: Instance)

	local driverSeat = chassis:FindFirstChild("VehicleSeat")

	local config = require((vehicle :: any).Config :: any)

	_vehicleMaids[taggedInstance] = Maid.new()
	local maid = _vehicleMaids[taggedInstance]

	local bus = MotorVehicle.new({
		root = driverSeat,
		wheels = { chassis.Wheels.RL, chassis.Wheels.RR },
		torque = config.torque,
		maxSteerAngle = config.maxSteerAngle,
		turnSpeed = config.turnSpeed,
		gearRatio = config.gearRatio,
		maxAngularAcceleration = config.maxAngularAcceleration,
	})

	local vehicleParams = VehicleManager.setVehicleParams(vehicle)

	driverSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if driverSeat.Occupant then
			local driver = Players:GetPlayerFromCharacter(driverSeat.Occupant.Parent)
			if driver and driver == LocalPlayer then
				vehicleParams = VehicleManager.setVehicleDriver(vehicle, driver)
				vehicleParams.stats = VehicleStats.new(LocalPlayer.PlayerGui.Vehicle)
				vehicleParams.platform.Engine.Rev:Play()

				maid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime)
					local clockStart = os.clock()

					if not driverSeat.Occupant then
						if chassis and chassis:FindFirstChild("Platform") then
							chassis.Platform.Engine.Rev:Stop()
						end
						vehicleParams.stats:destroy()
						maid:DoCleaning()
					end

					local steerFloat = driverSeat.SteerFloat
					local throttleFloat = driverSeat.ThrottleFloat

					local output = bus:compute(deltaTime, {
						steerFloat = -steerFloat,
						throttleFloat = throttleFloat,
					})

					attachments.FL.Orientation = Vector3.new(0, output.angle, 90)
					attachments.FR.Orientation = Vector3.new(0, output.angle + 180, 90)

					cylinders.FL.AngularVelocity = output.angularVelocity
					cylinders.FR.AngularVelocity = -output.angularVelocity
					cylinders.RL.AngularVelocity = output.angularVelocity
					cylinders.RR.AngularVelocity = -output.angularVelocity

					for _, cylinder: CylindricalConstraint in cylinders do
						cylinder.MotorMaxAngularAcceleration = output.motorMaxAngularAcceleration
						cylinder.MotorMaxTorque = output.motorMaxTorque
					end

					chassis.Platform.Engine.Rev.PlaybackSpeed = bus:getRevPlaybackSpeed()
						+ config.revPlaybackSpeedOffset

					local clockEnd = os.clock()

					vehicleParams.stats:compute({
						chassisInst = bus,
						vehicle = vehicle,
						clockStart = clockStart,
						clockEnd = clockEnd,
						deltaTime = deltaTime,
						steerFloat = steerFloat,
						throttleFloat = throttleFloat,
						output = output :: MvTypes.ComputeResult,
					})
				end))
			end
		end
	end)
end)

Network.connectEvent(Network.RemoteEvents.VehicleEvent, function(action, ...)
	if action == "enter" then
		local data = { ... }
		local player = data[1]
		local vehicle = data[2]
		local vehicleParams = VehicleManager.getVehicleParams(vehicle)

		if vehicleParams then
			vehicle.Chassis.Platform.Engine.Rev:Play()
		end
	elseif action == "exit" then
		local vehicle = ...
		local vehicleParams = VehicleManager.getVehicleParams(vehicle)

		if vehicleParams then
			vehicle.Chassis.Platform.Engine.Rev:Stop()
		end
	elseif action == "brake" then
		local tailLight: SpotLight = ...
		tailLight.Brightness = 2
		tailLight.Range = 20
		tailLight.Enabled = true
	elseif action == "neutralbrake" then
		local tailLight: SpotLight = ...
		tailLight.Brightness = 1
		tailLight.Range = 16
		tailLight.Enabled = true
	elseif action == "reverse" then
		local reverseLight: SpotLight = ...
		reverseLight.Enabled = true
	elseif action == "reverseOff" then
		local reverseLight: SpotLight = ...
		reverseLight.Enabled = false
	end
end, Network.t.any, Network.t.any)

return module
