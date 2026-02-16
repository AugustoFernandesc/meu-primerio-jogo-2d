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
	if player_detector.is_colliding():
		go_to_attack_state()

func attack_state(delta):
	# Aplica gravidade para ele não flutuar e ser empurrado
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	velocity.x = 0 
	if not player_detector.is_colliding():
		go_to_idle_state()
		return
	if can_throw:
		throw_claw()
		can_throw = false

func throw_claw():
	var new_claw = claw.instantiate()
	add_sibling(new_claw)
	new_claw.position = claw_position.global_position
	new_claw.set_direction(self.direction)

func dead_state(_delta):
	pass

func take_damage():
	go_to_dead_state()

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		go_to_idle_state()
	elif anim.animation == "dead":
		Globals.score += 150
		queue_free()
