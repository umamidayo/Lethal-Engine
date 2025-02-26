local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = {}

function module.init()
	local nvgevent = Instance.new("RemoteEvent")
	nvgevent.Name = "nvg"
	nvgevent.Parent = ReplicatedStorage

	local activenvgs = {}
	local previoustoggle = {}

	nvgevent.OnServerEvent:Connect(function(plr)
		if plr.Character then
			local helmet = plr.Character:FindFirstChild("Nods")
			if helmet then
				local nvg = helmet:FindFirstChild("Up")
				if nvg then
					local id = plr.Name
					local prevtoggle = previoustoggle[id]
					local newt = time()
					if not prevtoggle or newt - prevtoggle > 0.6 then
						previoustoggle[id] = newt
						local bool
						if activenvgs[id] then
							activenvgs[id] = nil
							bool = false
						else
							activenvgs[id] = nvg
							bool = true
						end
						for _, v in pairs(Players:GetPlayers()) do
							if v ~= plr then
								nvgevent:FireClient(v, nvg, bool)
							end
						end
					end
				end
			end
		end
	end)

	for _, v in pairs(script:GetChildren()) do
		if string.match(v.ClassName, "Value") then
			v.Parent = ReplicatedStorage
		end
	end

	Players.PlayerAdded:Connect(function(plr)
		for _, nvg in pairs(activenvgs) do
			if nvg then
				nvgevent:FireClient(plr, nvg, true)
			end
		end
	end)
end

return module
