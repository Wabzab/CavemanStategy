extends Sprite2D

@onready var hill: Sprite2D = $hill
@onready var tree: Sprite2D = $tree
@onready var border: Sprite2D = $border
@onready var area: Area2D = $Area2D
var neighbours = []
var type
var tile_data = {
	"height": 0,
	"temp": 0,
	"precipitation": 0,
	"ocean": false,
	"river": false
}

signal tile_selected

func SetTile(tile_type, TileType):
	type = tile_type
	area.monitoring = true
	# Assign unique attributes to each biome type
	match tile_type:
		TileType.WATER:
			texture = load("res://assets/hextiles/water.png")
			hill.texture = null
			tree.texture = null
			area.monitoring = false
		TileType.COAST:
			texture = load("res://assets/hextiles/coast.png")
			hill.texture = null
			tree.texture = null
			area.monitoring = false
		TileType.TUNDRA:
			texture = load("res://assets/hextiles/snow.png")
			hill.texture = null
			tree.texture = null
			area.monitoring = false
		TileType.BOREAL:
			texture = load("res://assets/hextiles/snow.png")
			hill.texture = null
			tree.texture = load("res://assets/trees/forest.png")
			area.monitoring = false
		TileType.GRASSLAND:
			#texture = load("res://assets/hextiles/grass.png")
			texture = load("res://assets/imports/grass.png")
			hill.texture = null
			tree.texture = null
			area.monitoring = false
		TileType.SHRUBLAND:
			texture = load("res://assets/hextiles/grass.png")
			hill.texture = null
			tree.texture = load("res://assets/trees/acacia.png")
			area.monitoring = false
		TileType.FOREST:
			texture = load("res://assets/hextiles/grass.png")
			hill.texture = null
			tree.texture = load("res://assets/trees/forest.png")
			area.monitoring = false
		TileType.RAINFOREST:
			texture = load("res://assets/hextiles/grass.png")
			hill.texture = null
			tree.texture = load("res://assets/trees/jungle_tree.png")
			area.monitoring = false
		TileType.DESERT:
			texture = load("res://assets/hextiles/desert.png")
			hill.texture = null
			tree.texture = null
			area.monitoring = false
		TileType.SAVANNAH:
			texture = load("res://assets/hextiles/savanna.png")
			hill.texture = null
			tree.texture = load("res://assets/trees/acacia.png")
			area.monitoring = false
		TileType.TROPICAL_RAINFOREST:
			texture = load("res://assets/hextiles/jungle.png")
			hill.texture = null
			tree.texture = load("res://assets/trees/jungle_tree.png")
			area.monitoring = false
		TileType.NULL:
			texture = null
			hill.texture = null
			tree.texture = null
			area.monitoring = false
		_:
			texture = load("res://assets/hextiles/error.png")
			hill.texture = null
			tree.texture = null
			area.monitoring = false

func SetNeighbours(nbrs):
	neighbours = nbrs

func SetTileData(height, temp, prec, is_ocean=false, is_river=false):
	tile_data["height"] = height
	tile_data["temp"] = temp
	tile_data["precipitation"] = prec

func SetOcean(state):
	tile_data["ocean"] = state

func SetRiver(state):
	tile_data["river"] = state

func IsOcean():
	return tile_data["ocean"]

func IsRiver():
	return tile_data["river"]

func SetBorder(v, c):
	border.visible = v
	border.modulate = c

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		pass
		#tile_selected.emit(self)
