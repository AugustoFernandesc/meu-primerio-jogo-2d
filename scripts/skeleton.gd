extends CharacterBody2D

enum skeleton_state {
	walk,
	attack,
	dead
}

const spinning_bone = preload("res://entities/spinning_bone.tscn") 

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var wall_detector: RayCast2D = $wallDetector
@onready var ground_detector: RayCast2D = $groundDetector
@onready var player_detector: RayCast2D = $playerDetector
@onready var bone_start_position: Node2D = $boneStartPosition



const SPEED = 10.0
const JUMP_VELOCITY = -400.0

var status: skeleton_state

var direction = 1
var can_throw = true

func _ready() -> void:
	go_to_walk_state()

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		skeleton_state.walk:
			walk_state(delta)
		skeleton_state.attack:
			attack_state(delta)
		skeleton_state.dead:
			dead_state(delta)

	move_and_slide()

func go_to_walk_state():
	status = skeleton_state.walk
	anim.play("walk")

func go_to_attack_state():
	status = skeleton_state.attack
	anim.play("attack")
	velocity = Vector2.ZERO
	can_throw = true

func go_to_dead_state():
	status = skeleton_state.dead
	anim.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	
func walk_state(_delta):
	if anim.frame == 3 or anim.frame == 4:
		velocity.x = SPEED * direction
	else:
		velocity.x = 0
	
	if wall_detector.is_colliding():
		scale.x *= -1
		direction *= -1
	
	if not ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1
	
	if player_detector.is_colliding():
		go_to_attack_state()
		return

func attack_state(_delta):
	if anim.frame == 2 and can_throw:
		throw_bone()
		can_throw = false

func dead_state(_delta):
	pass

func take_damage():
	go_to_dead_state()

func throw_bone():
	var new_bone = spinning_bone.instantiate()
	add_sibling(new_bone)
	new_bone.position = bone_start_position.global_position
	new_bone.set_direction(self.direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		go_to_walk_state()
		return
	if anim.animation == "dead":
		Globals.score += 150
		Globals.total_score_accumulated += 150
		queue_free()
