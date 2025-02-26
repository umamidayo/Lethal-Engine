local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local SentryPrefabs = ReplicatedStorage:WaitForChild("Entities"):WaitForChild("Wiremod"):WaitForChild("Sentry")
local SentrySounds = SoundService:WaitForChild("Wiremod"):WaitForChild("Sentry")
local Network = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Network"))

local Camera = workspace.CurrentCamera

local module = {}

local function HitEffect(Target: Model)
	local HitParts = { "Torso", "Head" }
	local HitPart = Target:FindFirstChild(HitParts[math.random(1, #HitParts)])
	if not HitPart then
		return
	end

	local Position = HitPart.Position
	local Normal = HitPart.CFrame.LookVector
	local Attachment = Instance.new("Attachment", workspace.Terrain)
	Attachment.CFrame = CFrame.new(Position, Position + Normal)

	local Particles = Instance.new("ParticleEmitter")
	Particles.Enabled = false
	Particles.Color = ColorSequence.new(Color3.fromRGB(144, 41, 41))
	Particles.LightEmission = 0
	Particles.LightInfluence = 1
	Particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5, 0),
		NumberSequenceKeypoint.new(1, 2),
	})
	Particles.Texture = "rbxassetid://11561421303"
	Particles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	Particles.Acceleration = Vector3.new(0, -20, 0)
	Particles.Lifetime = NumberRange.new(0.2, 0.5)
	Particles.Rate = 1000
	Particles.Drag = 0
	Particles.Rotation = NumberRange.new(-360, 360)
	Particles.RotSpeed = NumberRange.new(-40, 40)
	Particles.Speed = NumberRange.new(-15, 15)
	Particles.VelocitySpread = math.random(15, 25)
	Particles.SpreadAngle = Vector2.new(-25, 25)
	Particles.LockedToPart = true
	Particles.Parent = Attachment
	Particles.EmissionDirection = "Front"
	Particles:Emit(10)
	Debris:AddItem(Attachment, Particles.Lifetime.Max)
end

local function CalculateBulletSpread()
	return CFrame.Angles(
		math.rad(Random.new():NextNumber(-1, 1)),
		math.rad(Random.new():NextNumber(-1, 1)),
		math.rad(Random.new():NextNumber(-1, 1))
	)
end

local function RotateSentryHead(Sentry: Model, Target: Model)
	local TargetHead = Target:FindFirstChild("Head")
	local SentryHead = Sentry:FindFirstChild("Barrel")
	local SentryBearing = Sentry:FindFirstChild("Bearing")
	if not TargetHead or not SentryHead or not SentryBearing then
		return
	end

	local aimDirection = (TargetHead.Position - SentryHead.Position).Unit
	aimDirection = aimDirection.Y <= 0.3 and aimDirection.Y >= -0.3 and aimDirection
		or Vector3.new(aimDirection.X, math.clamp(aimDirection.Y, -0.3, 0.3), aimDirection.Z)
	TweenService:Create(SentryBearing, TweenInfo.new(0.2), {
		CFrame = CFrame.lookAt(SentryBearing.Position, SentryBearing.Position + aimDirection)
			* CFrame.Angles(0, math.rad(-180), 0),
	}):Play()
end

local function PlayShootSound(Sentry: Model)
	if (Sentry.WorldPivot.Position - Camera.CFrame.Position).Magnitude > 35 then
		local EchoSound: Sound = SentrySounds.Echo:Clone()
		EchoSound.Parent = Sentry.Barrel
		EchoSound:Play()
		Debris:AddItem(EchoSound, 1)
	end

	local FireSound: Sound = SentrySounds.Fire:Clone()
	FireSound.Parent = Sentry.Barrel
	FireSound:Play()
	Debris:AddItem(FireSound, 1)
end

--[[
    Creates the bullet with imitation physics (delay functions), decoration only
]]
local function CreateBullet(Sentry: Model)
	local SentryHead: BasePart = Sentry:FindFirstChild("Barrel")
	local Muzzle: Attachment = Sentry:FindFirstChild("Muzzle", true)
	if not SentryHead or not Muzzle then
		return
	end

	local bullet = SentryPrefabs.Bullet:Clone()
	local bulletForce = Vector3.new(0, bullet:GetMass() * workspace.Gravity - 0.1, 0)
	local bodyForce = Instance.new("BodyForce")
	local BulletSpread = CalculateBulletSpread()
	local direction = BulletSpread * Muzzle.WorldCFrame.LookVector

	local FlashFX: PointLight = Sentry.Barrel.Flash
	FlashFX.Enabled = true
	task.delay(0.05, function()
		FlashFX.Enabled = false
	end)

	local BulletFlareBillboard = Instance.new("BillboardGui")
	BulletFlareBillboard.Enabled = false
	BulletFlareBillboard.Adornee = bullet
	BulletFlareBillboard.Size = UDim2.new(20, 0, 20, 0)
	BulletFlareBillboard.LightInfluence = 0
	local BulletFlare = Instance.new("ImageLabel", BulletFlareBillboard)
	BulletFlare.BackgroundTransparency = 1
	BulletFlare.Size = UDim2.new(1, 0, 1, 0)
	BulletFlare.Position = UDim2.new(0, 0, 0, 0)
	BulletFlare.Image = "http://www.roblox.com/asset/?id=1047066405"
	BulletFlare.ImageTransparency = 0.5
	BulletFlare.ImageColor3 = Color3.fromRGB(255, 240, 126)
	BulletFlareBillboard.Parent = bullet
	task.delay(0.1, function()
		BulletFlareBillboard.Enabled = true
	end)

	bullet.Parent = workspace.Terrain
	bullet.CFrame = Muzzle.WorldCFrame
	bullet:ApplyImpulse(direction * 4)
	bodyForce.Parent = bullet
	Debris:AddItem(bullet, 3)
	task.delay(0.3, function()
		TweenService:Create(bullet, TweenInfo.new(1), {
			AssemblyLinearVelocity = direction * 150,
		}):Play()
		bodyForce.Force = bulletForce
	end)
end

function module.init()
	Network.connectEvent(
		Network.RemoteEvents.SentryEvent,
		function(EventType: string, ScheduledShots: { Sentry: {}, Target: Model })
			if EventType == "Shoot" then
				for _, Sentry in ScheduledShots do
					task.spawn(function()
						RotateSentryHead(Sentry.Model, Sentry.Target)
						task.wait(Random.new():NextNumber(0.05, 0.2))
						PlayShootSound(Sentry.Model)
						CreateBullet(Sentry.Model)
						HitEffect(Sentry.Target)
					end)
				end
			end
		end,
		Network.t.string,
		Network.t.table
	)
end

return module
