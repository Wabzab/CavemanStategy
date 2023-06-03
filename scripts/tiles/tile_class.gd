extends Node2D
class_name TileClass

@export var width: int = 304
@export var height: int = 304
@export var rect: Rect2 = Rect2(0, 0, 304, 304)
@export var base: Sprite2D = Sprite2D.new()
@export var cliffs: Node2D = Node2D.new()
@export var features: Node2D = Node2D.new()

var layer = 3
var ramp = false


func init(layer_in: int, ramp_in: bool):
	layer = layer_in
	ramp = ramp_in


func _ready():
	self.add_child(base)
	self.add_child(cliffs)
	self.add_child(features)


func update():
	pass


func add_feature(new_feature: PackedScene):
	var feature = new_feature.instantiate()
	feature.spread_objects()
	features.add_child(feature)


func set_texture(texture_in):
	base.texture = texture_in

func set_rect(rect_in):
	rect = rect_in

func get_layer(): return layer
func set_layer(layer_in): layer = layer_in

func is_ramp(): return ramp
func set_ramp(ramp_in): ramp = ramp_in


func add_cliff(cliff: PackedScene):
	cliffs.add_child(cliff.instantiate())
