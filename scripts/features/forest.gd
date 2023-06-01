extends Feature


func spread_objects(polygon, bounds):
	var others = []
	while others.size() <= total:
		var object = objects.pick_random()
		var x = randi_range(bounds[0].x, bounds[1].x)
		var y = randi_range(bounds[0].y, bounds[1].y)
		var point = Vector2(x, y)
		if !Geometry2D.is_point_in_polygon(point, polygon) or is_overlapping(point, radius, others):
			continue
		var sprite = Sprite2D.new()
		sprite.texture = object
		sprite.position = point
		others.append(sprite)
		self.add_child(sprite)
