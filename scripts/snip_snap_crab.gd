extends CharacterBody2D

enum crab_state { 
	idle, 
	attack, 
	dead
}

const claw = preload("res://entities/claw.tscn")
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var player_detector: RayCast2D = $player_detector
@onready var claw_position: Node2D = $claw_position
@onready var player_detector_2: RayCast2D = $player_detector2
@onready var claw_position_2: Node2D = $claw_position2

var status: crab_state
var direction = -1
var can_throw = true

func _ready() -> void:
	# Define a direção baseada na escala inicial
	direction = -1 if scale.x > 0 else 1
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		crab_state.idle:
			idle_state(delta)
		crab_state.attack:
			attack_state(delta)
		crab_state.dead:
			dead_state(delta)

	move_and_slide()

func go_to_idle_state():
	status = crab_state.idle
	anim.play("idle")

func go_to_attack_state():
	if status == crab_state.attack: return # Segurança para não resetar o ataque
	status = crab_state.attack
	anim.play("attack")
	velocity = Vector2.ZERO
	can_throw = true

func go_to_dead_state():
	status = crab_state.dead
	anim.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO

func idle_state(_delta):
	velocity.x = 0
	# Checa se QUALQUER UM dos dois sensores viu o player
	if player_detector.is_colliding() or player_detector_2.is_colliding():
		go_to_attack_state()

func attack_state(delta):
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	velocity.x = 0 

	# 1. ESCOLHE O LADO E A POSIÇÃO DA GARRA
	if player_detector_2.is_colliding(): # Sensor da Direita (Flipado)
		direction = 1
		anim.flip_h = true
		# Usamos o claw_position2 aqui
		if can_throw:
			throw_claw(claw_position_2.global_position)
			can_throw = false
			
	elif player_detector.is_colliding(): # Sensor da Esquerda (Normal)
		direction = -1
		anim.flip_h = false
		# Usamos o claw_position aqui
		if can_throw:
			throw_claw(claw_position.global_position)
			can_throw = false
	else:
		go_to_idle_state()

# 2. ATUALIZE A FUNÇÃO PARA RECEBER A POSIÇÃO
func throw_claw(pos: Vector2):
	var new_claw = claw.instantiate()
	add_sibling(new_claw)
	new_claw.global_position = pos # Usa a posição que passamos
	new_claw.set_direction(self.direction)

func dead_state(_delta):
	pass

func take_damage():
	go_to_dead_state()

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		can_throw = true # LIBERA PARA O PRÓXIMO CICLO
		go_to_idle_state()
	elif anim.animation == "dead":
		Globals.score += 150
		queue_free()
