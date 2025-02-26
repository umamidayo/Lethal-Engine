--!strict

--[[
	Specifies the names of all RemoteEvents. One RemoteEvent object gets generated for each name
	in this list, and these names are used as enums when interacting with Network to tell it
	which remote event to fire without typing out typo-prone string literals.
--]]

export type EnumType =
	"VoiceCommand"
	| "MousePing"
	| "AddWireConnection"
	| "RemoveWireConnection"
	| "NotifierEvent"
	| "MeleeEvent"
	| "LogEvent"
	| "LeaderboardEvent"
	| "WarthogEvent"
	| "BuildEvent"
	| "PlayerDataEvent"
	| "PlayerJoinedEvent"
	| "PlayerClassEvent"
	| "BodyTempEvent"
	| "ToolEvent"
	| "StoreEvent"
	| "DailyEvent"
	| "FoodEvent"
	| "VehicleEvent"
	| "TeleportEvent"
	| "SentryEvent"
	| "StoreUpdate"
local RemoteEventName = {
	VoiceCommand = "VoiceCommand" :: "VoiceCommand",
	MousePing = "MousePing" :: "MousePing",
	AddWireConnection = "AddWireConnection" :: "AddWireConnection",
	RemoveWireConnection = "RemoveWireConnection" :: "RemoveWireConnection",
	NotifierEvent = "NotifierEvent" :: "NotifierEvent",
	MeleeEvent = "MeleeEvent" :: "MeleeEvent",
	LogEvent = "LogEvent" :: "LogEvent",
	LeaderboardEvent = "LeaderboardEvent" :: "LeaderboardEvent",
	WarthogEvent = "WarthogEvent" :: "WarthogEvent",
	BuildEvent = "BuildEvent" :: "BuildEvent",
	PlayerDataEvent = "PlayerDataEvent" :: "PlayerDataEvent",
	PlayerJoinedEvent = "PlayerJoinedEvent" :: "PlayerJoinedEvent",
	PlayerClassEvent = "PlayerClassEvent" :: "PlayerClassEvent",
	BodyTempEvent = "BodyTempEvent" :: "BodyTempEvent",
	ToolEvent = "ToolEvent" :: "ToolEvent",
	StoreEvent = "StoreEvent" :: "StoreEvent",
	DailyEvent = "DailyEvent" :: "DailyEvent",
	FoodEvent = "FoodEvent" :: "FoodEvent",
	VehicleEvent = "VehicleEvent" :: "VehicleEvent",
	TeleportEvent = "TeleportEvent" :: "TeleportEvent",
	SentryEvent = "SentryEvent" :: "SentryEvent",
	StoreUpdate = "StoreUpdate" :: "StoreUpdate",
}

return RemoteEventName
