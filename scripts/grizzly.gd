extends CharacterBody2D

enum grizzly_state {
	sleeping,
	walk,
	attack,
	dead
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var wall_detector: RayCast2D = $wallDetector
@onready var player_detector: RayCast2D = $playerDetector
@onready var player_detector_2: RayCast2D = $playerDetector2
@onready var attack_player: RayCast2D = $attack_player
@onready var ground_detector: RayCast2D = $groundDetector
@onready var hand_hitbox: CollisionShape2D = $hitbox/hand_hitbox
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox_damage: CollisionShape2D = $hitbox2/hitbox_damage

var life = 2
const SPEED = 50.0

var status: grizzly_state

var direction = -1

func _ready() -> void:
	go_to_sleeping_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		grizzly_state.sleeping:
			sleeping_state(delta)
		grizzly_state.walk:
			walk_state(delta)
		grizzly_state.attack:
			attack_state(delta)
		grizzly_state.dead:
			dead_state(delta)

	move_and_slide()


func go_to_sleeping_state():
	status = grizzly_state.sleeping
	anim.play("sleeping")
# Ajuste da colisão física (corpo do urso)
	collision.shape.size.y = 10
	collision.position.y = 11

	# Ajuste da hitbox de dano (o que recebe o pulo do player)
	# Deixamos ela com 14 de altura para ela "sobrar" 4 pixels acima da colisão física
	hitbox_damage.shape.size.y = 14
	hitbox_damage.position.y = 9


func go_to_walk_state():
	status = grizzly_state.walk
	anim.play("walk")
# Reset para o estado em pé (Original 32x32)
	collision.shape.size.y = 32
	collision.position.y = 0
	
	hitbox_damage.shape.size.y = 32
	hitbox_damage.position.y = 0

func go_to_attack_state():
	if status == grizzly_state.attack:
		return 
	status = grizzly_state.attack
	anim.play("attack")
	velocity = Vector2.ZERO

func go_to_dead_state():
	status = grizzly_state.dead
	anim.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	
func walk_state(_delta):
	if status == grizzly_state.attack:
		return
	if wall_detector.is_colliding():
		velocity.x = 0
		go_to_sleeping_state()
	if not ground_detector.is_colliding():
		go_to_sleeping_state()
		return
	if player_detector_2.is_colliding():
		direction = -1
		anim.flip_h = false
		hand_hitbox.position.x = -22.25
		attack_player.target_position.x = -25.5
		velocity.x = SPEED * direction
	elif player_detector.is_colliding():
		direction = 1
		anim.flip_h = true
		hand_hitbox.position.x = 22.25
		attack_player.target_position.x = 25.5
		velocity.x = SPEED * direction
	else:
		go_to_sleeping_state()
		return
	
	if attack_player.is_colliding():
		go_to_attack_state()
		print("to atacando")
		return

func attack_state(_delta):
	velocity.x = 0
	hand_hitbox.set_deferred("disabled", false)

func dead_state(_delta):
	pass

func sleeping_state(_delta):
	velocity.x = 0
	# Força os detectores a olharem o mundo de novo
	player_detector.force_raycast_update()
	player_detector_2.force_raycast_update()
	
	if player_detector.is_colliding() or player_detector_2.is_colliding():
		# Só acorda se quem ele bateu for o Player
		var c1 = player_detector.get_collider()
		var c2 = player_detector_2.get_collider()
		
		if (c1 and c1.is_in_group("player")) or (c2 and c2.is_in_group("player")):
			go_to_walk_state()

func take_damage():
	life -= 1
	if life <= 0:
		go_to_dead_state()
	else:
		var tween = create_tween()
		anim.modulate = Color.RED
		tween.tween_property(anim, "modulate", Color.WHITE, 0.2)

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		hand_hitbox.set_deferred("disabled", true)
		go_to_walk_state()
		return
	if anim.animation == "dead":
		Globals.score += 250
		Globals.total_score_accumulated += 250
		queue_free()
