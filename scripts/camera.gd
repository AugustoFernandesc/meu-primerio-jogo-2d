extends Camera2D

var target: Node2D

func _ready() -> void:
	await get_tree().process_frame
	get_target()
	if target:
		global_position = target.global_position
		reset_smoothing()

func _process(_delta: float) -> void:
	position = target.position

func get_target():
	var nodes = get_tree().get_nodes_in_group("player")
	if nodes.size() > 0:
		target = nodes[0]
	else:
		await get_tree().create_timer(0.1).timeout
		get_target()
	
