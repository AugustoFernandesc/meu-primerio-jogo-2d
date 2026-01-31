extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $anim
@onready var hitbox: Area2D = $hitbox
@onready var ground_detector: RayCast2D = $ground_detector
var cherry_scene = preload("res://entities/cherry.tscn")

enum rockt_cherry_state {
	flying,
	hurt,
}

const SPEED = 30.0
const JUMP_VELOCITY = -400.0
var direction = 1
var start_position_y = 0.0

var status: rockt_cherry_state

func _ready() -> void:
	start_position_y = global_position.y
	go_to_flying_state()

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		rockt_cherry_state.flying:
			flying_state(delta)
		rockt_cherry_state.hurt:
			hurt_state(delta)
	move_and_slide()

func go_to_flying_state():
	status = rockt_cherry_state.flying
	anim.play("flying")

func go_to_hurt_state():
	if status == rockt_cherry_state.hurt: return
	status = rockt_cherry_state.hurt
	anim.play("hurt")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	set_physics_process(false)

func flying_state(_delta):
	velocity.y = SPEED * direction
	if direction == 1 and ground_detector.is_colliding():
		direction = -1
	elif direction == -1 and global_position.y <= start_position_y:
		direction = 1
		global_position.y = start_position_y

func hurt_state(_delta):
	velocity.x = move_toward(velocity.x, 0, 10)

func take_damage():
	go_to_hurt_state()

func spawn_cherry():
	var cherry = cherry_scene.instantiate()
	cherry.global_position = global_position
	get_parent().add_child(cherry)

func _on_anim_animation_finished() -> void:
	if anim.animation == "hurt":
		Globals.score += 100
		spawn_cherry()
		queue_free()
