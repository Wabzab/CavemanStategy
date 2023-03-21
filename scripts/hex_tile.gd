extends Sprite2D

var globals
var neighbours = []

func SetTile(tile_type):
	globals = get_node("/root/Globals")
	# Assign unique attributes to each biome type
	match tile_type:
		globals.TileType.OCEAN_DEEP:
			texture = load("res://assets/hextiles/ocean_deep.png")
		globals.TileType.OCEAN_MID:
			texture = load("res://assets/hextiles/ocean_mid.png")
		globals.TileType.OCEAN_SHALLOW:
			texture = load("res://assets/hextiles/ocean_shallow.png")
		globals.TileType.GRASSLAND:
			texture = load("res://assets/hextiles/grassland.png")
		globals.TileType.GRASSLAND_FLOWER:
			texture = load("res://assets/hextiles/grassland_flower.png")
		globals.TileType.DESERT:
			texture = load("res://assets/hextiles/sand.png")
		globals.TileType.SNOW:
			texture = load("res://assets/hextiles/snow.png")
		globals.TileType.TUNDRA:
			texture = load("res://assets/hextiles/tundra.png")

