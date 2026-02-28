extends Node

var tracks = {
	"grassland": preload("res://sons/grassland.ogg"),
	"forest": preload("res://sons/forest.ogg"),
	"tropic": preload("res://sons/tropic.ogg"),
	"winter_world": preload("res://sons/winter_world.ogg"),
	"boss": preload("res://sons/boss.mp3"),
	"extra_life": preload("res://sons/Heal.ogg")
}

@onready var p1: AudioStreamPlayer = $background_music
@onready var p2: AudioStreamPlayer = $background_music2

var current_p: AudioStreamPlayer
var current_world_track: String = ""

func _ready() -> void:
	current_p = p1
	# Conectando ao sinal do Globals (certifique-se que o nome no Globals é boss_defeated)
	if Globals.has_signal("boss_defeated"):
		Globals.boss_defeated.connect(stop_boss_music)
	Globals.life_changed.connect(_on_life_changed)

func play_track(world_name: String):
	if not tracks.has(world_name): return
	
	# Se a música já estiver tocando, não faz nada
	if current_p.stream == tracks[world_name] and current_p.playing:
		return
	
	# Salva qual é a música do mundo (para poder voltar depois do boss)
	if world_name != "boss":
		current_world_track = world_name

	_crossfade(tracks[world_name], _get_volume(world_name))

func _crossfade(new_stream: AudioStream, target_vol: float):
	var next_p = p2 if current_p == p1 else p1
	
	next_p.stream = new_stream
	next_p.volume_db = -60.0
	next_p.play()
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(current_p, "volume_db", -80.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(next_p, "volume_db", target_vol, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.set_parallel(false)
	tween.tween_callback(current_p.stop)
	current_p = next_p

func _get_volume(world_name: String) -> float:
	match world_name:
		"grassland": return -32.0
		"forest": return -23.0
		"tropic": return -15.0
		"winter_world": return -30.0
		"boss": return -30.0
	return 0.0

func start_boss_music():
	play_track("boss")

func stop_boss_music():
	if current_world_track != "":
		play_track(current_world_track)
	else:
		stop_all()

func stop_all():
	if p1: p1.stop()
	if p2: p2.stop()
	current_world_track = "" 

func _on_life_changed() -> void:
	var sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.stream = tracks["extra_life"]
	sfx_player.volume_db = -20.0 
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)
