extends Node2D
class_name TileClass

@export var tile_width: int = 100
@export var tile_height: int = 100
@export var base: Sprite2D = Sprite2D.new()
@export var features: Node2D = Node2D.new()

var polygon = [
	Vector2(0, -160),
	Vector2(127, -96),
	Vector2(127, 67),
	Vector2(0, 127),
	Vector2(-127, 67),
	Vector2(-127, -96),
]

func _ready():
	self.add_child(base)
	self.add_child(features)
	_update()

func _update():
	pass

func _set_tile(p_position: Vector2, p_texture: Texture2D):
	self.position = p_position
	base.texture = p_texture

func _add_feature(new_feature: Resource):
	var feature = new_feature.instantiate()
	feature.spread_objects(polygon, [Vector2(-127, -160), Vector2(127, 127)])
	features.add_child(feature)
