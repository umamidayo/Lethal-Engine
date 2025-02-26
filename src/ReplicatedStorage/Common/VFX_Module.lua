local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFX_Module = {
	TweenService = game.TweenService,
	CameraShaker = require(ReplicatedStorage:WaitForChild("Common").CameraShaker)
}

function VFX_Module.Create(VFX: BasePart, SetSize: Vector3, SetTransparency: number, SetCFrame: CFrame, DebrisTime: number)
	local newVFX = VFX:Clone()
	newVFX.Size = SetSize
	newVFX.Transparency = SetTransparency
	newVFX.CFrame = SetCFrame
	newVFX.Parent = workspace
	
	if DebrisTime then
		game.Debris:AddItem(newVFX, DebrisTime)
	end
	
	return newVFX
end

function VFX_Module.TweenSize(VFX: BasePart, EndSize: Vector3, Seconds: number)
	local VFXTweenInfo = TweenInfo.new(Seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	VFX_Module.TweenService:Create(VFX, VFXTweenInfo, {Size = EndSize}):Play()
end

function VFX_Module.TweenTransparency(VFX: BasePart, EndTransparency: number, Seconds: number)
	local VFXTweenInfo = TweenInfo.new(Seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	VFX_Module.TweenService:Create(VFX, VFXTweenInfo, {Transparency = EndTransparency}):Play()
end

function VFX_Module.SpinVFX(VFX: BasePart, CFrameAngles: Vector3)
	task.spawn(function()
		while VFX do
			VFX.CFrame = VFX.CFrame * CFrameAngles
			task.wait()
		end
	end)
end

local camera = workspace.CurrentCamera

local function ShakeCamera(shakeCf)
	camera.CFrame = camera.CFrame * shakeCf
end

local camShake = VFX_Module.CameraShaker.new(Enum.RenderPriority.Camera.Value, ShakeCamera)
camShake:Start()

function VFX_Module.ShakeCamera()
	camShake:Shake(VFX_Module.CameraShaker.Presets.Explosion)
end

return VFX_Module
