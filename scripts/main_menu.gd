extends MarginContainer

@onready var menu_sfx: AudioStreamPlayer = $menu_sfx

func _ready() -> void:
	if MusicPlayer.has_method("stop_all"):
		MusicPlayer.stop_all()
	menu_sfx.play()
	Globals.is_timer_active = false

func _on_play_pressed() -> void:
	# 1. Primeiro, fechamos o círculo (fundo fica preto)
	var tween = create_tween()
	# Note que usamos 'progress' porque é o nome no seu shader!
	# Se o seu código usa 'threshold', troque 'progress' por 'threshold'
	Transition.color_rect.visible = true
	tween.tween_property(Transition.color_rect.material, "shader_parameter/progress", 1.0, 0.5)
	
	# 2. Esperamos o círculo fechar totalmente
	await tween.finished
	
	# 3. Agora sim mudamos a cena (ninguém vai ver o mapa carregando)
	Globals.reset_game()
	Globals.items_collect.clear()
	get_tree().change_scene_to_file("res://scene/grassland.tscn")
	
	# 4. Chamamos a parte do texto e de abrir
	Transition.play_transition(1, "Grassland")


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_control_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/image_control.tscn")
