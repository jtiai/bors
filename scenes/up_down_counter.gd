extends HBoxContainer

class_name UpDownCounter

signal value_changed(node: UpDownCounter, amount: int)

@export var value: int = 0:
	get:
		return value
	set(value_):
		value = clampi(value_, min_value, max_value)
		value_label.text = "%s" % value

@export var min_value: int = 0:
	get:
		return min_value
	set(value_):
		min_value = min(value_, max_value)  # Min value can't be bigger than max_value
		value = max(value, value_)  # Value can't be smaller than min_value

@export var max_value: int = 100:
	get:
		return max_value
	set(value_):
		max_value = max(value_, min_value)  # Max value can't be smaller than min_value
		value = min(value, value_)  # Value can't be bigger than max_value

var label: String = "0":
	get:
		return value_label.text

@onready var value_label = $"ValueLabel"
@onready var sound_player := $"AudioStreamPlayer"
@onready var click_sound := preload("res://sounds/click.wav")


func _ready():
	sound_player.stream = click_sound
	value_label.text = "%s" % value


func _on_up_button_pressed():
	var old_value := value
	value += 1
	if value != old_value:
		sound_player.play()
		emit_signal("value_changed", self, 1)


func _on_down_button_pressed():
	var old_value := value
	value -= 1
	if value != old_value:
		sound_player.play()
		emit_signal("value_changed", self, -1)
