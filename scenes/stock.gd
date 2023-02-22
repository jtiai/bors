extends Control

class_name Stock

signal owned_changed(owned_node: UpDownCounter, node_id: int, amount: int)

var stock_id: int = -1  # Invalid ID

var company: String:
	get:
		return company
	set(value):
		company = value
		_update_labels()

var price: float = 10.0:
	get:
		return price
	set(value):
		price = snapped(value, 0.01)
		_update_labels()

var owned: int = 0

var change: float = 0:
	get:
		return change
	set(value):
		change = snapped(value, 0.01)
		_update_labels()

var old_price: float = 0:
	get:
		return old_price
	set(value):
		old_price = snapped(value, 0.01)
		_update_labels()

var dividend: float = 0:
	get:
		return dividend
	set(value):
		dividend = snapped(value, 0.01)
		_update_labels()

@onready var company_label := $"CompanyPanel/CompanyLabel"
@onready var price_label := $"PricePanel/PriceLabel"
@onready var owned_widget := $"OwnedPanel/Owned"
@onready var change_label := $"ChangePanel/ChangeLabel"
@onready var old_price_label := $"OldPricePanel/OldPriceLabel"
@onready var dividend_label := $"DividendPanel/DividendLabel"

var rng := RandomNumberGenerator.new()


func _ready():
	rng.randomize()
	_update_labels()


func _update_labels():
	if not is_inside_tree():
		return  # Short circuit until in tree

	company_label.text = company
	price_label.text = "%01.2f" % price
	owned_widget.value = owned
	change_label.text = "%01.2f" % change
	old_price_label.text = "%01.2f" % old_price
	dividend_label.text = "%01.2f" % dividend


func is_bankrupted() -> bool:
	return price <= 1


func issue_shares() -> bool:
	return price >= 30


func update_prices() -> void:
	pass


func _on_owned_value_changed(node: UpDownCounter, amount: int) -> void:
	# Emit enhanced signal
	owned = node.value
	emit_signal("owned_changed", node, stock_id, amount)
