extends Area2D

@onready var transition: CanvasLayer = $transition
@export var next_level = ""

func _ready() -> void:
	# 1. Começa o level escondido e sem detectar o player
	visible = false
	set_deferred("monitoring", false)
	
	# 2. Conecta ao sinal global que criamos no Globals.gd
	Globals.boss_defeated.connect(_on_boss_died)

# Esta função roda quando o Tankboy emite o sinal
func _on_boss_died():
	visible = true
	set_deferred("monitoring", true)
	# Opcional: Você pode tocar um som ou efeito aqui para avisar que o Sushi apareceu
	print("Boss derrotado! Sushi liberado.")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Globals.has_checkpoint = false 
		Globals.current_checkpoint_pos = Vector2.ZERO 
		set_deferred("monitoring", false) 
		await transition.change_scene()
		await get_tree().create_timer(0.4).timeout
		load_next_scene()
		Globals.player_life = 3
		Globals.player_hp = 5
		Globals.has_ice_cream = false

func load_next_scene():
	get_tree().change_scene_to_file("res://scene/" + next_level + ".tscn")
