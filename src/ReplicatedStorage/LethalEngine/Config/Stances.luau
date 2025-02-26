local function Angles(pitch: number, yaw: number, roll: number): CFrame
	return CFrame.fromOrientation(math.rad(pitch), math.rad(yaw), math.rad(roll))
end

local Stances = {
	Standing = {
		Joints = {
			RootJoint = CFrame.new(0, 0, 0) * Angles(-90, -180, 0),

			["Left Hip"] = CFrame.new(-0.5, 1, 0) * Angles(0, -90, 0),

			["Left Shoulder"] = CFrame.new(0.5, 0.5, 0) * Angles(0, -90, 0),

			Neck = CFrame.new(0, -0.5, 0) * Angles(-90, -180, 0),

			["Right Hip"] = CFrame.new(0.5, 1, 0) * Angles(0, 90, 0),

			["Right Shoulder"] = CFrame.new(-0.5, 0.5, 0) * Angles(0, 90, 0),
		},
		CameraOffset = Vector3.new(0, 0, 0),
		Walkspeed = 12,
		SprintSpeed = 24,
	},

	Crouching = {
		Joints = {
			RootJoint = CFrame.new(0, 1, 0) * Angles(-80, 0, 180),

			["Left Hip"] = CFrame.new(-0.5, 0, 0.2) * Angles(0, -90, -35),

			["Left Shoulder"] = CFrame.new(0.5, 0.5, 0) * Angles(0, -90, 0),

			Neck = CFrame.new(0, -0.5, 0) * Angles(-90, -180, 0),

			["Right Hip"] = CFrame.new(0.5, 0, 0.2) * Angles(0, 90, 35),

			["Right Shoulder"] = CFrame.new(-0.5, 0.5, 0) * Angles(0, 90, 0),
		},
		CameraOffset = Vector3.new(0, -1, 0),
		Walkspeed = 6,
	},

	Prone = {
		Joints = {
			RootJoint = CFrame.new(0, 0, 2.43) * Angles(0, 0, 180),

			["Left Hip"] = CFrame.new(-0.5, 1, 0) * Angles(0, -90, 0),

			["Left Shoulder"] = CFrame.new(-0.5, 1, 0) * Angles(0, 90, 180),

			Neck = CFrame.new(0, -0.5, 0.3) * Angles(-15, -180, 0),

			["Right Hip"] = CFrame.new(0.5, 1, 0) * Angles(0, 90, 0),

			["Right Shoulder"] = CFrame.new(-0.5, 1, 0) * Angles(0, 90, 180),
		},
		CameraOffset = Vector3.new(0, -3.5, 0),
		Walkspeed = 3,
	},
}

return Stances
