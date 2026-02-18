extends CharacterBody2D

const SPEED = 70.0 

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var water_detector: RayCast2D = $water_detector

func _physics_process(_delta: float) -> void:
	var move_dir = Vector2.ZERO
	if $player_detector2.is_colliding() or $player_detector3.is_colliding() or $player_detector4.is_colliding():
		move_dir.y = 1 # Ir para baixo
	elif $player_detector7.is_colliding() or $player_detector8.is_colliding():
		move_dir.y = -1 
	if $player_detector5.is_colliding() or $player_detector6.is_colliding():
		move_dir.x = 1
		anim.flip_h = true
	elif $player_detector9.is_colliding() or $player_detector.is_colliding():
		move_dir.x = -1
		anim.flip_h = false
	if move_dir.y < 0 and not water_detector.is_colliding():
		move_dir.y = 0 
		velocity.y = 20 
	if move_dir != Vector2.ZERO:
		velocity = move_dir.normalized() * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 5)

	anim.play("idle")
	move_and_slide()

func take_damage():
	await anim.animation_finished
	anim.play("dead")
	queue_free()
	Globals.score += 100
	Globals.total_score_accumulated += 100
