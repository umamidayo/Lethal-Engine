local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ReplicatedStorage.Common.Network)

local WeaponModules = ServerScriptService.Modules.MeleeWeapons

local weaponModuleCache = {}
local module = {}

local function addHitTag(player: Player, Humanoid: Humanoid)
	local hitTag = Instance.new("ObjectValue")
	hitTag.Name = "creator"
	hitTag.Value = player
	hitTag.Parent = Humanoid
	Debris:AddItem(hitTag, 10)
end

local function onHit(player: Player, tool: Tool, hit: BasePart, targetHumanoid: Humanoid)
	if not player.Character or not tool or not tool:IsA("Tool") or not tool.Parent == player.Character then
		return
	end
	if not hit or not targetHumanoid or targetHumanoid.Health <= 0 then
		return
	end
	if Players:GetPlayerFromCharacter(targetHumanoid.Parent) then
		return
	end

	local playerHumanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
	if not playerHumanoid or playerHumanoid.Health <= 0 then
		return
	end

	if player:DistanceFromCharacter(hit.Position) > 7 then
		return
	end

	if not weaponModuleCache[tool.Name] then
		local WeaponModule = WeaponModules:FindFirstChild(tool.Name)
		if not WeaponModule then
			return
		end
		weaponModuleCache[tool.Name] = require(WeaponModule).new()
	end

	addHitTag(player, targetHumanoid)
	if weaponModuleCache[tool.Name].HitBonus then
		weaponModuleCache[tool.Name].HitBonus(player, targetHumanoid)
	end
	local damage = weaponModuleCache[tool.Name].Damage
	if player.Character:GetAttribute("MeleeDamageBonus") then
		damage += damage * (player.Character:GetAttribute("MeleeDamageBonus") / 100)
	end
	if player.Character:GetAttribute("LifeSteal") then
		local lifesteal = player.Character:GetAttribute("LifeSteal") or 0
		playerHumanoid.Health += playerHumanoid.MaxHealth * lifesteal
	end
	targetHumanoid:TakeDamage(damage)
	Network.fireAllClients(Network.RemoteEvents.MeleeEvent, "Hit", { tool, hit })
end

local function onSwing(player: Player, tool: Tool)
	if not player.Character or not tool or not tool:IsA("Tool") or not tool.Parent == player.Character then
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
