extends MarginContainer

@onready var text_label: Label = $label_margin/text_label
@onready var timer: Timer = $letter_timer_display

var message_lines: Array[String] = []
var current_line = 0
var letter_index = 0
var can_advance = false

func _ready():
	await get_tree().process_frame
	global_position.x -= size.x / 2
	global_position.y -= size.y + 10
	show_current_line()

func show_current_line():
	can_advance = false
	text_label.text = ""
	letter_index = 0
	if current_line < message_lines.size():
		display_letters()

func display_letters():
	if letter_index < message_lines[current_line].length():
		text_label.text += message_lines[current_line][letter_index]
		letter_index += 1
		timer.start(0.02)
	else:
		can_advance = true

func _on_letter_timer_display_timeout():
	display_letters()

func _input(event):
	if event.is_action_pressed("advance_message") and can_advance:
		current_line += 1
		if current_line < message_lines.size():
			show_current_line()
		else:
			queue_free()
