local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Cryo = require(ReplicatedStorage.Packages.Cryo)
local DataStore2 = require(ServerScriptService.Modules.DataStore2)
local StoreUtility = require(ReplicatedStorage.Common.StoreUtility)
local Serializer = require(ServerScriptService.Modules.Serializer)
local Store = require(ReplicatedStorage.Common.Store)

local Migration = {}

-- Prepares the player's old materials data to the new materials saving method (Rodux + DataStore2).
function Migration.updateInventoryToLatest(player: Player)
    print("Migrating materials for player " .. player.Name)

    local CraftbagStore = DataStore2("Craftbag", player)
    local serialized_array = CraftbagStore:Get()

    -- If the player doesn't have anything saved, we skip migration.
    if not serialized_array then
        print("No migration required for player " .. player.Name)
        return
    end

    serialized_array = HttpService:JSONDecode(serialized_array)
    local migratingMaterials = {}
    for _, item in serialized_array do
        local deserialized_item = Serializer.DeserializeItem(item)
        migratingMaterials[deserialized_item[1]] = tonumber(deserialized_item[2])
    end

    local materials = StoreUtility.waitForValue("inventory", player.UserId, "materials")
    if materials then
        materials = Cryo.Dictionary.join(materials, migratingMaterials)
        Store:dispatch({
            type = "setMaterials",
            userId = player.UserId,
            materials = materials,
        })

        print("Successfully migrated materials for player " .. player.Name)
    else
        warn("Unable to migrate materials for player " .. player.Name)
    end
end

return Migration