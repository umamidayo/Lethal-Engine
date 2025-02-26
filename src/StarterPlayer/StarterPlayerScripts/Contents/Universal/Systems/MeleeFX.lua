local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Network = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Network"))
local WeaponSounds = SoundService:WaitForChild("Weapons")

local module = {}

local function playSound(sound: Sound, parent: Instance)
    local soundClone = sound:Clone()
    soundClone.PlaybackSpeed = Random.new():NextNumber(soundClone.PlaybackSpeed - 0.1, soundClone.PlaybackSpeed + 0.1)
    soundClone.Parent = parent
    soundClone:Play()
    Debris:AddItem(soundClone, 2)
end

local function emitTrail(tool: Tool)
    local trail = tool.Hitbox:FindFirstChild("Trail")
    if not trail then return end

    trail.Enabled = true
    task.delay(0.3, function()
        trail.Enabled = false
    end)
end

local function HitEffect(Hit: BasePart)
    if not Hit then return end

    local Position = Hit.Position
    local Normal = Hit.CFrame.LookVector
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
    Particles.Rotation = NumberRange.new(-360,360)
    Particles.RotSpeed = NumberRange.new(-40, 40)
    Particles.Speed = NumberRange.new(-15, 15)
    Particles.VelocitySpread = math.random(15, 25)
    Particles.SpreadAngle = Vector2.new(-25, 25)
    Particles.LockedToPart = true
    Particles.Parent = Attachment
    Particles.EmissionDirection = "Front"
    Particles:Emit(30)
    Debris:AddItem(Attachment, Particles.Lifetime.Max)
end

local function onHit(tool: Tool, hit: BasePart)
    local toolSounds = WeaponSounds:FindFirstChild(tool.Name)
    if not toolSounds then return end

    playSound(toolSounds.Hits.Flesh, hit)
    HitEffect(tool.Handle)
end

local function onSwing(tool: Tool)
    local toolSounds = WeaponSounds:FindFirstChild(tool.Name)
    if not toolSounds then return end

    playSound(toolSounds.Swings.Swing, tool.Handle)
    emitTrail(tool)
end

function module.init()
    Network.connectEvent(Network.RemoteEvents.MeleeEvent, function(eventType: string, params: {any})
        if eventType == "Hit" then
            onHit(params[1] :: Tool, params[2] :: BasePart)
        elseif eventType == "Swing" then
            onSwing(params[1] :: Tool)
        end
    end, Network.t.string, Network.t.table)
end

return module
