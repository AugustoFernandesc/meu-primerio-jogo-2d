extends Control


@onready var timer_counter: Label = $container/timer_container/timer_counter
@onready var score_counter: Label = $container/score_container/score_counter
@onready var coins_counter: Label = $container_coins/coins_container/coins_icons/coins_counter
@onready var life_counter: Label = $container_coins/life_container/life_icons/life_counter
@onready var hp_counter: Label = $hp_container/hp_icons/hp_counter
@onready var clock_timer: Timer = $clock_timer


var minutes = 0
var seconds = 0
@export_range(0,5) var default_minutes = 1
@export_range(0,59) var default_seconds = 0

signal time_is_up()

func _ready() -> void:
	coins_counter.text = str("%04d" % Globals.coins)
	score_counter.text = str("%06d" % Globals.score)
	hp_counter.text = str("%02d" % Globals.player_hp)
	life_counter.text = str("%02d" % Globals.player_life)
	timer_counter.text = str("%02d" % default_minutes) + ":" + str("%02d" % default_seconds)
	reset_clock_timer()

func _process(_delta: float) -> void:
	coins_counter.text = str("%04d" % Globals.coins)
	score_counter.text = str("%06d" % Globals.score)
	hp_counter.text = str("%02d" % Globals.player_hp)
	life_counter.text = str("%02d" % Globals.player_life)
	if minutes == 0  and seconds == 0:
		clock_timer.stop()
		emit_signal("time_is_up")
		_on_time_is_up()
		set_process(false)

func _on_clock_timer_timeout() -> void:
	if seconds == 0:
		if minutes > 0:
			minutes -= 1
			seconds = 60
	seconds -= 1
	timer_counter.text = str("%02d" % minutes) + ":" + str("%02d" % seconds)

func reset_clock_timer():
	minutes = default_minutes
	seconds = default_seconds

func _on_time_is_up() -> void:
	Globals.player_life -= 1
	if Globals.player_life > 0:
		Globals.player_hp = 3 
		get_tree().reload_current_scene()
	else:
		Globals.reset_game()
		get_tree().change_scene_to_file("res://ui/game_over.tscn")
