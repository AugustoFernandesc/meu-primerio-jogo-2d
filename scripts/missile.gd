extends AnimatableBody2D

const SPEED = 150.0
const EXPLOSION = preload("uid://k8vab88hr531")
var velocity = Vector2.ZERO
var direction 

@onready var sprite: Sprite2D = $sprite
@onready var collision_missile: CollisionShape2D = $collision
@onready var collision: CollisionShape2D = $hitbox/CollisionShape2D

func _process(delta: float) -> void:
	# Movimentação do míssil
	velocity.x = SPEED * direction * delta
	move_and_collide(velocity)

func set_direction(dir):
	direction = dir
	if direction == 1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	# 1. Checa se o corpo que entrou é o Player guardado no Globals
	if body == Globals.player:
		if body.has_method("go_to_knock_back_state"):
			# Calcula a direção do empurrão baseado na posição do míssil
			var push_dir = 1 if body.global_position.x > global_position.x else -1
			body.go_to_knock_back_state(Vector2(push_dir * 150, -150))

	# 2. Lógica da Explosão
	visible = false
	var explosion_instance = EXPLOSION.instantiate()
	# Adiciona a explosão na cena principal para ela não sumir junto com o míssil
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = global_position
	
	# Desativa as colisões imediatamente para evitar múltiplos acertos
	collision_missile.set_deferred("disabled", true)
	collision.set_deferred("disabled", true)
	
	# 3. Espera a animação de explosão acabar para deletar o míssil
	if explosion_instance.has_signal("animation_finished"):
		await explosion_instance.animation_finished
	
	queue_free()
