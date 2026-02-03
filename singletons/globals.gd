extends Node

var coins = 0
var score = 0
var player_life = 3
var player_hp = 3
var max_hp = 3

var player = null
var current_checkpoint_pos = Vector2.ZERO
var has_checkpoint = false

func reset_game():
	coins = 0
	score = 0
	player_life = 3
	player_hp = 3
	has_checkpoint = false
	current_checkpoint_pos = Vector2.ZERO

func respawn_player():
	if has_checkpoint and player != null:
		player.global_position = current_checkpoint_pos
