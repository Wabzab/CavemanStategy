extends Resource


@export var land_tile: Texture2D
@export var cliff_tile: Texture2D
@export var left_cliff: PackedScene
@export var right_cliff: PackedScene
@export var top_cliff: PackedScene
@export var bottom_cliff: PackedScene
@export var forest_feature: PackedScene
@export var rock_feature: PackedScene
@export var grass_feature: PackedScene

var default_land = null
var default_cliff = null
var default_forest = null
var default_rock = null
var default_grass = null

func _init(p_land = default_land, p_cliff = default_cliff, p_forest = default_forest, p_rock = default_rock, p_grass = default_grass):
	land_tile = p_land
	cliff_tile = p_cliff
	left_cliff = p_cliff
	right_cliff = p_cliff
	top_cliff = p_cliff
	bottom_cliff = p_cliff
	forest_feature = p_forest
	rock_feature = p_rock
	grass_feature = p_grass
