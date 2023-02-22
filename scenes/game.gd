extends Control

const NUMBER_OF_STOCKS = 10
const NUMBER_OF_PREHEAT_ROUNDS = 10

var Player: PackedScene = preload("res://scenes/player.tscn")
var NameGenerator = preload("res://scripts/name_generator.gd")
var name_generator = NameGenerator.new()

# Global company stats
var company_stats: Array[Dictionary] = []

var players: Array[Player] = []

var current_round: int = 1
var current_player: int = 0
var number_of_players: int = 1
var number_of_rounds: int = 0

@onready var player_config := $"BG/PlayerConfig"
@onready var message_popup := $"MessagePopup"
@onready var players_node := $"BG/Players"
@onready var game_over := $"BG/GameOver"

@onready var songs = [
	preload("res://sounds/motivation-gets-in-the-way-519.mp3"),
	preload("res://sounds/sensual-pop-289.mp3"),
	preload("res://sounds/whill-chake-632.mp3"),
]

func _ready():
	randomize()

	for song in songs:
		Audiomanager.queue_music(song)

	Audiomanager.start_music()

	make_stocks()

	player_config.show()

func make_stocks():
	for i in NUMBER_OF_STOCKS:
		var stats = {}
		stats["name"] = name_generator.company()
		stats["price"] = 10.00
		stats["old_price"] = 0
		stats["change"] = 0
		stats["dividend"] = 0
		stats["bankcrupt"] = false
		stats["shares_issued"] = false

		company_stats.append(stats)

	# Pre-heat game
	for i in NUMBER_OF_PREHEAT_ROUNDS:
		simulate_stocks()

	# Reset states
	for stock in company_stats:
		stock["bankcrupt"] = false
		stock["shares_issued"] = false



func _on_done_button_pressed():
	# Run next loop
	var prev_player = current_player
	current_player += 1
	if current_player >= number_of_players:
		current_player = 0
		current_round += 1

		if current_round > number_of_rounds:
			do_game_over()

		simulate_stocks(false)

		for player in players:
			player.set_round(current_round)
			player.apply_stocks(company_stats)

			if current_round < number_of_rounds:
				message_popup.show_message("Next round...", 2.0, message_popup.SoundType.ANNOUNCEMENT)
			else:
				message_popup.show_message("Final round...", 2.0, message_popup.SoundType.ANNOUNCEMENT)

	players[prev_player].hide()
	players[current_player].show()
	players[current_player].set_round(current_round)


func create_player(player_name: String) -> Player:
	var player = Player.instantiate()
	player.player_name = player_name
	player.money = 100
	player.number_of_rounds = number_of_rounds
	players.append(player)
	player.hide()
	players_node.add_child(player)
	player.create_stock_rows(company_stats)  # Relies being on a tree
	player.done_button.connect("pressed", _on_done_button_pressed)
	return player


# Simulate one round of stock market
func simulate_stocks(silent: bool = true):
	for stock_stat in company_stats:
		var dividend: float = randf_range(0, 1.5)
		var x: float = randf()
		var y: int = randi_range(1, 5)
		var m1: float = 0

		if x <= 0.4:
			m1 = 1
		elif x <= 0.7:
			m1 = -1

		stock_stat["old_price"] = stock_stat["price"]
		stock_stat["change"] = m1 * stock_stat["price"] / 8 * y
		stock_stat["price"] += stock_stat["change"]
		stock_stat["dividend"] = dividend
		stock_stat["bankcrupt"] = false
		stock_stat["shares_issued"] = false

		# Bankcrupt
		if stock_stat["price"] <= 1.0:
			stock_stat["price"] = 10.0
			stock_stat["dividend"] = 0
			stock_stat["change"] = 0
			stock_stat["old_price"] = 0
			stock_stat["bankcrupt"] = true
			if not silent:
				message_popup.show_message("%s went bankcrupt." % stock_stat["name"], 2.0)

		# Issue shares
		if stock_stat["price"] >= 30.0:
			stock_stat["shares_issued"] = true
			if not silent:
				message_popup.show_message("%s issued new shares." % stock_stat["name"], 2.0)


func _on_player_config_start_game(names: Array[String], rounds: int, shuffle: bool) -> void:
	player_config.hide()

	message_popup.show_message("Game begins...", 5.0, message_popup.SoundType.ANNOUNCEMENT)

	number_of_players = names.size()
	number_of_rounds = rounds

	if shuffle:
		names.shuffle()

	for i in names.size():
		var player_name = names.pop_front()
		create_player(player_name)

	# Round one, first player
	players[current_player].show()
	players[current_player].set_round(current_round)


func do_game_over():
	# Hide all players
	for i in players.size():
		players[i].hide()

	# Sell all stocks
	for player in players:
		for stock in player.stock_rows:
			player.money += stock.price * stock.owned

	players.sort_custom(func (a: Player, b: Player): return a.money > b.money)

	game_over.set_players(players)
	game_over.show()



func _on_game_over_restart_game():
	company_stats = []
	players = []

	current_round = 1
	current_player = 0
	number_of_players = 1
	number_of_rounds = 0

	make_stocks()
	game_over.hide()
	player_config.show()

