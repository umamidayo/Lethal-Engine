local module = {}

function module.init()
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
end

return module
