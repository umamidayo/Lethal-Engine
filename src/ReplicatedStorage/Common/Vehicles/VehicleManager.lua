type VehicleParams = {
	bodyGyro: BodyGyro,
	driver: Player,
	driverSeat: VehicleSeat,
	headLights: { SpotLight },
	passengerSeats: { Seat | VehicleSeat },
	platform: BasePart,
	stats: { any },
	tailLights: { PointLight },
	vehicle: Model,
}

local vehicles: { VehicleParams } = {}

local VehicleManager = {}

function VehicleManager.flip(vehicleParams: VehicleParams)
	vehicleParams.bodyGyro.Parent = vehicleParams.platform
	task.delay(2, function()
		vehicleParams.bodyGyro.Parent = nil
	end)
end

function VehicleManager.getVehicleParams(vehicle: Model): VehicleParams
	for _, vehicleParams in vehicles do
		if vehicleParams.vehicle == vehicle then
			return vehicleParams
		end
	end
end

function VehicleManager.getVehicleParamsFromDriver(driver: Player): VehicleParams
	for _, vehicleParams in vehicles do
		if vehicleParams.driver == driver then
			return vehicleParams
		end
	end
end

function VehicleManager.setVehicleParams(vehicle: Model): VehicleParams
	local platform: BasePart = vehicle:FindFirstChild("Platform", true)
	assert(platform, `{script.Name}: No platform found`)

	local vehicleParams = {
		bodyGyro = Instance.new("BodyGyro"),
		driverSeat = vehicle.Chassis:FindFirstChild("VehicleSeat", true),
		passengerSeats = {},
		platform = platform,
		headLights = {},
		stats = {},
		tailLights = {},
		vehicle = vehicle,
	} :: VehicleParams

	for _, seat in vehicle.Chassis:GetDescendants() do
		if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
			table.insert(vehicleParams.passengerSeats, seat)
		end
	end

	vehicleParams.bodyGyro.D = 500
	vehicleParams.bodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
	vehicleParams.bodyGyro.P = 2500
	vehicleParams.bodyGyro.CFrame = platform.CFrame

	local lights = vehicleParams.vehicle.Chassis:FindFirstChild("Lights", true)

	if lights then
		for _, light in lights:GetDescendants() do
			if light:IsA("SpotLight") then
				table.insert(vehicleParams.headLights, light)
			elseif light:IsA("PointLight") then
				table.insert(vehicleParams.tailLights, light)
			end
		end
	end

	table.insert(vehicles, vehicleParams)

	return vehicleParams
end

function VehicleManager.setVehicleDriver(vehicle: Model, driver: Player): VehicleParams
	for _, vehicleParams in vehicles do
		if vehicleParams.driver == driver and vehicleParams.vehicle ~= vehicle then
			vehicleParams.driver = nil
		end
	end

	local vehicleParams = VehicleManager.getVehicleParams(vehicle)
	vehicleParams.driver = driver

	return vehicleParams
end

function VehicleManager.teleport(vehicleParams: VehicleParams)
	vehicleParams.driverSeat:Sit(vehicleParams.driver.Character.Humanoid)
end

return VehicleManager
