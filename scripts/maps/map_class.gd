extends Node
class_name MapClass

# Specify map generation

@export_enum("Small", "Medium", "Large") var size: int 
@export var map: Texture2D
@export var land_tile: PackedScene
@export var cliff_tile: PackedScene
@export var water_tile: PackedScene
@export var biome_data: Resource
@export var tile_pool: Node2D = Node2D.new()

var Size = {
	0: 0.15,
	1: 0.3,
	2: 0.5,
}

var image: Image
var scale: float


func _ready():
	image = map.get_image()
	image.resize(image.get_width()*scale, image.get_height()*scale)
	scale = Size.get(size)
	self.add_child(tile_pool)
	
	_fuzz_image()
	_ready_tiles()
	_set_tiles()


func _ready_tiles():
	for y in range(image.get_height() + 2):
		for x in range(image.get_width() + 2):
			var tile: TileClass = init_tile(x, y)
			var delta_x: int = tile.tile_width * x
			var delta_y: int = tile.tile_height * y
			var position = Vector2(delta_x, delta_y)
			tile.set_position(position)
			tile_pool.add_child(tile)


func _set_tiles():
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var tile: TileClass = get_tile(x+1, y+1)
			if tile.get_layer() == 1:
				if get_tile(x, y+1).layer == 0:
					pass
				if get_tile(x+2, y+1).layer == 0:
					pass
				if get_tile(x+1, y).layer == 0:
					pass
				if get_tile(x+1, y+2).layer == 0:
					pass


func get_tile(x: int, y: int):
	return tile_pool.get_child(y*image.get_width() + x)


func init_tile(x: int, y: int):
	# Implement custom tile setting
	var tile = land_tile.instantiate()
	return tile.init(0, false)


func _fuzz_image():
	# Implement custom image fuzzing
	return

