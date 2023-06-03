extends TileClass

@export var total = 5
@export var textures: Array = [null]


func update():
	if layer != 3:
		add_grass()


func add_grass():
	var others = []
	var half_w = self.width/2
	var half_h = self.height/2
	
	while others.size() <= total:
		var texture = textures.pick_random()
		var x = randi_range(-half_w, self.rect.size.x-half_w)
		var y = randi_range(-half_h, self.rect.size.y-half_h)
		var point = Vector2(x, y)
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.position = point
		others.append(sprite)
		self.add_child(sprite)
