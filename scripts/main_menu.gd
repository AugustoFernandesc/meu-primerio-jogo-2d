extends MarginContainer

@onready var menu_sfx: AudioStreamPlayer = $menu_sfx

func _ready() -> void:
	MusicPlayer.stop()
	menu_sfx.play()
	Globals.is_timer_active = false

func _on_play_pressed() -> void:
	Globals.reset_game()
	Globals.items_collect.clear()
	get_tree().change_scene_to_file("res://scene/grassland.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_control_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/image_control.tscn")
