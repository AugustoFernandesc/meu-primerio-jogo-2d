extends Node

# Dicionário com suas músicas
var tracks = {
	"grassland": preload("res://sons/grassland.ogg"),
	"forest": preload("res://sons/forest.ogg"),
	"tropic": preload("res://sons/tropic.ogg"),
	"winter_world": preload("res://sons/winter_world.ogg"),
	"boss": preload("res://sons/boss.mp3")
}

@onready var p1: AudioStreamPlayer = $background_music
@onready var p2: AudioStreamPlayer = $background_music2

var current_p: AudioStreamPlayer
var current_world_track: String = ""

func _ready() -> void:
	current_p = p1
	# Conecta ao seu sinal global de vitória
	if Globals.has_signal("boss_defeated"):
		Globals.boss_defeated.connect(stop_boss_music)
	print("--- MusicPlayer Pronto! ---")

func play_track(world_name: String):
	if not tracks.has(world_name): return
	# Se a música já está tocando, não faz nada
	if current_p.stream == tracks[world_name] and current_p.playing: return
	
	if world_name != "boss":
		current_world_track = world_name

	_crossfade(tracks[world_name], _get_volume(world_name))

func _crossfade(new_stream: AudioStream, target_vol: float):
	var next_p = p2 if current_p == p1 else p1
	
	# Prepara a nova música (Boss ou Mapa)
	next_p.stream = new_stream
	next_p.volume_db = -60.0 # Começa bem baixo mas audível
	next_p.play()
	
	var tween = create_tween().set_parallel(true)

	tween.tween_property(current_p, "volume_db", -80.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(next_p, "volume_db", target_vol, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.set_parallel(false)
	tween.tween_callback(current_p.stop)
	current_p = next_p

func _get_volume(world_name: String) -> float:
	match world_name:
		"grassland": return -27.0
		"forest": return -23.0
		"tropic": return -10.0
		"winter_world": return -25.0
		"boss": return -15.0
	return 0.0

func start_boss_music():
	play_track("boss")

func stop_boss_music():
	if current_world_track != "":
		play_track(current_world_track)

func stop_all():
	if p1: p1.stop()
	if p2: p2.stop()
	current_world_track = "" 
