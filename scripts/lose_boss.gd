extends CharacterBody2D

var speed = 70.0
var jump_force = -170.0
var gravity = 800.0
var jump_count = 0
var can_jump_again = false
var is_fading = false 

@onready var sprite: AnimatedSprite2D = $lose_boss 

func _ready() -> void:
	# 1. Sai do tanque já correndo e pulando
	sprite.play("run_away")
	velocity = Vector2(speed, jump_force)
	
	# 2. Espera um tempo (1.2s) para ele correr um pouco no chão antes de liberar o próximo pulo
	get_tree().create_timer(1.2).timeout.connect(func(): can_jump_again = true)

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	velocity.y += gravity * delta
	
	# Lógica de chão
	if is_on_floor():
		# Se já correu o tempo necessário e ainda não deu o segundo pulo
		if can_jump_again and jump_count < 1:
			velocity.y = jump_force # Dá o segundo pulo
			jump_count += 1
			
			# O PULO DO GATO: Espera ele começar a cair do segundo pulo para iniciar o sumiço
			get_tree().create_timer(0.4).timeout.connect(start_fading)
	
	# Se bater na parede, some na hora para não bugar
	if is_on_wall() and not is_fading:
		start_fading()

	# Mantém a corrida para a direita
	velocity.x = speed
	
	move_and_slide()

func start_fading():
	if is_fading: return
	is_fading = true
	
	# Cria o efeito de transparência (Fade Out)
	var tween = create_tween()
	# Ele vai sumindo suavemente em 1.2 segundos enquanto continua correndo
	tween.tween_property(sprite, "modulate:a", 0.0, 1.2)
	# Assim que sumir tudo, deleta da memória
	tween.tween_callback(queue_free)
