extends CanvasLayer

@onready var resume: Button = $menu_holder/resume

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		visible = true
		get_tree().paused = true

func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
