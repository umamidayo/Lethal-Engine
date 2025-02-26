export type ResourceInfo = {
	Name: string,
	DropQuantity: number,
	MaxQuantity: number,
	TerrainMaterial: {string},
}

local Resources = {
	Rock = {
		Name = "Rock",
		DropQuantity = 1,
		MaxQuantity = 35,
		TerrainMaterial = {"Ground", "LeafyGrass"},
	},

	Stick = {
		Name = "Stick",
		DropQuantity = 1,
		MaxQuantity = 45,
		TerrainMaterial = {"Ground", "LeafyGrass"},
	},

	Plastic = {
		Name = "Plastic",
		DropQuantity = 1,
		MaxQuantity = 22,
		TerrainMaterial = {"Ground", "LeafyGrass"},
	},

	Metal = {
		Name = "Metal",
		DropQuantity = 1,
		MaxQuantity = 16,
		TerrainMaterial = {"Ground", "LeafyGrass"},
	},
	
	Cloth = {
		Name = "Cloth",
		DropQuantity = 1,
		MaxQuantity = 25,
		yOffset = 1,
		TerrainMaterial = {"Ground", "LeafyGrass"},
	},

	["Raw Meat"] = {
		Name = "Raw Meat",
		DropQuantity = 3,
		MaxQuantity = 99,
		AdditionalDrops = {"Leather"},
	},
	
	["Leather"] = {
		Name = "Leather",
		DropQuantity = 1,
		MaxQuantity = 0,
	},
	
	["Blueberries"] = {
		Name = "Blueberries",
		DropQuantity = 1,
		MaxQuantity = 100,
		TerrainMaterial = {"Grass"},
	}
}

function Resources.GetResourceInfo(Resource: string)
	return Resources[Resource]
end

return Resources
