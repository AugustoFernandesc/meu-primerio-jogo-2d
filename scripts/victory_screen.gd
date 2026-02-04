extends CanvasLayer

@onready var label_thanks: Label = $VBoxContainer/Label_thanks
@onready var label_coins: Label = $VBoxContainer/Label_coin
@onready var label_time: Label = $VBoxContainer/Label_time
@onready var label_score: Label = $VBoxContainer/Label_score
@onready var btn_menu: Button = $VBoxContainer/btn_menu

func _ready():
	label_thanks.visible = false
	label_coins.visible = false
	label_time.visible = false
	label_score.visible = false
	btn_menu.visible = false
	display_victory_sequence()

func display_victory_sequence():
	Globals.is_timer_active = false
	
	# 1. Mensagem de agradecimento
	label_thanks.visible = true
	await get_tree().create_timer(1.0).timeout
	label_thanks.text = "Zenith finalmente sente o abraco gelado do seu lar."
	await get_tree().create_timer(2.5).timeout
	label_thanks.text = "O inverno nunca foi tado acolhedor."
	await get_tree().create_timer(2.5).timeout
	label_thanks.text = "Obrigado por guiar nosso pinguim de volta para casa!"
	await get_tree().create_timer(2.5).timeout
	label_thanks.visible = false
	
	# 2. Moedas
	await get_tree().create_timer(1.0).timeout
	label_coins.text = "Moedas coletadas: " + str(Globals.coins)
	label_coins.visible = true
	
		# 4. Tempo
	await get_tree().create_timer(1.0).timeout
	label_time.text = "Tempo de Jogo: " + format_time(Globals.time_elapsed)
	label_time.visible = true
	
	# 3. Score
	await get_tree().create_timer(1.0).timeout
	label_score.text = "Score Final: " + str(Globals.score)
	label_score.visible = true

	# 5. Botão para sair
	await get_tree().create_timer(1.5).timeout
	btn_menu.visible = true

func format_time(time_seconds: float) -> String:
	var total_seconds = int(time_seconds)
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	if hours > 0:
		return "%02d:%02d:%02d" % [hours, minutes, seconds]
	else:
		return "%02d:%02d" % [minutes, seconds]

func _on_quit_pressed() -> void:
	Globals.reset_game()
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
