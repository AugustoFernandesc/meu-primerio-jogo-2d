extends Area2D

# Referência à colisão do StaticBody que está dentro da Area
# Se você não quiser usar StaticBody, pode ignorar essa parte e apenas 
# usar o bloco como um "sensor"
@onready var physics_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D2

func _ready() -> void:
	# Igualzinho ao seu LevelEnd
	visible = false
	set_deferred("monitoring", false)
	# Se tiver um StaticBody dentro, desligamos a colisão física também
	if physics_collision:
		physics_collision.set_deferred("disabled", true)
		
	Globals.boss_defeated.connect(_on_boss_died)

func _on_boss_died():
	visible = true
	set_deferred("monitoring", true)
	# Liga a colisão física para o Zenith poder pisar
	if physics_collision:
		physics_collision.set_deferred("disabled", false)
	
	# Um efeitinho de fade para ficar bonito
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	print("Bloco Area2D ativado com sucesso!")
