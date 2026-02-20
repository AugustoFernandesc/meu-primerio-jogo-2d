extends Area2D

@export var next_level = ""          # Nome do arquivo (ex: winter_world)
@export var level_name_display = ""  # Nome que aparece na tela (ex: Mundo de Gelo)
@export var next_chapter: int = 2    # Número do capítulo

func _ready() -> void:
	visible = false
	set_deferred("monitoring", false)
	Globals.boss_defeated.connect(_on_boss_died)

func _on_boss_died():
	visible = true
	set_deferred("monitoring", true)
	print("Boss derrotado! Sushi liberado.")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# 1. Trava o Zenith para ele não sair andando
		body.set_physics_process(false) 
		
		Globals.has_checkpoint = false 
		Globals.current_checkpoint_pos = Vector2.ZERO 
		set_deferred("monitoring", false) 

		# 2. DEFINIR O NOME QUE VAI APARECER
		# Se você não digitar nada no level_name_display, ele usa o nome do arquivo
		var texto_da_tela = level_name_display
		if texto_da_tela == "":
			texto_da_tela = next_level.capitalize()

		# 3. CHAMA A TRANSIÇÃO (Fecha o círculo e mostra o texto)
		Transition.play_transition(next_chapter, texto_da_tela)
		
		# 4. ESPERA o tempo do círculo fechar (0.5s) antes de trocar a cena
		await get_tree().create_timer(0.5).timeout
		
		# 5. CARREGA A PRÓXIMA FASE (No escuro)
		load_next_scene()
		
		# Reseta status para o próximo level
		Globals.player_life = 3
		Globals.player_hp = 5
		Globals.has_ice_cream = false

func load_next_scene():
	var path = "res://scene/" + next_level + ".tscn"
	get_tree().change_scene_to_file(path)
