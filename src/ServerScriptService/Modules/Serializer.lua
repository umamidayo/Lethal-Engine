local Serializer = {}

function Serializer.SerializeItem(itemid: string, quantity: number)
	itemid = string.gsub(itemid, " ", "_")
	return tostring(itemid .. ":" .. quantity)
end

function Serializer.DeserializeItem(item_serialized: string)
	item_serialized = string.gsub(item_serialized, "_", " ")
	return string.split(item_serialized, ":")
end

return Serializer
