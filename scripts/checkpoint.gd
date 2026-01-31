extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if Globals.has_checkpoint and Globals.current_checkpoint_pos == global_position:
		anim.play("checked")
	else:
		anim.play("idle")

func _on_body_entered(body: Node2D) -> void:
	if body.name.to_lower() == "player" or body.is_in_group("player"):
		if not Globals.has_checkpoint or Globals.current_checkpoint_pos != global_position:
			Globals.current_checkpoint_pos = global_position
			Globals.has_checkpoint = true
			anim.play("active")

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "active":
		anim.play("checked")
