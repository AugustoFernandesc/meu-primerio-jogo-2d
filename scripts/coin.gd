extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var coin_sfx: AudioStreamPlayer = $coin_sfx

var coins = 1 

func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass

func _on_body_entered(_body: Node2D) -> void:
	anim.play("collect")
	coin_sfx.play()
	
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Apenas soma os valores. O Globals.gd cuida da lógica de conversão no _process
	Globals.coins += coins
	Globals.total_coins_collected += coins

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "collect":
		queue_free()
