extends Node

var coins = 0
var score = 0
var player_life = 3
var player_hp = 3
var max_hp = 3
var player = null
var current_checkpoint_pos = Vector2.ZERO
var has_checkpoint = false
var items_collect = []
var has_ice_cream = false
var time_elapsed = 0.0 # Armazena o tempo total em segundos
var is_timer_active = false # Para parar o tempo no menu ou na vitória
signal boss_defeated

func _process(delta: float) -> void:
	if is_timer_active:
		time_elapsed += delta

func reset_game():
	coins = 0
	score = 0
	player_life = 3
	player_hp = 3
	has_checkpoint = false
	current_checkpoint_pos = Vector2.ZERO
	has_ice_cream = false
	time_elapsed = 0.0
	is_timer_active = true

func respawn_player():
	if has_checkpoint and player != null:
		player.global_position = current_checkpoint_pos

func reset_items_temp():
	items_collect.clear()
