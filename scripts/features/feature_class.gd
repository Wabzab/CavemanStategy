extends Node
class_name Feature

# Describes how to place objects within a region

@export var total: int = 10
@export var radius: int = 10
@export var resources: Array = []


func spread_resource(bounds):
	var others = []
	while others.size() < total:
		var half_x = bounds.x/2
		var half_y = bounds.y/2
		var x = randi_range(-half_x+radius, half_x-radius)
		var y = randi_range(-half_y+radius, half_y-radius)
		var position = Vector2(x, y)
		if is_overlapping(position, radius, others):
			continue
		var texture: Texture2D = resources.pick_random()
		var new_res = Sprite2D.new()
		new_res.z_index = 1
		new_res.texture = texture
		new_res.position = position
		others.append(new_res)
		add_child(new_res)


func is_overlapping(position: Vector2, radius: int, others):
	for o in others:
		if position.distance_to(o.position) < (radius+radius):
			return true
	return false

