extends Feature


func spread_resource(bounds):
	var others = []
	var fails = 0
	while others.size() < total or fails > 100:
		var half_x = bounds.x/2
		var half_y = bounds.y/2
		var x = randi_range(-half_x+radius, half_x-radius)
		var y = randi_range(-half_y+radius, half_y-radius)
		var position = Vector2(x, y)
		if is_overlapping(position, radius, others):
			fails += 1
			continue
		var texture: Texture2D = resources.pick_random()
		var new_res = Sprite2D.new()
		new_res.z_index = 1
		#new_res.offset.y = -texture.get_height()+10
		new_res.texture = texture
		new_res.position = position
		others.append(new_res)
		print(new_res.global_position, new_res.position)
		add_child(new_res)
