extends MarginContainer

@onready var menu_sfx: AudioStreamPlayer = $menu_sfx

func _ready() -> void:
	if MusicPlayer.has_method("stop_all"):
		MusicPlayer.stop_all()
	menu_sfx.play()
	Globals.is_timer_active = false

func _on_play_pressed() -> void:
	# 1. Garante que o círculo comece aberto e feche
	Transition.color_rect.visible = true
	Transition.color_rect.material.set_shader_parameter("progress", 0.0)
	
	var tween = create_tween()
	tween.tween_property(Transition.color_rect.material, "shader_parameter/progress", 1.0, 0.5)
	await tween.finished
	Globals.reset_game()
	Globals.items_collect.clear()
	get_tree().change_scene_to_file("res://scene/grassland.tscn")
	Transition.call_deferred("play_open_only")


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_control_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/image_control.tscn")
