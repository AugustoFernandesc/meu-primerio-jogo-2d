extends CharacterBody2D

const SPEED = 50.0 

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var water_detector: RayCast2D = $water_detector

func _physics_process(_delta: float) -> void:
	var move_dir = Vector2.ZERO
	
	# Lógica de detecção (mantive seus Raycasts)
	if $player_detector2.is_colliding() or $player_detector3.is_colliding() or $player_detector4.is_colliding():
		move_dir.y = 1 # Down
	elif $player_detector7.is_colliding() or $player_detector8.is_colliding():
		move_dir.y = -1 # Up
		
	if $player_detector5.is_colliding() or $player_detector6.is_colliding():
		move_dir.x = 1
		anim.flip_h = true
	elif $player_detector9.is_colliding() or $player_detector.is_colliding():
		move_dir.x = -1
		anim.flip_h = false
		
	# Trava pra não sair da água quando subir
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
	# Desativa o movimento pra ela não bater em você enquanto morre
	set_physics_process(false)
	
	# Toca a animação de morte
	anim.play("dead")
	
	# Ganha pontos
	Globals.score += 100
	Globals.total_score_accumulated += 100
	
	# Espera um tempinho pra animação aparecer e some
	await get_tree().create_timer(0.3).timeout
	queue_free()
