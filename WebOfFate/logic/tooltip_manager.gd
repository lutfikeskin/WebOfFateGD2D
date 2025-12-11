extends Node

# Autoload: TooltipManager
# Manages the display of tooltips.

signal show_tooltip(data: Dictionary, position: Vector2)
signal hide_tooltip()

var _active_card: Node = null

func request_show(card_node: Node) -> void:
	if not card_node.get("card_data"):
		return
		
	var data = card_node.card_data
	if not data is CardData:
		return
		
	_active_card = card_node
	
	var info = {
		"title": tr(data.display_name),
		"description": tr(data.description) if "description" in data else "",
		"tags": data.tags if "tags" in data else [],
		"dp": data.base_dp,
		"chaos": data.base_chaos
	}
	
	# Determine position (e.g., to the right or top of the card)
	var pos = card_node.global_position
	# Adjust to show next to mouse or card
	pos = card_node.get_global_mouse_position() + Vector2(20, 20)
	
	show_tooltip.emit(info, pos)

func request_hide() -> void:
	_active_card = null
	hide_tooltip.emit()

