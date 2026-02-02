extends Area2D

@onready var transition: CanvasLayer = $transition
@export var next_level = ""

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Globals.has_checkpoint = false 
		Globals.current_checkpoint_pos = Vector2.ZERO 
		set_deferred("monitoring", false) 
		await transition.change_scene()
		await get_tree().create_timer(0.4).timeout
		load_next_scene()

func load_next_scene():
	get_tree().change_scene_to_file("res://scene/" + next_level + ".tscn")
