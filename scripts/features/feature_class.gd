extends Node
class_name Feature

# Describes how to place objects within a region

@export var total: int = 10
@export var radius: int = 20
@export var objects: Array = []

func spread_objects(polygon, bounds):
	var count = []
	while count.size() <= total:
		var object = objects.pick_random()
		var x = randi_range(bounds[0].x, bounds[1].x)
		var y = randi_range(bounds[0].y, bounds[1].y)
		var point = Vector2(x, y)
		if !Geometry2D.is_point_in_polygon(point, polygon) or is_overlapping(point, radius, count):
			continue
		var sprite = Sprite2D.new()
		sprite.texture = object
		sprite.position = point
		count.append(sprite)
		self.add_child(sprite)

func form_triangles(polygon, indices):
	var triangles = []
	if indices.size() != 0:
		for i in range(indices.size()/3):
			var triangle = PackedVector2Array(
				[
					polygon[indices[i]],
					polygon[indices[i+1]],
					polygon[indices[i+2]]
				]
			)
			triangles.append(triangle)
	return(triangles)

func is_overlapping(position: Vector2, radius: int, others):
	for o in others:
		if position.distance_to(o.position) < radius:
			return true
	return false

