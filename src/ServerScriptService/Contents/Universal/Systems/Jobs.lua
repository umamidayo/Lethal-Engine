local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Jobs = require(ServerScriptService.Modules.JobsData)

local JobsEvent = ReplicatedStorage.RemotesLegacy.Jobs
local Notify = ReplicatedStorage.RemotesLegacy.Notifier

local playerJobs = {}
local module = {}

function module.init()
	Players.PlayerAdded:Connect(function(player)
		if playerJobs[player.Name] == nil then
			playerJobs[player.Name] = {}

			for _ = 1, 10 do
				table.insert(playerJobs[player.Name], Jobs[math.random(1, #Jobs)])
			end

			playerJobs[player.Name] = Jobs.fixDuplicateJobs(playerJobs[player.Name])
			playerJobs[player.Name] = Jobs.deepCopy(playerJobs[player.Name])
		end

		JobsEvent:FireClient(player, playerJobs[player.Name])
	end)

	JobsEvent.OnServerEvent:Connect(function(player, jobName: string)
		if playerJobs[player.Name] == nil then
			return
		end

		for i, job in playerJobs[player.Name] do
			if job.Name ~= jobName or not job.Completed(player) then
				continue
			end

			table.remove(playerJobs[player.Name], i)
			Notify:FireClient(player, "Completed task '" .. job.Name .. "'")
			player:SetAttribute("Cash", player:GetAttribute("Cash") + job.CashReward)
			Notify:FireClient(
				player,
				"You received $" .. job.CashReward .. " for completing the task '" .. job.Name .. "'"
			)
		end
	end)
end

return module
