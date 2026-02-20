extends CanvasLayer

@onready var resume: Button = $menu_holder/resume

func _ready() -> void:
	visible = false

# Essa função mágica detecta eventos do sistema (como minimizar o app)
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		# Se o jogo não estiver no menu principal e o app for minimizado, pausa!
		pausar_jogo()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		if not visible:
			pausar_jogo()
		else:
			despausar_jogo()

func pausar_jogo() -> void:
	visible = true
	get_tree().paused = true
	# Dica: se tiver botões, é bom dar um grab_focus no resume para facilitar
	resume.grab_focus()

func despausar_jogo() -> void:
	get_tree().paused = false
	visible = false

func _on_resume_pressed() -> void:
	despausar_jogo()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
