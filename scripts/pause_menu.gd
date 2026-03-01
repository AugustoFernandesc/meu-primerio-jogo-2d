extends CanvasLayer

@onready var resume_button: Button = $menu_holder/resume

func _ready() -> void:
	visible = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		pause_game()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		if not visible:
			pause_game()
		else:
			resume_game()

func pause_game() -> void:
	visible = true
	get_tree().paused = true
	resume_button.grab_focus()

func resume_game() -> void:
	get_tree().paused = false
	visible = false

func _on_resume_pressed() -> void:
	resume_game()

func _on_quit_pressed() -> void:
	if MusicPlayer:
		MusicPlayer.stop_all_music()
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
