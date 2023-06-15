extends Node
class_name MapClass

# Specify map generation

@export_enum("Small", "Medium", "Large") var size: int 
@export var map: Texture2D
@export var land_tile: PackedScene
@export var water_tile: PackedScene
@export var biome_data: Resource
@export var tile_pool: Node2D = Node2D.new()

var Size = {
	0: 0.15,
	1: 0.3,
	2: 0.5,
}

var scale: float
var image: Image
var noise_image: Image


func _ready():
	scale = Size.get(size)
	image = map.get_image()
	image.resize(image.get_width()*scale, image.get_height()*scale)
	self.add_child(tile_pool)
	
	fuzz_image()
	ready_tiles()
	set_tiles()
	update()


func ready_tiles():
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var tile: TileClass = init_tile(x, y)
			var delta_x: int = tile.width * x
			var delta_y: int = tile.height * y
			var position = Vector2(delta_x, delta_y)
			tile.set_position(position)
			tile_pool.add_child(tile)


func set_tiles():
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var tile: TileClass = get_tile(x, y)
			tile.set_texture(biome_data.land_tile)
			if tile.get_layer() == 1 and not tile.is_ramp():
				var left = get_tile(x-1, y)
				var right = get_tile(x+1, y)
				var up = get_tile(x, y-1)
				var down = get_tile(x, y+1)
				if left and left.get_layer() == 0:
					tile.add_cliff(biome_data.left_cliff)
				if right and right.get_layer() == 0:
					tile.add_cliff(biome_data.right_cliff)
				if up and up.get_layer() == 0:
					tile.add_cliff(biome_data.top_cliff)
				if down and down.get_layer() == 0:
					tile.set_texture(biome_data.cliff_tile)
					tile.add_cliff(biome_data.bottom_cliff)
					tile.set_rect(Rect2(0, 0, 304, 204))
			tile.update()


func get_tile(x: int, y: int):
	if y < 0 or y > image.get_height():
		return null
	if x < 0 or x > image.get_width():
		return null
	return tile_pool.get_child(y*image.get_width() + x)


func init_tile(x: int, y: int):
	# Implement tile setting
	var tile = land_tile.instantiate()
	return tile.init(3, false)


func fuzz_image():
	# Implement image fuzzing
	return


func update():
	return


func get_image():
	return image
