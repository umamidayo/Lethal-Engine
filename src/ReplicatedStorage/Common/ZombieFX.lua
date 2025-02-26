local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local VFXModule = require(ReplicatedStorage.Common.VFX_Module)
local BezierLib = require(ReplicatedStorage.Common.Libraries.Bezier)

local Entities = ReplicatedStorage:WaitForChild("Entities")
local ZombieFX = {
	ZombieSounds = SoundService:WaitForChild("Zombies"),
	Particles = Entities:WaitForChild("Zombies"):WaitForChild("Particles"),
	VFX = Entities:WaitForChild("Zombies"):WaitForChild("VFX"),
}

local Player = Players.LocalPlayer

function ZombieFX.AbominationExplode(zombie: Model)
	local PreExplode = ZombieFX.ZombieSounds.Abomination.Death.PreExplode:Clone()
	PreExplode.Parent = zombie.Torso
	PreExplode:Play()
	task.wait(2)
	PreExplode:Stop()

	local DebrisTime = 0.5

	local BileExplosion = VFXModule.Create(
		ZombieFX.VFX.BileExplosion,
		Vector3.new(),
		0,
		CFrame.new(zombie.Torso.Position + Vector3.new(0, 3, 0)),
		DebrisTime
	)
	VFXModule.TweenSize(BileExplosion, Vector3.new(35, 35, 35), DebrisTime / 1.25)
	VFXModule.TweenTransparency(BileExplosion, 1, DebrisTime)
	VFXModule.SpinVFX(BileExplosion, CFrame.Angles(0, math.rad(1), 0))

	local FleshExplosion = VFXModule.Create(
		ZombieFX.VFX.FleshExplosion,
		Vector3.new(),
		0,
		CFrame.new(zombie.Torso.Position + Vector3.new(0, 3, 0)),
		DebrisTime
	)
	VFXModule.TweenSize(FleshExplosion, Vector3.new(40, 40, 40), DebrisTime / 1.25)
	VFXModule.TweenTransparency(FleshExplosion, 1, DebrisTime)
	VFXModule.SpinVFX(FleshExplosion, CFrame.Angles(0, math.rad(1), 0))

	local BloodExplosion = VFXModule.Create(
		ZombieFX.VFX.BloodExplosion,
		Vector3.new(),
		0,
		CFrame.new(zombie.Torso.Position + Vector3.new(0, 3, 0)),
		DebrisTime
	)
	VFXModule.TweenSize(BloodExplosion, Vector3.new(45, 1, 45), DebrisTime / 1.25)
	VFXModule.TweenTransparency(BloodExplosion, 1, DebrisTime)

	if Player.Character and Player.Character:FindFirstChildWhichIsA("Humanoid") then
		if Player:DistanceFromCharacter(zombie.Torso.Position) < 50 then
			VFXModule.ShakeCamera()
		end
	end

	local Explode = ZombieFX.ZombieSounds.Abomination.Death.Explode:Clone()
	Explode.Parent = zombie.Torso
	Explode:Play()

	local FleshExplode = ZombieFX.ZombieSounds.Abomination.Death.FleshExplode:Clone()
	FleshExplode.Parent = zombie.Torso
	FleshExplode:Play()
end

function ZombieFX.SpitterShot(zombie: Model, arguments)
	--local spitEndPos: Vector3  = arguments[1]
	local spitProjectilePositions: { Vector3 } = arguments[2]
	local spitProjectileTime = arguments[3]

	local spitProjectile = ZombieFX.Particles.SpitProjectile:Clone()
	spitProjectile.Parent = workspace

	local spitVocalSound = ZombieFX.ZombieSounds.Spitter.Spit.SpitVocal:Clone()
	spitVocalSound.PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
	local spitShotSound = ZombieFX.ZombieSounds.Spitter.Spit.SpitShot:Clone()
	spitShotSound.PlaybackSpeed = spitShotSound.PlaybackSpeed
	spitShotSound.Parent = zombie.Head
	spitVocalSound.Parent = zombie.Head
	spitVocalSound:Play()
	spitShotSound:Play()

	Debris:AddItem(spitVocalSound, spitShotSound.TimeLength)
	Debris:AddItem(spitShotSound, spitShotSound.TimeLength)

	local spitTweenInfo = TweenInfo.new(spitProjectileTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local spitBezier = BezierLib.new(spitProjectilePositions[1], spitProjectilePositions[2], spitProjectilePositions[3])

	local spitTween = spitBezier:CreateVector3Tween(spitProjectile, { "Position" }, spitTweenInfo)
	spitTween:Play()
	spitTween.Completed:Wait()

	local spitPuddleExplosion = ZombieFX.Particles.SpitPuddleExplosion:Clone()
	spitPuddleExplosion.CFrame = spitProjectile.CFrame
	spitPuddleExplosion.Parent = workspace

	local spitSplatSound = ZombieFX.ZombieSounds.Spitter.Spit.SpitSplat:Clone()
	local spitSizzleSound = ZombieFX.ZombieSounds.Spitter.Spit.SpitSizzle:Clone()
	spitSplatSound.PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
	spitSizzleSound.PlaybackSpeed = spitSplatSound.PlaybackSpeed
	spitSplatSound.Parent = spitPuddleExplosion
	spitSizzleSound.Parent = spitPuddleExplosion
	spitSplatSound:Play()
	spitSizzleSound:Play()

	for _, v: ParticleEmitter in spitPuddleExplosion:GetDescendants() do
		if v:IsA("ParticleEmitter") then
			v:Emit(10)
		end
	end

	Debris:AddItem(spitPuddleExplosion, spitSizzleSound.TimeLength)
	spitProjectile:Destroy()
	spitBezier:Destroy()
end

return ZombieFX
