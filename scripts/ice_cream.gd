extends Area2D

func _ready() -> void:
	# Se o jogador já pegou o sorvete em uma vida anterior,
	# o item nem chega a aparecer na cena.
	if Globals.has_ice_cream:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		Globals.has_ice_cream = true
		# Opcional: Tocar um som de "Power Up" aqui
		queue_free()
