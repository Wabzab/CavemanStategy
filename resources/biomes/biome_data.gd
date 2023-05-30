extends Resource


@export var land_tile: Texture2D
@export var cliff_tile: Texture2D

var default_land = null
var default_cliff = null

func _init(p_land = default_land, p_cliff = default_cliff):
	land_tile = p_land
	cliff_tile = p_cliff
