extends CharacterBody2D

const box_pieces = preload("res://entities/interactables/box_pieces.tscn")
const coin_instance = preload("res://entities/interactables/coin_rigid.tscn")

@onready var anim: AnimationPlayer = $anim
@onready var spawn_coin: Marker2D = $spawn_coin
@onready var hit_box: AudioStreamPlayer = $hit_box
@onready var box_falling: AudioStreamPlayer = $box_falling

@export var pieces: PackedStringArray
@export var hit_points = 5
var impulse = 200
var is_broken = false

func take_hit():
	if is_broken:
		return
	hit_points -= 1
	if hit_points > 0:
		hit_box.play()
		anim.play("hit")
	else:
		is_broken = true
		set_deferred("collision_layer", 0)
		set_deferred("collision_mask", 0)
		break_sprite()

func break_sprite():
	create_coin()
	for piece in pieces.size():
		var piece_instance = box_pieces.instantiate()
		get_parent().add_child(piece_instance)
		piece_instance.get_node("texture").texture = load(pieces[piece])
		piece_instance.global_position = global_position
		piece_instance.apply_impulse(Vector2(randi_range(-impulse, impulse), randi_range(-impulse, -impulse * 2)))
	visible = false
	box_falling.play()
	var box_id = get_tree().current_scene.name + str(global_position)
	if not Globals.items_collect.has(box_id):
		Globals.items_collect.append(box_id)
	await box_falling.finished
	queue_free()

func create_coin():
	var coin = coin_instance.instantiate()
	get_parent().call_deferred("add_child", coin)
	coin.global_position = spawn_coin.global_position
	coin.apply_impulse(Vector2(randi_range(-50,50), -150))

func _ready():
	var box_id = get_tree().current_scene.name + str(global_position)
	if Globals.items_collect .has(box_id):
		queue_free()
