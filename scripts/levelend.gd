extends Area2D

@export var next_level = "" 

func _ready() -> void:
	visible = false
	set_deferred("monitoring", false)
	if Globals.has_signal("boss_defeated"):
		Globals.boss_defeated.connect(_on_boss_died)

func _on_boss_died():
	visible = true
	set_deferred("monitoring", true)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# 1. Trava o jogador e limpa checkpoint
		body.set_physics_process(false) 
		Globals.has_checkpoint = false 
		Globals.current_checkpoint_pos = Vector2.ZERO 
		set_deferred("monitoring", false) 
		if Transition.has_method("play_transition"):
			Transition.play_transition()
		await get_tree().create_timer(0.1).timeout
		Globals.player_life = 3
		Globals.player_hp = 5
		Globals.has_ice_cream = false
		var path = "res://scene/" + next_level + ".tscn"
		if FileAccess.file_exists(path):
			get_tree().change_scene_to_file(path)
			Transition.call_deferred("play_open_only")
