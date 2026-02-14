extends CharacterBody2D

enum player_state{
	idle,
	walk,
	jump,
	fall,
	duck,
	slide,
	wall,
	swimming,
	knock_back,
	victory_dance,
	dead
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var reaload_timer: Timer = $reloadTimer
@onready var hitbox_collision: CollisionShape2D = $hitbox/CollisionShape2D
@onready var left_wall_detector: RayCast2D = $leftWallDetector
@onready var right_wall_detector: RayCast2D = $rightWallDetector
@onready var jump_sfx: AudioStreamPlayer = $jump_sfx
@onready var damage_sfx: AudioStreamPlayer = $damage_sfx
@onready var water_sfx: AudioStreamPlayer = $water_sfx
@onready var ceiling_detector: RayCast2D = $ceiling_detector

@export var max_speed = 110.0
@export var acceleration = 100
@export var deceleration = 100
@export var slide_deceleration = 100
@export var wall_acceleration = 40
@export var wall_jump_velocity = 240
@export var water_max_speed = 100
@export var water_acceleration = 100 
@export var water_jump_force = -100
@export var knockback_vector = Vector2.ZERO

const JUMP_VELOCITY = -300.0
var jump_count = 0
@export var max_jump_count = 2
var direction = 0
var status: player_state
var is_invincible: bool = false

func _ready() -> void:
	Globals.player = self
	is_invincible = false
	if Globals.has_checkpoint:
		await get_tree().process_frame 
		global_position = Globals.current_checkpoint_pos
		print("Player respawnado no checkpoint: ", global_position)
	go_to_idle_state()

func _physics_process(delta: float) -> void:

	match status:
		player_state.idle:
			idle_state(delta)
		player_state.walk:
			walk_state(delta)
		player_state.jump:
			jump_state(delta)
		player_state.fall:
			fall_state(delta)
		player_state.duck:
			duck_state(delta)
		player_state.slide:
			slide_state(delta)
		player_state.wall:
			wall_state(delta)
		player_state.swimming:
			swimming_state(delta)
		player_state.knock_back:
			knock_back_state(delta)
		player_state.victory_dance:
			victory_dance_state(delta)
		player_state.dead:
			dead_state(delta)
	move_and_slide()

func go_to_idle_state():
	status = player_state.idle
	anim.play("idle")

func go_to_walk_state():
	status = player_state.walk
	anim.play("walk")

func go_to_jump_state():
	status = player_state.jump
	anim.play("jump")
	jump_sfx.play()
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_fall_state():
	status = player_state.fall
	anim.play("fall")

func go_to_duck_state():
	status = player_state.duck
	anim.play("duck")
	set_small_collider()

func exit_from_duck_state():
	set_large_collider()

func go_to_slide_state():
	status = player_state.slide
	anim.play("slide")
	set_small_collider()

func exit_from_slide_state():
	set_large_collider()

func go_to_wall_state():
	status = player_state.wall
	anim.play("wall")
	velocity = Vector2.ZERO
	jump_count = 0

func go_to_swimming_state():
	status = player_state.swimming
	anim.play("swimming")
	water_sfx.play()
	velocity.y = min(velocity.y, 50)

func go_to_knock_back_state(force: Vector2, duration: float = 0.25):
	if status == player_state.dead:
		return
	status = player_state.knock_back
	anim.play("knock_back")
	damage_sfx.play()
	velocity = force
	if not is_invincible:
		is_invincible = true
		Globals.player_hp -= 1
		if Globals.player_hp <= 0:
			go_to_dead_state()
			return
		start_knockback_tween(duration)
		start_flash_tween()
		get_tree().create_timer(0.25).timeout.connect(func(): is_invincible = false)
	else:
		get_tree().create_timer(duration).timeout.connect(finish_knockback)

func start_knockback_tween(duration):
	var knock_tween = create_tween()
	anim.modulate = Color(1, 0, 0, 1)
	knock_tween.tween_property(anim, "modulate", Color(1, 1, 1, 1), duration)
	knock_tween.tween_callback(finish_knockback)

func start_flash_tween():
	var flash_tween = create_tween().set_loops(5)
	flash_tween.tween_property(anim, "modulate:a", 0.5, 0.1)
	flash_tween.tween_property(anim, "modulate:a", 1.0, 0.1)

func finish_knockback():
	if status != player_state.dead:
		go_to_idle_state()

func go_to_victory_dance():
	status = player_state.victory_dance
	velocity = Vector2.ZERO
	anim.play("victory_dance")

func go_to_dead_state():
	if status == player_state.dead:
		return
	status = player_state.dead
	anim.play("dead")
	velocity.x = 0
	hitbox_collision.set_deferred("disabled", true)
	reaload_timer.start()

func idle_state(delta):
	apply_gravity(delta)
	move(delta)
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return 
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return
	if velocity.x != 0:
		go_to_walk_state()
		return 

func walk_state(delta):
	apply_gravity(delta)
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return 
	if Input.is_action_just_pressed("duck"):
		go_to_slide_state()
		return
	
	if not is_on_floor():
		jump_count += 1
		go_to_fall_state()

func jump_state(delta):
	apply_gravity(delta)
	move(delta)
	if Input.is_action_just_pressed("jump") and can_jump():
		go_to_jump_state()
		return
	if velocity.y > 0:
		go_to_fall_state()

func fall_state(delta):
	apply_gravity(delta)
	move(delta)
	if Input.is_action_just_pressed("jump") and can_jump():
		go_to_jump_state()
		return
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return
	if (left_wall_detector.is_colliding() or right_wall_detector.is_colliding()) and is_on_wall():
		if Globals.has_ice_cream:
			go_to_wall_state()
			return

func duck_state(delta):
	apply_gravity(delta)
	update_direction()
	velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	if direction != 0:
		go_to_slide_state()
		return
	if Input.is_action_just_released("duck"):
		if not ceiling_detector.is_colliding():
			exit_from_duck_state()
			go_to_idle_state()
			return

func slide_state(delta):
	apply_gravity(delta)
	update_direction()
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * (max_speed * 0.8), acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)
	
	if Input.is_action_just_pressed("jump") and can_jump():
		exit_from_slide_state()
		go_to_jump_state()
		return
	if Input.is_action_just_released("duck"):
		if not ceiling_detector.is_colliding():
			exit_from_slide_state()
			go_to_idle_state()
			return 
	if velocity.x == 0:
		if ceiling_detector.is_colliding():
			exit_from_slide_state()
			go_to_duck_state()
		else:
			exit_from_slide_state()
			go_to_idle_state()
		return

func wall_state(delta):
	velocity.y += wall_acceleration * delta
	if left_wall_detector.is_colliding():
		anim.flip_h = false
		direction = 1
	elif right_wall_detector.is_colliding():
		anim.flip_h = true
		direction = -1
	else:
		go_to_fall_state()
		return
	if is_on_floor():
		go_to_idle_state()
		return
	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_jump_velocity * direction
		go_to_jump_state()
		return

func swimming_state(delta):
	update_direction()
	if direction:
		velocity.x = move_toward(velocity.x, water_max_speed * direction, wall_acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, water_acceleration * delta)
	velocity.y += water_acceleration * delta
	velocity.y = min(velocity.y, water_max_speed)
	if Input.is_action_just_pressed("jump"):
		velocity.y = water_jump_force

func knock_back_state(delta):
	apply_gravity(delta)
	velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func victory_dance_state(delta):
	velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	apply_gravity(delta)

func dead_state(delta):
	apply_gravity(delta)

func move(delta):
	
	update_direction()
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func update_direction():
	direction = Input.get_axis("left", "right")
	
	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

func can_jump() -> bool:
	# Se o teto estiver colado na cabeça (passagem estreita), não pula de jeito nenhum
	if ceiling_detector.is_colliding():
		return false
	
	# Lógica normal de pulo duplo com o sorvete
	if not Globals.has_ice_cream:
		return jump_count < 1
	return jump_count < max_jump_count

func set_small_collider():
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3
	
	hitbox_collision.shape.size.y = 10
	hitbox_collision.position.y = 3

func set_large_collider():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0
	
	hitbox_collision.shape.size.y = 15
	hitbox_collision.position.y = 0.5

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		hit_enemy(area)
	elif area.is_in_group("lethalArea"):
		hit_lethal_area(area)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if status == player_state.dead:
		return
	if body.is_in_group("lethalArea"):
		go_to_knock_back_state(Vector2(0, -200))
	elif body.is_in_group("water"):
		go_to_swimming_state()
	elif body.is_in_group("lava"):
		go_to_knock_back_state(Vector2(0, -200))
	if body.is_in_group("spikes"):
		var direc = 1 if global_position.x > body.global_position.x else -1
		go_to_knock_back_state(Vector2(300 * direc, -400))
		return
	if body.has_method("break_sprite"):
		if velocity.y < 0:
			if body.has_method("take_hit"):
				body.take_hit()
				body.create_coin()
				if velocity.y < 0:
					velocity.y = 0
					go_to_fall_state()
		if body.hit_points < 0:
			body.break_sprite()
	if body.is_in_group("game_win"):
		go_to_victory_dance()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("water"):
		jump_count = 0
		go_to_jump_state()

func hit_enemy(area: Area2D):
	if velocity.y > 0:
		#enemy dead
		damage_sfx.play()
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		var difference = global_position.x - area.global_position.x
		var push_direction = 0
		if difference > 0:
			push_direction = 1 
		else:
			push_direction = -1
		go_to_knock_back_state(Vector2(push_direction * 250, -200))

func hit_lethal_area(area: Area2D):
	if area:
		var difference = global_position.x - area.global_position.x
		var push_direction = 0
		if difference > 0:
			push_direction = 1 
		else:
			push_direction = -1
		go_to_knock_back_state(Vector2(push_direction * 250, -200))
	else:
		go_to_knock_back_state(Vector2(0, -200))

func _on_reload_timer_timeout() -> void:
	Globals.player_life -= 1
	if Globals.player_life > 0:
		Globals.player_hp = 3
		Globals.coins = 0
		Globals.score = 0
		get_tree().reload_current_scene()
	else:
		Globals.reset_game()
		# Se quiser que o Game Over tire ele do Checkpoint:
		# Globals.has_checkpoint = false
		get_tree().change_scene_to_file("res://ui/game_over.tscn")
