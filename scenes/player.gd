extends Control

class_name Player

var stock_row_scene: PackedScene = preload("res://scenes/stock.tscn")
var stock_rows: Array[Stock] = []

@export var player_name: String = "Nanonano"
@export var money: float = 100

@export var number_of_rounds: int = 0

@onready var done_button: Button = %DoneButton

func _ready():
	update_money_label()
	update_player_label()

func adjust_money(amount: float) -> float:
	if money - amount < 0:
		pass  # No change to money
	else:
		money += amount
	return money


func create_stock_rows(company_stats: Array[Dictionary]) -> void:
	for i in company_stats.size():
		var stats := company_stats[i]
		var new_stock: Stock = stock_row_scene.instantiate()

		new_stock.stock_id = i

		stock_rows.append(new_stock)
		%StockRows.add_child(new_stock)

		# Relies being on a tree
		new_stock.company = stats["name"]
		new_stock.price = stats["price"]
		new_stock.old_price = stats["old_price"]
		new_stock.change = stats["change"]
		new_stock.dividend = stats["dividend"]

		new_stock.connect("owned_changed", _on_owned_changed)


func apply_stocks(stock_stats: Array[Dictionary]) -> void:
	for i in stock_stats.size():
		var stats = stock_stats[i]
		var stock = stock_rows[i]

		stock.price = stats["price"]
		stock.change = stats["change"]
		stock.old_price = stats["old_price"]
		stock.dividend = stats["dividend"]
		if stats["bankcrupt"]:
			stock.owned = 0

		if stats["shares_issued"]:
			stock.owned += stock.owned / 2

		# Pay the dividend
		money += stock.dividend * stock.owned
		update_money_label()

func _on_owned_changed(node: UpDownCounter, stock_id: int, amount: int) -> void:
	var stock = stock_rows[stock_id]
	var price = stock.price * absi(amount)

	if amount > 0:
		# Bying
		if money - price >= 0:
			money -= price
		else:
			node.value -= 1  # Rollback one since couldn't buy
	else:
		# Selling
		money += price

	update_money_label()


func update_player_label() -> void:
	%PlayerLabel.text = "Player: %s" % player_name


func update_money_label() -> void:
	%CashLabel.text = "Cash: %.02f" % money


func set_round(game_round: int) -> void:
	%RoundLabel.text = "Round: %d / %d" % [game_round, number_of_rounds]
