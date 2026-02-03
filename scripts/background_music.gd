extends AudioStreamPlayer

func _ready() -> void:
	volume_db = -20.0

var tracks = {
	"grassland": preload("res://sons/grassland.ogg"),
	"forest": preload("res://sons/forest.ogg"),
	"tropic": preload("res://sons/tropic.ogg"),
	"winter_world": preload("res://sons/winter_world.ogg")
}

func play_track(world_name: String):
	if not tracks.has(world_name):
		print("Erro: Música do mundo ", world_name, " não encontrada!")
		return
	var selected_track = tracks[world_name]
	if stream != selected_track or not playing:
		stream = selected_track
		play()
