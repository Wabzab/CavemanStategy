extends MapClass


@export var rage = 09

@onready var txrRect = $TextureRect

var low  = 0.49
var ramp = 0.51
#   high = 1.0


func fuzz_image():
	return


func init_tile(x: int, y: int):
	#var noise_image = noise.noise.get_image(image.get_width(), image.get_height(), false, false, true)
	#var height = noise_image.get_pixel(x, y).r
	var height = 1-image.get_pixel(x, y).r
	var tile = land_tile.instantiate()
	if height <= low:
		tile.set_layer(1)
	elif height <= ramp:
		tile.set_layer(0)
		tile.set_ramp(true)
	else:
		tile.set_layer(0)
	return tile


func update():
	txrRect.texture = get_image()
