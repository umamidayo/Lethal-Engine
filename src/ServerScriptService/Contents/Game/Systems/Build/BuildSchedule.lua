local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ReplicatedStorage.Common.Network)
local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)
local Sentry = require(ServerScriptService.Modules.Build.Sentry)

local module = {
	priority = 1,
}

local StatusEffects = {
	Burning = {
		damage = 0.10,
		particle = ReplicatedStorage.Entities.Effects.Particles.Fire,
		spreadTag = "FireSpread",
	},
	Toxic = {
		damage = 0.05,
		particle = ReplicatedStorage.Entities.Effects.Particles.Poison,
		slowAmount = 0.75,
	},
	LethalGas = {
		damage = 0.20,
		particle = ReplicatedStorage.Entities.Effects.Particles.Poison,
		slowAmount = 0.50,
	},
}

local function applyParticle(zombie: Model, effectType: string)
	local particle = zombie.PrimaryPart:FindFirstChild(effectType)
	if particle then
		return
	end

	particle = StatusEffects[effectType].particle:Clone()
	particle.Name = effectType
	particle.Parent = zombie.PrimaryPart
end

local function applyStatusEffect(zombie: Model, effectType: string)
	if not zombie.PrimaryPart then
		zombie:RemoveTag(effectType)
		return
	end

	local config = StatusEffects[effectType]
	local humanoid = zombie:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		return
	end

	applyParticle(zombie, effectType)

	if humanoid.Health > 0 then
		humanoid:TakeDamage(humanoid.MaxHealth * config.damage)
	else
		zombie:RemoveTag(effectType)
	end

	if config.slowAmount and not zombie:HasTag("Slowed") then
		zombie:AddTag("Slowed")
		humanoid.WalkSpeed *= config.slowAmount
	end
end

local function handleSpread(sourceTag: string, targetTags: { string }, chance: number)
	local sourceZombies = CollectionService:GetTagged(sourceTag)
	for _, zombie in sourceZombies do
		if not zombie.PrimaryPart then
			zombie:RemoveTag(sourceTag)
			continue
		end

		local nearbyZombies = workspace:GetPartBoundsInRadius(zombie.PrimaryPart.Position, 10)
		for _, part in nearbyZombies do
			local otherZombie = part:FindFirstAncestorWhichIsA("Model")
			if not otherZombie or otherZombie == zombie or not otherZombie:HasTag("Zombie") then
				continue
			end

			if math.random() < chance then
				for _, tag in targetTags do
					if not otherZombie:HasTag(tag) then
						otherZombie:AddTag(tag)
					end
				end
			end
		end
	end
end

function module.init()
	Scheduler.AddToScheduler("Interval_1s", "BurningEffect", function()
		for _, zombie in CollectionService:GetTagged("Burning") do
			applyStatusEffect(zombie, "Burning")
		end
	end)

	Scheduler.AddToScheduler("Interval_1s", "ToxicEffect", function()
		for _, zombie in CollectionService:GetTagged("Toxic") do
			applyStatusEffect(zombie, "Toxic")
		end
	end)

	Scheduler.AddToScheduler("Interval_1s", "LethalGasEffect", function()
		for _, zombie in CollectionService:GetTagged("LethalGas") do
			applyStatusEffect(zombie, "LethalGas")
		end
	end)

	Scheduler.AddToScheduler("Interval_1s", "ContagionSpread", function()
		handleSpread("Contagion", { "LethalGas", "Contagion" }, 0.25)
	end)

	Scheduler.AddToScheduler("Interval_1s", "FireSpread", function()
		handleSpread("FireSpread", { "Burning" }, 0.25)
	end)

	Scheduler.AddToScheduler("Interval_0.2", "SentryNetwork", function()
		if not next(Sentry.ScheduledShots) then
			return
		end

		Network.fireAllClients(Network.RemoteEvents.SentryEvent, "Shoot", Sentry.ScheduledShots)
		Sentry.ScheduledShots = {}
	end)
end

return module
