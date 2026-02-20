extends CanvasLayer

@onready var color_rect: ColorRect = $color_react
@onready var chapter_label: Label = $chapter
@onready var phase_label: Label = $phase

func play_transition(chapter_num: int, phase_name: String) -> void:
	color_rect.visible = true
	
	# 1. FECHA O CÍRCULO (Caso ele esteja aberto)
	# Se já estiver em 1.0 (preto), o Tween termina na hora.
	var tween_close = create_tween()
	tween_close.tween_property(color_rect.material, "shader_parameter/progress", 1.0, 0.4)
	await tween_close.finished
	
	# Prepara textos (Garanta que estão invisíveis antes de começar)
	chapter_label.text = "Capitulo " + str(chapter_num)
	phase_label.text = phase_name
	chapter_label.modulate.a = 0
	phase_label.modulate.a = 0
	
	# 2. Aparece o texto (Fade in)
	var tween_msg = create_tween()
	tween_msg.tween_property(chapter_label, "modulate:a", 1.0, 0.4)
	tween_msg.parallel().tween_property(phase_label, "modulate:a", 1.0, 0.4)
	await tween_msg.finished
	
	await get_tree().create_timer(1.5).timeout
	
	# 3. Some o texto (Fade out)
	var tween_out = create_tween()
	tween_out.tween_property(chapter_label, "modulate:a", 0.0, 0.3)
	tween_out.parallel().tween_property(phase_label, "modulate:a", 0.0, 0.3)
	await tween_out.finished
	
	# 4. ABRE O CÍRCULO
	var tween_open = create_tween()
	tween_open.tween_property(color_rect.material, "shader_parameter/progress", 0.0, 0.6)
	await tween_open.finished
	
	color_rect.visible = false
