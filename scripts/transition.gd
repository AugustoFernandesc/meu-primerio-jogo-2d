extends CanvasLayer

@onready var color_rect: ColorRect = $color_react

func change_scene() -> void:
	var scene_transition = get_tree().create_tween()
	scene_transition.tween_property(color_rect, "threshold", 1.0, 0.5)
	await scene_transition.finished
