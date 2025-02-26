local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ReplicatedStorage.Common.Network)

local WeaponModules = ServerScriptService.Modules.MeleeWeapons

local weaponModuleCache = {}
local module = {}

local function addHitTag(player: Player, humanoid: Humanoid)
	local hitTag = Instance.new("ObjectValue")
	hitTag.Name = "creator"
	hitTag.Value = player
	hitTag.Parent = humanoid
	Debris:AddItem(hitTag, 10)
end

local function validateHit(player: Player, tool: Tool, hit: BasePart, targetHumanoid: Humanoid): boolean
	if not player.Character then
		return false
	end

	if not tool:IsA("Tool") or tool.Parent ~= player.Character then
		return false
	end

	if not hit or not targetHumanoid or targetHumanoid.Health <= 0 then
		return false
	end

	-- Don't allow hitting other players
	if Players:GetPlayerFromCharacter(targetHumanoid.Parent) then
		return false
	end

	local playerHumanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
	if not playerHumanoid or playerHumanoid.Health <= 0 then
		return false
	end

	if player:DistanceFromCharacter(hit.Position) > 7 then
		return false
	end

	return true
end

local function getWeaponModule(toolName: string)
	if not weaponModuleCache[toolName] then
		local weaponModule = WeaponModules:FindFirstChild(toolName)
		if not weaponModule then
			return nil
		end
		weaponModuleCache[toolName] = require(weaponModule).new()
	end
	return weaponModuleCache[toolName]
end

local function calculateDamage(player: Player, baseDamage: number): number
	local damageBonus = player.Character:GetAttribute("MeleeDamageBonus") or 0
	return baseDamage * (1 + damageBonus / 100)
end

local function applyLifesteal(player: Player)
	local lifestealPercent = player.Character:GetAttribute("LifeSteal")
	if not lifestealPercent then
		return
	end

	local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid.Health += humanoid.MaxHealth * lifestealPercent
	end
end

local function onHit(player: Player, tool: Tool, hit: BasePart, targetHumanoid: Humanoid)
	if not validateHit(player, tool, hit, targetHumanoid) then
		return
	end

	local weaponModule = getWeaponModule(tool.Name)
	if not weaponModule then
		return
	end

	addHitTag(player, targetHumanoid)

	if weaponModule.HitBonus then
		weaponModule.HitBonus(player, targetHumanoid)
	end

	local damage = calculateDamage(player, weaponModule.Damage)
	applyLifesteal(player)

	targetHumanoid:TakeDamage(damage)
	Network.fireAllClients(Network.RemoteEvents.MeleeEvent, "Hit", { tool, hit })
end

local function onSwing(player: Player, tool: Tool)
	if not player.Character or not tool:IsA("Tool") or tool.Parent ~= player.Character then
		return
	end
	Network.fireAllClients(Network.RemoteEvents.MeleeEvent, "Swing", { tool })
end

function module.init()
	Network.connectEvent(Network.RemoteEvents.MeleeEvent, function(player: Player, eventType: string, params: { any })
		if eventType == "Hit" then
			onHit(player, params[1] :: Tool, params[2] :: BasePart, params[3] :: Humanoid)
		elseif eventType == "Swing" then
			onSwing(player, params[1] :: Tool)
		end
	end, Network.t.instanceOf("Player"), Network.t.string, Network.t.table)
end

return module
