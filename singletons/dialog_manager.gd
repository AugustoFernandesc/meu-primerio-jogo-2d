extends Node

@onready var dialog_box_scene = preload("res://entities/interactables/dialog_box.tscn")

func start_message(pos: Vector2, lines: Array[String]):
	if get_tree().current_scene.find_child("DialogBoxInstance", true, false):
		return
	var box = dialog_box_scene.instantiate()
	box.name = "DialogBoxInstance"
	box.message_lines = lines
	box.global_position = pos
	get_tree().current_scene.add_child(box)
