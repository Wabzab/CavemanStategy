extends Node2D
class_name TileClass

@export var tile_width: int = 304
@export var tile_height: int = 304
@export var features: Node2D = Node2D.new()

var layer = 0
var ramp = false


func _init(layer_in: int, ramp_in: bool):
	layer = layer_in
	ramp = ramp_in


func _ready():
	self.add_child(features)
	_update()


func _update():
	pass


func add_feature(new_feature: PackedScene):
	var feature = new_feature.instantiate()
	feature.spread_objects()
	features.add_child(feature)


func get_layer(): return layer


func is_ramp(): return ramp
