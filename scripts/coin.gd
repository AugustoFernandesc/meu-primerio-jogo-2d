extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass

func _on_body_entered(_body: Node2D) -> void:
	anim.play("collect")

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "collect":
		queue_free()
