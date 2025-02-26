--!strict

--[[
	Specifies the names of all RemoteFunctions. One RemoteFunction object gets generated for each name
	in this list, and these names are used as enums when interacting with Network to tell it
	which remote function to fire without typing out typo-prone string literals.
--]]

export type EnumType = "RequestServerListing" | "RequestTeleport" | "Craft" | "Pickup" | "InitialStateSync"

local RemoteFunctionName = {
	RequestServerListing = "RequestServerListing" :: "RequestServerListing",
	RequestTeleport = "RequestTeleport" :: "RequestTeleport",
	Craft = "Craft" :: "Craft",
	Pickup = "Pickup" :: "Pickup",
	InitialStateSync = "InitialStateSync" :: "InitialStateSync",
}

return RemoteFunctionName
