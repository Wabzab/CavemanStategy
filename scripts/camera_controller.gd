extends Camera2D

@export var speed: int = 10


func _process(_delta):
	var direction = Vector2(
		Input.get_action_strength("pan_right") - Input.get_action_strength("pan_left"),
		Input.get_action_strength("pan_down") - Input.get_action_strength("pan_up")
	)
	
	offset += direction.normalized() * speed
