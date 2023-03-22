extends Camera2D

@export var speed: int = 10


func _process(_delta):
	var direction = Vector2(
		Input.get_action_strength("pan_right") - Input.get_action_strength("pan_left"),
		Input.get_action_strength("pan_down") - Input.get_action_strength("pan_up")
	)
	
	offset += direction.normalized() * speed

# zoom inputs
func _input(event):
	# zoom increments by 0.1 + 10% of current zoom
	
	if event.is_action_pressed("zoom_in"):
		zoom = zoom + Vector2(0.1,0.1) + (0.10 * zoom)
	if event.is_action_pressed("zoom_out"):
		zoom = zoom - Vector2(0.1,0.1) - (0.10 * zoom)
		
	zoom = zoom.clamp(Vector2(0.5,0.5), Vector2(3.0,3.0))
		
