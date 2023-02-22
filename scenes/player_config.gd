extends Control

signal start_game(names, rounds, shuffle)

@onready var player_list := $"PanelContainer/VBoxContainer/MarginContainer2/PlayerList"
@onready var player_template := $"PanelContainer/VBoxContainer/MarginContainer2/PlayerList/PlayerTemplate"
@onready var ready_button := $"PanelContainer/VBoxContainer/MarginContainer3/ReadyButton"

var players: Array = []
var rounds: int = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_button.disabled = true
	%RoundsLabel.text = str(rounds)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	ready_button.disabled = not are_names_valid()


func _on_add_button_pressed():
	if players.size() >= 10:
		return  # Max 10 players

	var player_row = player_template.duplicate()
	player_row.player_id = players.size()
	players.append(player_row)
	player_list.add_child(player_row)
	player_row.show()

func _on_player_template_player_removed(player_id):
	players.remove_at(player_id)

	# Renumbering
	for i in players.size():
		players[i].player_id = i


func _on_ready_button_pressed():
	var player_names: Array[String] = []
	for p in players:
		var player_name: String = p.player_name.strip_edges()
		if name.is_empty() or player_names.has(name):
			return  # Bail out incase of invalid stuff

		player_names.append(player_name)

	emit_signal("start_game", player_names, rounds, %SufflePlayers.button_pressed)



func _on_player_template_player_name_changed(player_id):
	var player_names = []
	for p in players:
		if p.player_id == player_id:
			continue  # Skip current player

		var player_name: String = p.player_name.strip_edges()
		if player_name.is_empty() or player_names.has(player_name):
			continue  # Bail out incase of invalid stuff

		player_names.append(player_name)

	var player_name: String = players[player_id].player_name.strip_edges()
	if player_name.is_empty():
		players[player_id].show_error("Name can't be empty!")

	if player_names.has(player_name):
		players[player_id].show_error("Duplicate name!")


func are_names_valid() -> bool:
	if players.is_empty():
		return false

	for p in players:
		if p.has_error:
			return false

	return true


func _on_rounds_slider_value_changed(value):
	rounds = value * 10
	%RoundsLabel.text = str(rounds)
