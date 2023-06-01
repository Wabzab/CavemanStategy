extends MapClass


@export var rage = 0

var low  = 0.45
var ramp = 0.55
#   high = 1.0


func fuzz_image():
	return


func init_tile(x: int, y: int):
	var height = image.get_pixel(x, y).r
	var tile = land_tile.instantiate()
	tile.init(1, false)
	if height <= low:
		tile.init(0, false)
	if height <= ramp:
		tile.init(1, true)
	return tile

