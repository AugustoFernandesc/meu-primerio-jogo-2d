extends Node2D

func _ready() -> void:
	if Globals.first_time_in_level:
		Transition.play_transition(1, "Vivid Wilds")
		Globals.first_time_in_level = false
	else:
		Transition.color_rect.visible = false
	MusicPlayer.play_track("grassland")
	Globals.is_timer_active = true
