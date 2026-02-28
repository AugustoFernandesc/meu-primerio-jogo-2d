extends CharacterBody2D

var move_speed = 170 
var direction = 1
var active = true 

func _process(delta: float) -> void:
	if not active: return
	var collision = move_and_collide(Vector2(move_speed * direction * delta, 0))
	
	if collision:
		var target = collision.get_collider()
		_on_impact(target)

func _on_impact(target):
	if not active: return 
	
	if target.is_in_group("player"):
		if target.has_method("take_damage"):
			target.take_damage()
			active = false 
			queue_free()
	else:
		active = false
		queue_free()

func set_direction(dir):
	direction = dir
	if $anim:
		$anim.flip_h = (dir < 0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and active:
		_on_impact(body)
		queue_free()
