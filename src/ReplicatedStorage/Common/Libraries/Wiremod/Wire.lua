local module = {}
module.__index = module

local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

-- Entire shared library will error if Wiremod gets required, so it's required in the constructor, where it's being referenced.
local Wiremod: table

export type WireObject = {
    Constraint: RopeConstraint,
    ObjectA: Wiremod.WiremodObject,
    ObjectB: Wiremod.WiremodObject
}

local function CreateWirePart(Model:  Model)
    local WirePart = Instance.new("Part")
    WirePart.Name = "WirePart"
    WirePart.Anchored = true
    WirePart.CanCollide = false
    WirePart.Transparency = 1
    WirePart.Size = Vector3.new(0.2, 0.2, 0.2)

    local Orientation, Size = Model:GetBoundingBox()
    WirePart.CFrame = CFrame.new(Orientation.Position + Vector3.new(0, Size.Y / 2, 0))
    WirePart.Parent = Model

    return WirePart
end

local function CreateWireAttachment(WirePart: BasePart)
    local Attachment = Instance.new("Attachment")
    Attachment.Name = "WireAttachment"
    Attachment.Position = Vector3.zero
    Attachment.Parent = WirePart
    return Attachment
end

function module.CreateWire(ModelA: BasePart, ModelB: BasePart)
    local WirePartA = ModelA:FindFirstChild("WirePart") or CreateWirePart(ModelA)
    local WirePartB = ModelB:FindFirstChild("WirePart") or CreateWirePart(ModelB)

    local WireAttachmentA = WirePartA:FindFirstChild("WireAttachment") or CreateWireAttachment(WirePartA)
    local WireAttachmentB = WirePartB:FindFirstChild("WireAttachment") or CreateWireAttachment(WirePartB)

    local Wire = Instance.new("RopeConstraint")
    Wire.Name = "Wire"
    Wire.Visible = true
    Wire.Color = BrickColor.new("Really black")
    Wire.Length = (WirePartA.Position - WirePartB.Position).Magnitude + 0.2
    Wire.Attachment0 = WireAttachmentA
    Wire.Attachment1 = WireAttachmentB
    Wire.Parent = WirePartA
    return Wire
end

function module.PlayWiringSound(Source: BasePart)
    local WiringSound: Sound = SoundService.Building:FindFirstChild("WiringSound")

    if WiringSound then
        WiringSound = WiringSound:Clone()
        WiringSound.PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
        WiringSound.Parent = Source
        WiringSound:Play()
        Debris:AddItem(WiringSound, WiringSound.TimeLength)
    end
end

function module.new(constraint: RopeConstraint, objectA: Wiremod.WiremodObject, objectB: Wiremod.WiremodObject)
    if not Wiremod then
        Wiremod = require(script.Parent.Wiremod)
    end
    
    local Wire = {
        Constraint = constraint,
        ObjectA = objectA,
        ObjectB = objectB,
    }

    table.insert(Wiremod.Objects, Wire)

    return setmetatable(Wire, module)
end

-- Wire doesn't inherit Wiremod object, therefore it needs its own Destroy method.
function module:Destroy()
    local index = table.find(Wiremod.Objects, self)

    if not index then return warn(script.Name .. " - Couldn't find wire from removal") end

    table.remove(Wiremod.Objects, index)
    self.Constraint:Destroy()

    for key in self do
        self[key] = nil
    end

    setmetatable(self, nil)
end

function module.GetObjectFromConstraint(constraint: RopeConstraint)
    for _,Wire in pairs(Wiremod.Objects) do
        if Wire.Constraint == constraint then
            return Wire
        end
    end
end

return module