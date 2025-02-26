local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Store = require(ReplicatedStorage.Common.Store)

local StoreUtility = {}

-- Attempts to fetch the data, will wait for 10 seconds for the provided parameters from the Rodux Store.
function StoreUtility.waitForValue(...: any): any?
    local params = {...}
    local state = Store:getState()
    local currentValue = state

    for i, key in params do
        if not currentValue[key] then
            local startTime = os.time()
            repeat
                task.wait(0.1)
                state = Store:getState()
                currentValue = state
                for j = 1, i-1 do
                    currentValue = currentValue[params[j]]
                end
            until currentValue[key] or os.time() - startTime > 10

            if os.time() - startTime > 10 then
                warn(`Failed to find value {key} in path:`)
                print(state)
                return nil
            end
        end
        currentValue = currentValue[key]
    end

    return currentValue
end

-- Returns the value of the provided parameters from the Rodux Store.
function StoreUtility.getValue(...: any): any?
    local params = {...}
    local state = Store:getState()
    local currentValue = state

    for _, key in params do
        if not currentValue[key] then
            return nil
        end
        currentValue = currentValue[key]
    end

    return currentValue
end


return StoreUtility