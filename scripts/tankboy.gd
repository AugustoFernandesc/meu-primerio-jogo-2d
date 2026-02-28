extends CharacterBody2D

const BOMB = preload("uid://c6segkipgnt5")
const MISSILE = preload("uid://bq058f8rijoug")

@export_group("Phase Settings")
@export var boss_phase: int = 1 
@export var boss_instance : PackedScene

var health: int = 3
var max_missiles: int = 4
var max_bombs: int = 3
var current_speed: float = 14000.0

var direction: int = -1
var turn_count: int = 0
var missile_count: int = 0
var bomb_count: int = 0
var can_launch_missile: bool = true
var can_launch_bomb: bool = true
var player_can_hit: bool = false
var is_dead: bool = false

@onready var anim_tree: AnimationTree = $anim_tree
@onready var state_machine = anim_tree["parameters/playback"]
@onready var sprite: Sprite2D = $sprite
@onready var wall_detector: RayCast2D = $wall_detector
@onready var missile_point: Marker2D = %missile_point
@onready var bomb_point: Marker2D = %bomb_point
@onready var hitbox_2: Area2D = $hitbox2

func _ready() -> void:
	setup_boss_difficulty()
	set_physics_process(false)

func setup_boss_difficulty():
	if boss_phase == null: boss_phase = 1
	health = 2 + boss_phase 
	max_missiles = 3 + boss_phase 
	max_bombs = 2 + boss_phase 
	current_speed = 13500.0 + (boss_phase * 1000.0)

func _physics_process(delta: float) -> void:
	if is_dead: return

	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1
		turn_count += 1
	
	var current_node = state_machine.get_current_node()
	
	match current_node:
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
	if is_dead: return

	if turn_count <= 2:
		anim_tree.set("parameters/conditions/can_move", true)
		anim_tree.set("parameters/conditions/time_missile", false)
		anim_tree.set("parameters/conditions/time_bomb", false)
		anim_tree.set("parameters/conditions/is_vunerable", false)
	elif missile_count < max_missiles:
		anim_tree.set("parameters/conditions/can_move", false)
		anim_tree.set("parameters/conditions/time_missile", true)
	elif bomb_count < max_bombs:
		anim_tree.set("parameters/conditions/time_missile", false)
		anim_tree.set("parameters/conditions/time_bomb", true)
	else:
		anim_tree.set("parameters/conditions/time_bomb", false)
		anim_tree.set("parameters/conditions/is_vunerable", true)

func take_damage():
	if is_dead: return
	health -= 1
	start_damage_flash()
	
	if health <= 0:
		is_dead = true
		state_machine.travel("death")
		await get_tree().create_timer(0.2).timeout
		create_lose_boss()
	else:
		reset_boss_cycle()

func reset_boss_cycle():
	turn_count = 0
	missile_count = 0
	bomb_count = 0
	player_can_hit = false
	can_launch_missile = true
	can_launch_bomb = true
	anim_tree.set("parameters/conditions/is_vunerable", false)
	anim_tree.set("parameters/conditions/time_bomb", false)
	anim_tree.set("parameters/conditions/time_missile", false)
	anim_tree.set("parameters/conditions/can_move", true)

func start_damage_flash():
	var tween = create_tween()
	sprite.modulate = Color(10, 10, 10, 1)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.2)

func launch_missile():
	var missile_instance = MISSILE.instantiate()
	missile_instance.SPEED = 210.0 + (boss_phase * 40.0)
	add_sibling(missile_instance)
	missile_instance.global_position = missile_point.global_position
	missile_instance.set_direction(direction)
	$missile_cooldown.start()
	missile_count += 1

func throw_bomb():
	var bomb_instance = BOMB.instantiate()
	add_sibling(bomb_instance)
	bomb_instance.global_position = bomb_point.global_position
	var arena_width = 220.0 + ((boss_phase - 1) * 40.0) 
	var impulse_x = randi_range(direction * (arena_width * 0.7), direction * (arena_width * 1.1))
	var impulse_y = randi_range(-250, -320)
	bomb_instance.apply_impulse(Vector2(impulse_x, impulse_y))
	$bomb_cooldown.start()
	bomb_count += 1

func create_lose_boss():
	is_dead = true
	velocity = Vector2.ZERO
	if hitbox_2.is_connected("body_entered", _on_hitbox_body_entered):
		hitbox_2.disconnect("body_entered", _on_hitbox_body_entered)
	$hitbox/CollisionShape2D.set_deferred("disabled", true)
	for child in hitbox_2.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", true)

	set_collision_layer_value(1, true) 
	set_collision_mask_value(1, true)
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(0.3, 0.3, 0.3, 1), 0.1)
	
	var boss_scene = boss_instance.instantiate()
	get_parent().add_child(boss_scene)
	boss_scene.global_position = global_position - Vector2(0, 30)
	
	# --- CORREÇÃO DA MÚSICA AQUI ---
	if has_node("/root/MusicPlayer"):
		MusicPlayer.stop_boss_music() # Usando a função que já criamos no MusicPlayer
	
	Globals.boss_defeated.emit()

func _on_bomb_cooldown_timeout() -> void:
	can_launch_bomb = true

func _on_missile_cooldown_timeout() -> void:
	can_launch_missile = true
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "player" and not is_dead:
		if player_can_hit:
			body.velocity = Vector2(direction * -200, -300)
			take_damage()
		else:
			if body.has_method("go_to_knock_back_state"):
				var push_dir = 1 if body.global_position.x > global_position.x else -1
				body.go_to_knock_back_state(Vector2(push_dir * 300, -200))

func _on_player_detector_body_entered(_body: Node2D) -> void:
	if _body.name == "player" or _body.is_in_group("player"):
		set_physics_process(true)
		if has_node("/root/MusicPlayer"):
			MusicPlayer.start_boss_music()

func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	set_physics_process(true)
