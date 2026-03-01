extends CharacterBody2D

var move_speed = 200
var direction = 1
var active = true 

func _physics_process(delta: float) -> void:
	if not active: return
	
	var velocity_vec = Vector2(move_speed * direction * delta, 0)
	
	var collision = move_and_collide(velocity_vec)
	
	if collision:
		_on_impact(collision.get_collider())

func _on_impact(target):
	if not active: return 
	active = false
	
	if target.is_in_group("player") or target.name == "player":
		if target.has_method("take_damage"):
			target.take_damage()
	queue_free()

func _on_lethal_area_body_entered(body: Node2D) -> void:
	if active and (body.is_in_group("player") or body.name == "player"):
		_on_impact(body)

func set_direction(dir):
	direction = dir
	if has_node("anim"):
		$anim.flip_h = (dir < 0)
	elif has_node("sprite"):
		$sprite.flip_h = (dir < 0)


func _on_self_destruction_timer_timeout() -> void:
	queue_free()
