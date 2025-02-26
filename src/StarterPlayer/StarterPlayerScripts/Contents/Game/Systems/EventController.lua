local module = {}

function module.init()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Network = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Network"))
    local Warthog = require(ReplicatedStorage.Common.Event.Warthog)

    Network.connectEvent(Network.RemoteEvents.WarthogEvent, function(EventType: string)
        Warthog.strafe(Vector3.new(1, 0, 1) * math.random(-300, 300))
    end, Network.t.string)
end

return module
