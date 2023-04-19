extends Sprite2D

@onready var hill: Sprite2D = $hill
@onready var tree: Sprite2D = $tree
@onready var area: Area2D = $Area2D
var neighbours = []
var type

signal tile_selected

func SetTile(tile_type, TileType):
	type = tile_type
	area.monitoring = true
	# Assign unique attributes to each biome type
	match tile_type:
#		Water-Based Tiles
		TileType.OCEAN_DEEP:
			texture = load("res://assets/hextiles/ocean_deep.png")
			hill.texture = null
			tree.texture = null
		TileType.OCEAN_MID:
			texture = load("res://assets/hextiles/ocean_mid.png")
			hill.texture = null
			tree.texture = null
		TileType.OCEAN_SHALLOW:
			texture = load("res://assets/hextiles/ocean_shallow.png")
			hill.texture = null
			tree.texture = null
#		Land-Based Tiles
		TileType.SNOW:
			texture = load("res://assets/hextiles/snow.png")
			hill.texture = null
			tree.texture = null
		TileType.SNOW_HILL:
			texture = load("res://assets/hextiles/snow.png")
			hill.texture = load("res://assets/hills/snow_hill_v2.png")
			tree.texture = null
		TileType.SNOW_MOUNTAIN:
			texture = load("res://assets/hextiles/snow.png")
			hill.texture = load("res://assets/hills/mountain.png")
			tree.texture = null
		TileType.TUNDRA:
			texture = load("res://assets/hextiles/tundra.png")
			hill.texture = null
			tree.texture = null
		TileType.TUNDRA_HILL:
			texture = load("res://assets/hextiles/tundra.png")
			hill.texture = load("res://assets/hills/snow_hill_v2.png")
			tree.texture = null
		TileType.TAIGA:
			texture = load("res://assets/hextiles/snow.png")
			hill.texture = null
			tree.texture = load("res://assets/trees/forest.png")
		TileType.TAIGA_HILL:
			texture = load("res://assets/hextiles/snow.png")
			hill.texture = load("res://assets/hills/snow_hill_v2.png")
			tree.texture = load("res://assets/trees/forest.png")
		TileType.GRASS:
			texture = load("res://assets/hextiles/grassland.png")
			hill.texture = null
			tree.texture = null
		TileType.GRASS_HILL:
			texture = load("res://assets/hextiles/grassland.png")
			hill.texture = load("res://assets/hills/grass_hill.png")
			tree.texture = null
		TileType.GRASS_MOUNTAIN:
			texture = load("res://assets/hextiles/grassland.png")
			hill.texture = load("res://assets/hills/mountain.png")
			tree.texture = null
		TileType.FOREST:
			texture = load("res://assets/hextiles/grassland.png")
			hill.texture = null
			tree.texture = load("res://assets/trees/forest.png")
		TileType.FOREST_HILL:
			texture = load("res://assets/hextiles/grassland.png")
			hill.texture = load("res://assets/hills/grass_hill.png")
			tree.texture = null
		TileType.SWAMP:
			texture = load("res://assets/hextiles/swamp.png")
			hill.texture = null
			tree.texture = load("res://assets/trees/willow.png")
		TileType.SAND:
			texture = load("res://assets/hextiles/sand.png")
			hill.texture = null
			tree.texture = null
		TileType.SAND_HILL:
			texture = load("res://assets/hextiles/sand.png")
			hill.texture = load("res://assets/hills/sand_hill.png")
			tree.texture = null
		TileType.SAVANNAH:
			texture = load("res://assets/hextiles/savannah.png")
			hill.texture = null
			tree.texture = load("res://assets/trees/acacia.png")
		TileType.SAVANNAH_HILL:
			texture = load("res://assets/hextiles/savannah.png")
			hill.texture = load("res://assets/hills/sand_hill.png")
			tree.texture = load("res://assets/trees/acacia.png")
		TileType.JUNGLE:
			texture = load("res://assets/hextiles/jungle.png")
			hill.texture = null
			tree.texture = load("res://assets/trees/jungle_tree.png")
		TileType.JUNGLE_HILL:
			texture = load("res://assets/hextiles/jungle.png")
			hill.texture = load("res://assets/hills/grass_hill.png")
			tree.texture = load("res://assets/trees/jungle_tree.png")
		TileType.NULL:
			texture = null
			hill.texture = null
			tree.texture = null
			area.monitoring = true
		_:
			texture = load("res://assets/hextiles/Purple tile.png")
			hill.texture = null
			tree.texture = null
			area.monitoring = true

func SetNeighbours(nbrs):
	neighbours = nbrs


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		tile_selected.emit(self)
