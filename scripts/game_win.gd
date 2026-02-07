extends Area2D

func _ready() -> void:
	hide()
	Globals.boss_defeated.connect(on_boss_victory)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("go_to_victory_dance") and body.status != body.player_state.victory_dance:
		body.go_to_victory_dance()
		var player_anim = body.get_node("AnimatedSprite2D")
		await player_anim.animation_finished
		player_anim.play("victory_dance")
		await player_anim.animation_finished
		get_tree().change_scene_to_file("res://ui/victory_screen.tscn")

func on_boss_victory():
	await get_tree().create_timer(2.0).timeout
	show()
