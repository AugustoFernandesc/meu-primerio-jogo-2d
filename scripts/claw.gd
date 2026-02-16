extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

var speed = 0 # Pode aumentar um pouco para dar mais desafio
var direction = 1

func _process(delta: float) -> void:
	# Move a garra na horizontal
	position.x += speed * delta * direction

func set_direction(crab_direction):
	direction = crab_direction
	# Se a garra nascer olhando para o lado errado, 
	# mude o '>' para '<' na linha abaixo
	if sprite:
		sprite.flip_h = direction > 0

func _on_self_destruction_timer_timeout() -> void:
	queue_free()

func _on_area_entered(_area: Area2D) -> void:
	# Se bater na hitbox do player (que deve ser uma Area2D)
	queue_free()


func _on_body_entered(_body: Node2D) -> void:
	# Se bater no pinguim (CharacterBody2D) ou no chão
	queue_free()
