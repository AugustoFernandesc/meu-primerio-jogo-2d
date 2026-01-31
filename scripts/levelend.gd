extends Area2D

@export var next_level = ""

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		# CORREÇÃO: Usamos a nova flag que criamos no Globals
		Globals.has_checkpoint = false 
		# Opcional: Se você quiser garantir que a posição também resete
		Globals.current_checkpoint_pos = Vector2.ZERO 
		
		call_deferred("load_next_scene")

func load_next_scene():
	# Verifique se a pasta é 'scene' ou 'scenes' no seu projeto
	get_tree().change_scene_to_file("res://scene/" + next_level + ".tscn")
