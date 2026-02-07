extends CharacterBody2D

const BOMB = preload("uid://c6segkipgnt5")
const MISSILE = preload("uid://bq058f8rijoug")

@export_group("Configurações de Fase")
@export var boss_phase = 1 # Defina 1 para Grassland, 2 para Tropic, etc. no Inspector
@export var boss_instance : PackedScene

# Atributos que vão mudar conforme a fase
var health = 1 
var max_missiles = 4
var max_bombs = 3
var current_speed = 7000.0

# Variáveis de controle de jogo
var direction = -1
var turn_count = 0
var missile_count = 0
var bomb_count = 0
var can_launch_missile = true
var can_launch_bomb = true
var player_can_hit = false
var is_dead = false

@onready var anim_tree: AnimationTree = $anim_tree
@onready var state_machine = anim_tree["parameters/playback"]
@onready var sprite: Sprite2D = $sprite
@onready var wall_detector: RayCast2D = $wall_detector
@onready var missile_point: Marker2D = %missile_point
@onready var bomb_point: Marker2D = %bomb_point

func _ready() -> void:
	set_physics_process(false)
	setup_boss_difficulty() # Configura o Boss baseado na fase escolhida

func setup_boss_difficulty():
	# Aqui a mágica acontece: escalamos os stats pela fase
	health = 0 + boss_phase          # F1=3, F2=4, F3=5...
	max_missiles = 3 + boss_phase     # F1=4, F2=5, F3=6...
	max_bombs = 2 + boss_phase        # F1=3, F2=4, F3=5...
	current_speed = 10000.0 + (boss_phase * 2000.0) # Fica mais rápido
	
	print("Boss Nível ", boss_phase, " pronto. Vida: ", health)

func _physics_process(delta: float) -> void:
	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1
		turn_count += 1
	
	match state_machine.get_current_node():
		"moving":
			$hitbox/CollisionShape2D.set_deferred("disabled", true)
			velocity.x = direction * current_speed * delta
			sprite.flip_h = (direction == 1)
		"missile_attack":
			velocity.x = 0
			if can_launch_missile:
				can_launch_missile = false
				launch_missile()
		"hide_bomb":
			velocity.x = 0
			if can_launch_bomb:
				can_launch_bomb = false
				throw_bomb()
		"vunerable":
			velocity.x = 0
			player_can_hit = true
			$hitbox/CollisionShape2D.set_deferred("disabled", false)

	update_conditions()
	move_and_slide()

func update_conditions():
	# Lógica da escada usando as novas variáveis max_missiles e max_bombs
	if turn_count <= 2:
		anim_tree.set("parameters/conditions/can_move", true)
		anim_tree.set("parameters/conditions/time_missile", false)
	elif missile_count < max_missiles:
		anim_tree.set("parameters/conditions/can_move", false)
		anim_tree.set("parameters/conditions/time_missile", true)
		anim_tree.set("parameters/conditions/time_bomb", false)
	elif bomb_count < max_bombs:
		anim_tree.set("parameters/conditions/time_missile", false)
		anim_tree.set("parameters/conditions/time_bomb", true)
	else:
		anim_tree.set("parameters/conditions/time_bomb", false)
		anim_tree.set("parameters/conditions/is_vunerable", true)
	
	if health <= 0:
		state_machine.travel("death")

func take_damage():
	if is_dead:
		return
	health -= 1
	start_damage_flash()
	
	if health <= 0:
		is_dead = true
		Globals.score += 500 * boss_phase
		call_deferred("create_lose_boss")
		$hitbox/CollisionShape2D.set_deferred("disabled", true)
	else:
		# Se ele ainda tem vida, ele reseta o ciclo para atacar de novo
		reset_boss_cycle()

func reset_boss_cycle():
	turn_count = 0
	missile_count = 0
	bomb_count = 0
	player_can_hit = false
	# Isso força o Boss a voltar para o estado 'moving'
	anim_tree.set("parameters/conditions/is_vunerable", false)
	anim_tree.set("parameters/conditions/can_move", true)

func start_damage_flash():
	var tween = create_tween()
	sprite.modulate = Color(10, 10, 10, 1) # Brilha branco
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.2)

func launch_missile():
	if missile_count < max_missiles:
		var missile_instance = MISSILE.instantiate()
		add_sibling(missile_instance)
		missile_instance.global_position = missile_point.global_position
		missile_instance.set_direction(direction)
		$missile_cooldown.start()
		missile_count += 1

func throw_bomb():
	if bomb_count < max_bombs:
		var bomb_instance = BOMB.instantiate()
		add_sibling(bomb_instance)
		bomb_instance.global_position = bomb_point.global_position
		bomb_instance.apply_impulse(Vector2(randi_range(direction * 30, direction * 200), randi_range(-200, -400)))
		$bomb_cooldown.start()
		bomb_count += 1

func _on_bomb_cooldown_timeout() -> void:
	can_launch_bomb = true

func _on_missile_cooldown_timeout() -> void:
	can_launch_missile = true

func _on_player_detector_body_entered(_body: Node2D) -> void:
	set_physics_process(true)

func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	set_physics_process(true)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "player":
		if player_can_hit:
			body.velocity = Vector2(direction * -200, -300) # Pequeno pulo do player ao bater
			take_damage()
		else:
			if body.has_method("go_to_knock_back_state"):
				var push_dir = 1 if body.global_position.x > global_position.x else -1
				body.go_to_knock_back_state(Vector2(push_dir * 300, -200))

func create_lose_boss():
	# 1. Desativa as colisões para o player não quicar mais
	$hitbox/CollisionShape2D.set_deferred("disabled", true)
	# Desativa a colisão principal (corpo do tanque) para o player passar por ele
	$collision.set_deferred("disabled", true) 
	
	# 2. Para o processamento do Boss (ele não anda mais nem ataca)
	set_physics_process(false)
	
	# 3. Cria o piloto
	var boss_scene = boss_instance.instantiate()
	get_parent().add_child(boss_scene)
	boss_scene.global_position = global_position - Vector2(0, 30)
	Globals.boss_defeated.emit()
	# NÃO USE visible = false. O tanque vai continuar na tela como destroço.
	# Se quiser, você pode mudar o frame do sprite para um "tanque quebrado".
	# sprite.frame = 10 (exemplo)
