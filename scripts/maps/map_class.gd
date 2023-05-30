extends Node
class_name MapClass

# Specify map generation


@export_range(1, 100) var map_size: int = 1
@export var land_tile: Resource
@export var water_tile: Resource
@export var biome_data: Resource
@export var tile_pool: Node2D = Node2D.new()


func _ready():
	self.add_child(tile_pool)
	ready_tiles(map_size)

func ready_tiles(size: int):
	if land_tile == null:
		return
	
	for y in range(size):
		for x in range(size):
			var new_tile = land_tile.instantiate()
			var delta_x: int = (new_tile.tile_width * x) + (new_tile.tile_width/2 * (y%2))
			var delta_y: int = (new_tile.tile_height/1.3 * y)
			var position = Vector2(delta_x, delta_y)
			new_tile._set_tile(position, biome_data.land_tile)
			tile_pool.add_child(new_tile)
