extends Control

signal restart_game

func set_players(players):
	for player in players:
		var new_entry = %PlayerTemplate.duplicate()
		%PlayerList.add_child(new_entry)
		new_entry.get_node("PlayerName").text = player.player_name
		new_entry.get_node("PlayerCash").text = "%.02f" % player.money
		new_entry.show()

func _on_restart_button_pressed():
	emit_signal("restart_game")
