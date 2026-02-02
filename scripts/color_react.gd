extends ColorRect

var threshold = 0.0:
	set(value):
		threshold = value
		material.set_shader_parameter("progress", threshold)

func _ready() -> void:
	var fade_in = get_tree().create_tween()
	threshold = 1.0
	fade_in.tween_property(self, "threshold", 0.0, 0.5)
