local module = {}

function module.init()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Network = require(ReplicatedStorage.Common.Network)

    task.wait(math.random(60, 180))

    Network.fireAllClients(Network.RemoteEvents.WarthogEvent, "WarthogEvent")
end

return module
