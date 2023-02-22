extends HBoxContainer

class_name PlayerName

signal player_removed(player_id)
signal player_name_changed(player_id)

var player_id: int = -1
var has_error: bool = true

@onready var player_name_edit := $"PlayerNameEdit"
@onready var error_indicator := $"TextureRect"

var player_name: String:
	get:
		return player_name_edit.text


func _ready() -> void:
	show_error("Name can't be empty!")
	if player_id == 0:
		player_name_edit.grab_focus()


func _on_remove_player_button_pressed():
	emit_signal("player_removed", player_id)
	queue_free()


func hide_error() -> void:
	error_indicator.modulate.a = 0
	error_indicator.tooltip_text = ""
	has_error = false

func show_error(message: String) -> void:
	error_indicator.modulate.a = 255
	error_indicator.tooltip_text = message
	has_error = true

func _on_player_name_edit_text_changed(_new_text):
	hide_error()
	emit_signal("player_name_changed", player_id)
