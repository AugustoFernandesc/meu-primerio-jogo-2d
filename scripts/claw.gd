extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

var speed = 200 
var direction = 1
var already_hit = false 

func _process(delta: float) -> void:
	position.x += speed * delta * direction

func set_direction(crab_direction):
	direction = crab_direction
	if sprite:
		sprite.flip_h = (direction == 1)

func _on_self_destruction_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body):
	if already_hit: return
	
	if body.is_in_group("player") or body.name == "Player":
		already_hit = true
		var force_x = direction * 250
		var direction_push = Vector2(force_x, -150) 
		
		if body.has_method("go_to_knock_back_state"):
			body.go_to_knock_back_state(direction_push)
		
		call_deferred("queue_free")

func _on_area_entered(_area: Area2D) -> void:
	if not already_hit:
		already_hit = true
		queue_free()
