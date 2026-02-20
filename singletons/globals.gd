extends Node

var coins = 0
var score = 0
var player_life = 3
var player_hp = 5
var max_hp = 5
var player = null
var current_checkpoint_pos = Vector2.ZERO
var has_checkpoint = false
var items_collect = []
var has_ice_cream = false
var time_elapsed = 0.0 
var is_timer_active = false
var ready_plate: bool = false
var first_time_in_level = true
# VARIÁVEIS PARA A TELA DE VITÓRIA
var total_coins_collected = 0
var total_score_accumulated = 0

signal boss_defeated

func _process(delta: float) -> void:
	if is_timer_active:
		time_elapsed += delta
	
	check_coin_to_life_conversion()
	check_score_to_life_conversion()

func check_coin_to_life_conversion():
	while coins >= 15:
		if player_hp < 5:
			player_hp += 1
			coins -= 15
		elif player_life < 3:
			player_life += 1
			player_hp = 1  #Reseta o HP ao ganhar vida nova
			coins -= 15
		else:
			break

func check_score_to_life_conversion():
	while score >= 1000:
		if player_hp < 5:
			player_hp += 1
			score -= 1000
		elif player_life < 3:
			player_life += 1
			player_hp = 1  #  Reseta o HP ao ganhar vida nova
			score -= 1000
		else:
			break

func reset_game():
	coins = 0
	score = 0
	player_life = 3
	player_hp = 5
	has_checkpoint = false
	current_checkpoint_pos = Vector2.ZERO
	has_ice_cream = false
	time_elapsed = 0.0
	is_timer_active = true
	total_coins_collected = 0
	total_score_accumulated = 0

func respawn_player():
	if has_checkpoint and player != null:
		player.global_position = current_checkpoint_pos

func reset_items_temp():
	items_collect.clear()
