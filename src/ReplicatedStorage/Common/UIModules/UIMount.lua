local module = {}

function module.close(uiObject: ImageButton, uiParams: {any})
    local mouseEnter, mouseLeave, mouseClick

    if uiParams.mouseEnter then
        mouseEnter = uiObject.MouseEnter:Connect(uiParams.mouseEnter)
    end

    if uiParams.mouseLeave then
        mouseLeave = uiObject.MouseLeave:Connect(uiParams.mouseLeave)
    end

    if uiParams.mouseClick then
        mouseClick = uiObject.MouseButton1Click:Connect(uiParams.mouseClick)
    end

    return mouseEnter, mouseLeave, mouseClick
end

function module.button(uiObject: TextButton, uiParams: {any})
    local mouseEnter, mouseLeave, mouseClick

    uiParams = uiParams or {}
    local button: TextButton = uiParams.button

    if uiParams.mouseEnter then
        mouseEnter = button.MouseEnter:Connect(uiParams.mouseEnter)
    end

    if uiParams.mouseLeave then
        mouseLeave = button.MouseLeave:Connect(uiParams.mouseLeave)
    end

    if uiParams.mouseClick then
        mouseClick = button.MouseButton1Click:Connect(uiParams.mouseClick)
    end

    return mouseEnter, mouseLeave, mouseClick
end

function module.mount(uiObject: GuiObject, type: string, uiParams: {any})
    if module[type] then
        return module[type](uiObject, uiParams)
    end
end

return module
