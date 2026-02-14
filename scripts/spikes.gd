extends Node2D

@onready var sprite: Sprite2D = $spikes_image
@onready var solid_collision: CollisionShape2D = $"spikes-area/CollisionShape2D"

func _ready():
	solid_collision.shape = solid_collision.shape.duplicate()
	solid_collision.shape.size = sprite.get_rect().size

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage()
