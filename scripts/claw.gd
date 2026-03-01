extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

var speed = 200 
var direction = 1
var already_hit = false 

func _process(delta: float) -> void:
	if already_hit: return
	position.x += speed * delta * direction

func set_direction(crab_direction):
	direction = crab_direction
	if sprite:
		sprite.flip_h = (direction == 1)

func _on_self_destruction_timer_timeout() -> void:
	queue_free()

func _on_impact(_target):
	if already_hit: return
	already_hit = true
	queue_free()

func _on_body_entered(body):
	if already_hit: return
	
	# 1. Se bater no Player
	if body.is_in_group("player") or body.name == "Player":
		if body.global_position.y < global_position.y - 10: 
			_on_impact(body)
			return
			
		var force_x = direction * 250
		var direction_push = Vector2(force_x, -150) 
		
		if body.has_method("go_to_knock_back_state"):
			body.go_to_knock_back_state(direction_push)
		
		_on_impact(body)
	
	# 2. SE BATER NO CENÁRIO (Paredes ou Chão na Layer 1)
	# Isso evita que ele fique "correndo" parado na parede
	else:
		_on_impact(null)

func _on_area_entered(_area: Area2D) -> void:
	_on_impact(null)
