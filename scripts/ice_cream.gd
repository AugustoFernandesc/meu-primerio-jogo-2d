extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		Globals.has_ice_cream = true
		queue_free()
