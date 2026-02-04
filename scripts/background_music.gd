extends AudioStreamPlayer

func _ready() -> void:
	pass

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
		
	match world_name:
		"grassland":
			volume_db = -27.0
		"forest":
			volume_db = -23.0
		"tropic":
			volume_db = -10.0
		"winter_world":
			volume_db = -25.0
		
	var selected_track = tracks[world_name]
	if stream != selected_track or not playing:
		stream = selected_track
		play()
