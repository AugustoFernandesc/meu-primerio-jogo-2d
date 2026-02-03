extends Node2D

@onready var area_sign: Area2D = $area_sign

const lines: Array[String] = [
	"BEM-VINDO, ZENITH!",
	"[A][D] ou [SETAS]: Mover",
	"[W] ou [ESPAÇO]: Pular (2x para Pulo Duplo)",
	"[S] (em movimento): Slide / Deslizar",
	"[S] (parado): Agachar",
]

func _unhandled_input(event: InputEvent) -> void:
	if area_sign.get_overlapping_bodies().size() > 0:
		if event.is_action_pressed("interact"): 
			DialogManager.start_message(global_position, lines)
