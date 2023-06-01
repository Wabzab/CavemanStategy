extends TileClass

@export var total = 5
@export var textures: Array = [null]


func _update():
	add_grass()


func add_grass():
	var others = []
	var half_width = self.tile_width/2
	var half_height = self.tile_height/2
	
	while others.size() <= total:
		var texture = textures.pick_random()
		var x = randi_range(-half_width, half_width)
		var y = randi_range(-half_height, half_height)
		var point = Vector2(x, y)
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.position = point
		others.append(sprite)
		self.add_child(sprite)
