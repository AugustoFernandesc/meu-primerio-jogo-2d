extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if Globals.player_life == 3 and Globals.player_hp == 3:
			return 
		if Globals.player_hp >= 3:
			Globals.player_life += 1
			Globals.player_hp = 1
			coletar_item()
		else:
			Globals.player_hp += 1
			coletar_item()

func coletar_item():
	$CollisionShape2D.set_deferred("disabled", true)
	if anim.sprite_frames.has_animation("collected"):
		anim.play("collected")
	else:
		queue_free()

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
