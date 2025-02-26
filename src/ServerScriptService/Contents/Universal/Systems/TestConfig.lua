local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TestConfig = {
    priority = 1,
    isTestBuild = RunService:IsStudio() or game.PlaceId == 125199028804410 or game.PlaceId == 15853388084,
}

local function setupProducts()
	local Products = require(ReplicatedStorage.Common.Products.Products)

	for _, productInfo in Products.tokens do
        if productInfo.Cost then
            productInfo.Cost = 0
        end
	end

    for _, productInfo in Products.classes do
        if productInfo.Cost then
            productInfo.Cost = 0
        end
    end

    for _, productInfo in Products.special do
        if productInfo.Cost then
            productInfo.Cost = 0
        end
    end

    for _, productInfo in Products.items do
        if productInfo.Cost then
            productInfo.Cost = 0
        end
    end
end

function TestConfig.isTester(player: Player)
    return player:IsInGroup(34139524) and player:GetRankInGroup(34139524) >= 50
end

function TestConfig.init()
    local isTestPlace = game.PlaceId == 125199028804410 or game.PlaceId == 15853388084
    if not isTestPlace then
        return
    end

    print("Setting up TestConfig")

    setupProducts()
end

return TestConfig