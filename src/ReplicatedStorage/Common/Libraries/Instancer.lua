-- Instances objects with ease.
local module = {}

function module.ProximityPrompt(promptSettings: {})
    local ProximityPrompt = Instance.new("ProximityPrompt")
    ProximityPrompt.MaxActivationDistance = promptSettings.maxActivationDistance or 7
    ProximityPrompt.ActionText = promptSettings.actionText or "Interact"
    ProximityPrompt.RequiresLineOfSight = promptSettings.requiresLineOfSight or false
    ProximityPrompt.HoldDuration = promptSettings.holdDuration or 0.5
    ProximityPrompt.Parent = promptSettings.parent or nil
    return ProximityPrompt
end

return module
