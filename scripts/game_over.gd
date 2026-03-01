extends Control

@onready var game_over_sfx: AudioStreamPlayer = $game_over_sfx

func _ready() -> void:
	if MusicPlayer:
		MusicPlayer.stop_all_music()
	
	game_over_sfx.play()

func _on_restart_btn_pressed() -> void:
	Globals.reset_items_temp()
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
