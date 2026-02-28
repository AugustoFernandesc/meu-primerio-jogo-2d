extends CharacterBody2D

@onready var sprite: Sprite2D = $sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fireball_spawn_point: Marker2D = $fireball_spawn_point
@onready var ground_detector: RayCast2D = $ground_detector
@onready var player_detector: RayCast2D = $player_detector

enum enemy_state { patrol, attack, hurt }
var current_state = enemy_state.patrol

var move_speed = 45
var direction = 1
var health_point = 2
const FIREBALL = preload("uid://dhpxoxp47ldow")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Gerencia os estados
	match(current_state):
		enemy_state.patrol: 
			patrol_state()
		enemy_state.attack: 
			attack_state()
		enemy_state.hurt:
			velocity.x = 0
	
	move_and_slide()

func patrol_state():
	animation_player.play("running")
	if is_on_wall() or not ground_detector.is_colliding():
		flip_enemy()
		
	velocity.x = move_speed * direction 
	
	if player_detector.is_colliding():
		current_state = enemy_state.attack

func attack_state():
	animation_player.play("shooting")
	velocity.x = 0 # Para de andar para atirar
	if not player_detector.is_colliding():
		current_state = enemy_state.patrol

func take_damage():
	if current_state == enemy_state.hurt: return
	
	current_state = enemy_state.hurt
	health_point -= 1
	apply_damage_tween()
	if health_point <= 0:
		animation_player.play("hurt")
		await animation_player.animation_finished
		queue_free()
	else:
		animation_player.play("hurt")
		await animation_player.animation_finished
		current_state = enemy_state.patrol

func flip_enemy():
	direction *= -1
	sprite.scale.x *= -1
	player_detector.scale.x *= -1
	fireball_spawn_point.position.x *= -1

func spawn_fireball():
	var new_fireball = FIREBALL.instantiate()
	# Usa a direção do dragão para a bola de fogo
	new_fireball.set_direction(direction)
	add_sibling(new_fireball)
	new_fireball.global_position = fireball_spawn_point.global_position

func apply_damage_tween():
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		take_damage()
