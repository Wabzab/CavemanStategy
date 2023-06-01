extends Resource


@export var land_tile: Texture2D
@export var cliff_tile: Texture2D
@export var forest_feature: Resource
@export var rock_feature: Resource

var default_land = null
var default_cliff = null
var default_forest = null
var default_rock = null

func _init(p_land = default_land, p_cliff = default_cliff, p_forest = default_forest, p_rock = default_rock):
	land_tile = p_land
	cliff_tile = p_cliff
	forest_feature = p_forest
	rock_feature = p_rock
