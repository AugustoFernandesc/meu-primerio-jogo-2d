extends Control

func _ready() -> void:
	MusicPlayer.stop()

func _on_restart_btn_pressed() -> void:
	Globals.reset_items_temp()
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
