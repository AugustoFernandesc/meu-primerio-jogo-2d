extends CharacterBody2D

enum cherry_state {
	walk,
	hurt,
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var wall_detector: RayCast2D = $wallDetector
@onready var ground_detector: RayCast2D = $groundDetector

const SPEED = 35.0
const JUMP_VELOCITY = -400.0

var status: cherry_state

var direction = 1
var can_throw = true

func _ready() -> void:
	velocity = Vector2.ZERO
	if Globals.player:
		var diff = Globals.player.global_position.x - global_position.x
		direction = -1 if diff < 0 else 1
		update_sprite_direction()
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
	if wall_detector.is_colliding() or not ground_detector.is_colliding():
		direction *= -1
		update_sprite_direction()

func flying_state(_delta):
	pass

func hurt_state(_delta):
	pass

func take_damage():
	if status == cherry_state.hurt:
		return
	go_to_hurt_state()
	Globals.score += 50
	Globals.total_score_accumulated += 50

func update_sprite_direction():
	if direction == 1:
		anim.flip_h = true
	else:
		anim.flip_h = false 
	wall_detector.target_position.x = abs(wall_detector.target_position.x) * direction
	ground_detector.position.x = abs(ground_detector.position.x) * direction

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "hurt":
		queue_free() 
