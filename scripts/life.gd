extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var id_single: String
@onready var heal: AudioStreamPlayer = $heal

func _ready() -> void:
	if Globals.items_collect.has(id_single):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if Globals.player_life == 3 and Globals.player_hp == 5:
			return 
		$CollisionShape2D.set_deferred("disabled", true)
		heal.play()
		if Globals.player_hp >= 5:
			if Globals.player_life < 3:
				Globals.player_life += 1
				Globals.player_hp = 1
		else:
			Globals.player_hp += 1
		Globals.items_collect.append(id_single)
		if anim.sprite_frames.has_animation("collected"):
			anim.play("collected")
			await anim.animation_finished
		else:
			visible = false
		if heal.playing:
			await heal.finished
			
		queue_free()

func collect_item():
	$CollisionShape2D.set_deferred("disabled", true)
	if anim.sprite_frames.has_animation("collected"):
		anim.play("collected")
	else:
		queue_free()

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
