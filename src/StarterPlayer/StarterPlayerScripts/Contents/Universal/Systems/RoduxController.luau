local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Common.Network)
local Store = require(ReplicatedStorage.Common.Store)

local LocalPlayer = Players.LocalPlayer

local RoduxController = {}

function RoduxController.init()
	Store:dispatch({
		type = "setupInterface",
	})

	Network.connectEvent(Network.RemoteEvents.StoreUpdate, function(action)
		Store:dispatch(action)
	end, Network.t.any)

	local playerClassState = Network.invokeServerAsync(Network.RemoteFunctions.InitialStateSync)
	if playerClassState then
		for userId, playerData in playerClassState do
			if userId == LocalPlayer.UserId then
				continue
			end

			Store:dispatch({
				type = "SETUP_PLAYER",
				userId = userId,
				className = playerData.className,
				level = playerData.level,
				experience = playerData.experience,
				requiredExperience = playerData.requiredExperience,
				perkpoints = playerData.perkpoints,
				perks = playerData.perks,
				classes = playerData.classes,
			})
		end
	end
end

return RoduxController
