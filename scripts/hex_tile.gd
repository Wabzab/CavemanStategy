extends Sprite2D

@onready var feature: Sprite2D = $feature
var neighbours = []

func SetTile(tile_type, globals):
	# Assign unique attributes to each biome type
	match tile_type:
		globals.TileType.OCEAN_DEEP:
			texture = load("res://assets/hextiles/ocean_deep.png")
			feature.texture = null
		globals.TileType.OCEAN_MID:
			texture = load("res://assets/hextiles/ocean_mid.png")
			feature.texture = null
		globals.TileType.OCEAN_SHALLOW:
			texture = load("res://assets/hextiles/ocean_shallow.png")
			feature.texture = null
		globals.TileType.GRASS:
			texture = load("res://assets/hextiles/grassland.png")
			feature.texture = null
		globals.TileType.GRASS_FLOWER:
			texture = load("res://assets/hextiles/grassland_flower.png")
			feature.texture = null
		globals.TileType.GRASS_HILL:
			texture = load("res://assets/hextiles/grassland.png")
			feature.texture = load("res://assets/features/grass_hill.png")
		globals.TileType.GRASS_MOUNTAIN:
			texture = load("res://assets/hextiles/grassland.png")
			feature.texture = load("res://assets/features/mountain.png")
		globals.TileType.SAND:
			texture = load("res://assets/hextiles/sand.png")
			feature.texture = null
		globals.TileType.SAND_HILL:
			texture = load("res://assets/hextiles/sand.png")
			feature.texture = load("res://assets/features/sand_hill.png")
		globals.TileType.SAND_MOUNTAIN:
			texture = load("res://assets/hextiles/sand.png")
			feature.texture = load("res://assets/features/mountain.png")
		globals.TileType.SNOW:
			texture = load("res://assets/hextiles/snow.png")
			feature.texture = null
		globals.TileType.SNOW_HILL:
			texture = load("res://assets/hextiles/snow.png")
			feature.texture = load("res://assets/features/snow_hill.png")
		globals.TileType.SNOW_MOUNTAIN:
			texture = load("res://assets/hextiles/snow.png")
			feature.texture = load("res://assets/features/mountain.png")
		globals.TileType.TUNDRA:
			texture = load("res://assets/hextiles/tundra.png")
			feature.texture = null
		globals.TileType.NULL:
			texture = null
			feature.texture = null
		_:
			texture = load("res://assets/hextiles/Purple tile.png")
			feature.texture = null
			print("Tile could not be found!")

