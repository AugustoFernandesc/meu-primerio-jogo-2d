extends Area2D

@export var next_level: String = "" 

func _ready() -> void:
	visible = false
	monitoring = false
	# Conexão robusta para evitar que o sinal se perca no carregamento
	if Globals.is_connected("boss_defeated", _on_boss_died):
		Globals.boss_defeated.disconnect(_on_boss_died)
	Globals.boss_defeated.connect(_on_boss_died)

func _on_boss_died():
	visible = true
	monitoring = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# 1. Trava o jogador IMEDIATAMENTE para ele não cair do mapa
		body.process_mode = Node.PROCESS_MODE_DISABLED
		
		# 2. Reseta os dados globais
		Globals.has_checkpoint = false 
		Globals.current_checkpoint_pos = Vector2.ZERO 
		Globals.player_life = 3
		Globals.player_hp = 5
		Globals.has_ice_cream = false
		
		# 3. Inicia Transição (Damos 0.5s para a tela cobrir tudo)
		if Transition.has_method("play_transition"):
			Transition.play_transition()
			await get_tree().create_timer(0.5).timeout
		
		# 4. Troca de Cena Segura (Verifica se o arquivo existe antes de tentar carregar)
		var full_path = "res://scene/" + next_level + ".tscn"
		
		if ResourceLoader.exists(full_path):
			get_tree().change_scene_to_file(full_path)
		else:
			# Se o caminho estiver errado, avisa o console e destrava o player (pro jogo não morrer)
			print("ERRO CRÍTICO: Caminho não encontrado no Celular: ", full_path)
			body.process_mode = Node.PROCESS_MODE_INHERIT
