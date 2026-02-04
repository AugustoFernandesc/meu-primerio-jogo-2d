extends Node2D

func _ready() -> void:
	MusicPlayer.play_track("grassland")
	Globals.is_timer_active = true
