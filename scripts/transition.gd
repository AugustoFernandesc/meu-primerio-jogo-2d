extends CanvasLayer

@onready var color_rect: ColorRect = $color_react

func play_open_only() -> void:
	color_rect.visible = true
	color_rect.material.set_shader_parameter("progress", 1.0)
	
	await get_tree().create_timer(0.2).timeout
	var tween_open = create_tween()
	tween_open.tween_property(color_rect.material, "shader_parameter/progress", 0.0, 1.0).set_trans(Tween.TRANS_SINE)
	
	await tween_open.finished
	color_rect.visible = false
