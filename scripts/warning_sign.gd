extends Node2D

@onready var area_sign: Area2D = $area_sign

@export var lines: Array[String] = []

func _unhandled_input(event: InputEvent) -> void:
	if area_sign.get_overlapping_bodies().size() > 0:
		if event.is_action_pressed("interact"): 
			DialogManager.start_message(global_position, lines)
