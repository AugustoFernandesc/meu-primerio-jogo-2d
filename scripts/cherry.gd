extends CharacterBody2D

enum cherry_state {
	walk,
	hurt,
}


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var wall_detector: RayCast2D = $wallDetector
@onready var ground_detector: RayCast2D = $groundDetector

const SPEED = 20.0
const JUMP_VELOCITY = -400.0

var status: cherry_state

var direction = 1
var can_throw = true

func _ready() -> void:
	go_to_walk_state()

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		cherry_state.walk:
			walk_state(delta)
		cherry_state.hurt:
			hurt_state(delta)
	move_and_slide()


func go_to_walk_state():
	status = cherry_state.walk
	anim.play("walk")

func go_to_hurt_state():
	status = cherry_state.hurt
	anim.play("hurt")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	
func walk_state(_delta):
	velocity.x = SPEED * direction
	if wall_detector.is_colliding():
		scale.x *= -1
		direction *= -1
	
	if not ground_detector.is_colliding():
		scale.x *= 1
		direction *= -1

func flying_state(_delta):
	pass

func hurt_state(_delta):
	pass

func take_damage():
	go_to_hurt_state()


	if anim.animation == "hurt":
		Globals.score += 100
		queue_free()
