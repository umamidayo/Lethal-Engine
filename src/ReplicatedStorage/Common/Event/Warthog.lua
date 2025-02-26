local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local warthogModel: Model = ReplicatedStorage.Entities.Aircraft.Warthog

function module.strafe(attackPos: Vector3)
    local model = warthogModel:Clone()
    local strafeStartPos = attackPos + Vector3.new(0, 500, 0) + model.PrimaryPart.CFrame.LookVector * 10000
    local strafeEndPos = strafeStartPos + model.PrimaryPart.CFrame.LookVector * -16000
    model:PivotTo(CFrame.new(strafeStartPos, strafeEndPos))
    model.Parent = workspace

    local function playSounds()
        local jetSound: Sound = model.PrimaryPart:FindFirstChild("Jet")
        local fireSound: Sound = model.PrimaryPart:FindFirstChild("Fire")
        local turbineSound: Sound = model.PrimaryPart:FindFirstChild("Turbine")
        if not jetSound or not fireSound or not turbineSound then return end
        fireSound.Volume = 10
        jetSound.Volume = 10
        turbineSound.Volume = 10
        turbineSound:Play()
        jetSound:Play()
        TweenService:Create(jetSound, TweenInfo.new(16), {Volume = 0}):Play()
        TweenService:Create(turbineSound, TweenInfo.new(16), {Volume = 0}):Play()
        task.delay(3.4, function()
            fireSound:Play()
        end)
    end
    playSounds()

    local cframeValue = model:FindFirstChildWhichIsA("CFrameValue")
    if not cframeValue then return end
    cframeValue.Value = CFrame.new(strafeStartPos)
    cframeValue:GetPropertyChangedSignal("Value"):Connect(function()
        model:PivotTo(cframeValue.Value * CFrame.Angles(math.rad(-15), 0, 0))
    end)
    local tween = TweenService:Create(cframeValue, TweenInfo.new(16), {Value = CFrame.new(strafeEndPos) * CFrame.Angles(math.rad(25), 0, 0)})
    tween:Play()
    tween.Completed:Wait()
    model:Destroy()
    tween:Destroy()
end

return module
