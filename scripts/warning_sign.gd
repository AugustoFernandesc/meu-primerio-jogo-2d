extends Node2D

@onready var area_sign: Area2D = $area_sign

const lines: Array[String] = [
	"Seja bem-vindo!",
	"Tente nao morrer",
	"no primeiro buraco.",
]

func _unhandled_input(event: InputEvent) -> void:
	if area_sign.get_overlapping_bodies().size() > 0:
		if event.is_action_pressed("interact"): 
			DialogManager.start_message(global_position, lines)
