extends Control
class_name ThreadRenderer

# Visual configuration
@export var line_width: float = 4.0
@export var thread_colors = {
	LoomManager.ThreadType.WHITE: Color.WHITE,
	LoomManager.ThreadType.RED: Color(0.8, 0.2, 0.2), # Red
	LoomManager.ThreadType.GOLD: Color(1.0, 0.8, 0.2), # Gold
	LoomManager.ThreadType.PURPLE: Color(0.6, 0.2, 0.8) # Purple
}

# Relationship visual colors
const BOND_COLOR := Color(1.0, 0.5, 0.8) # Pink glow for bonded cards
const GRUDGE_COLOR := Color(0.4, 0.0, 0.0) # Dark red for enemies

# Stores Line2D nodes: key is [min_id, max_id], value is Line2D
var _lines: Dictionary = {}
var _ghost_lines: Array[Line2D] = []
var _relationship_overlays: Dictionary = {} # Overlay lines for relationships

func _process(_delta: float) -> void:
	update_all_line_positions()
	_update_relationship_overlays()

func update_all_line_positions() -> void:
	var slots = LoomManager.get_all_slots()
	
	# First, ensure we have lines for all connections
	for slot in slots:
		var slot_id = slot.slot_id
		var connections = LoomManager.get_connections_for_slot(slot_id)
		
		for conn in connections:
			var target_id = conn["target_slot"]
			var type = conn["type"]
			
			# Create a unique key for the connection (order independent)
			var key = [min(slot_id, target_id), max(slot_id, target_id)]
			
			if not _lines.has(key):
				_create_line(key, type)
			
			# Update position
			_update_line_positions(key, slot_id, target_id)

func _create_line(key: Array, type: int) -> void:
	var line = Line2D.new()
	line.width = line_width
	line.default_color = thread_colors.get(type, Color.WHITE)
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	# Add to scene
	add_child(line)
	_lines[key] = line

func _update_line_positions(key: Array, id1: int, id2: int) -> void:
	var line = _lines[key]
	var slot1 = LoomManager.get_slot(id1)
	var slot2 = LoomManager.get_slot(id2)
	
	if slot1 and slot2:
		# Convert global positions to local for the Line2D (which is child of this control)
		# Assuming slots are siblings or in same canvas layer context basically
		# Use get_global_rect().get_center() for accurate center
		var start_pos = slot1.get_global_rect().get_center()
		var end_pos = slot2.get_global_rect().get_center()
		
		line.clear_points()
		line.add_point(line.to_local(start_pos))
		line.add_point(line.to_local(end_pos))

# Highlight logic: change visual style if a synergy is active
func highlight_connection(id1: int, id2: int, active: bool) -> void:
	var key = [min(id1, id2), max(id1, id2)]
	if _lines.has(key):
		var line = _lines[key]
		if active:
			line.width = line_width * 2.0
			line.modulate = Color(1.5, 1.5, 1.5) # Glow effect
		else:
			line.width = line_width
			line.modulate = Color.WHITE

## Update relationship visual overlays based on Chronicle data
func _update_relationship_overlays() -> void:
	# Clear old overlays
	for overlay in _relationship_overlays.values():
		if is_instance_valid(overlay):
			overlay.queue_free()
	_relationship_overlays.clear()
	
	# Check if Chronicle is available
	if not ChronicleManager or not ChronicleManager.chronicle:
		return
	
	var slots = LoomManager.get_all_slots()
	
	# Check all slot pairs for relationship data
	for i in range(slots.size()):
		for j in range(i + 1, slots.size()):
			var slot1 = slots[i]
			var slot2 = slots[j]
			
			if not slot1.has_card() or not slot2.has_card():
				continue
			
			var card1_id = _get_card_id_from_slot(slot1)
			var card2_id = _get_card_id_from_slot(slot2)
			
			if card1_id.is_empty() or card2_id.is_empty():
				continue
			
			# Check relationship
			var rel = ChronicleManager.chronicle.get_relationship(card1_id, card2_id)
			if not rel:
				continue
			
			# Only show overlay for strong relationships
			if rel.affinity >= 0.5 or rel.affinity <= -0.4:
				_create_relationship_overlay(slot1, slot2, rel.affinity)

func _create_relationship_overlay(slot1, slot2, affinity: float) -> void:
	var overlay = Line2D.new()
	overlay.width = line_width * 1.5
	
	if affinity >= 0.5:
		overlay.default_color = BOND_COLOR
		overlay.default_color.a = 0.6
	else:
		overlay.default_color = GRUDGE_COLOR
		overlay.default_color.a = 0.8
	
	overlay.begin_cap_mode = Line2D.LINE_CAP_ROUND
	overlay.end_cap_mode = Line2D.LINE_CAP_ROUND
	overlay.z_index = -1 # Behind regular threads
	
	add_child(overlay)
	
	var start_pos = slot1.get_global_rect().get_center()
	var end_pos = slot2.get_global_rect().get_center()
	
	overlay.add_point(overlay.to_local(start_pos))
	overlay.add_point(overlay.to_local(end_pos))
	
	var key = "%s_%s" % [slot1.slot_id, slot2.slot_id]
	_relationship_overlays[key] = overlay

func _get_card_id_from_slot(slot) -> String:
	if slot.has_method("get_card"):
		var card = slot.get_card()
		if card and card.card_data:
			return card.card_data.id
	elif slot.has_method("has_card") and slot.has_card():
		# Try alternative access
		var children = slot.get_children()
		for child in children:
			if child.has_method("get") and child.get("card_data"):
				return child.card_data.id
	return ""

# --- GHOST LINES (Intent Prediction) ---

func show_ghost_connections(target_slot_id: int) -> void:
	_clear_ghost_lines()
	
	var connections = LoomManager.get_connections_for_slot(target_slot_id)
	var target_slot = LoomManager.get_slot(target_slot_id)
	
	if not target_slot: return
	
	var mouse_pos = get_global_mouse_position() # Ghost lines connect to mouse cursor (held card)
	
	for conn in connections:
		var neighbor_id = conn["target_slot"]
		var neighbor_slot = LoomManager.get_slot(neighbor_id)
		var type = conn["type"]
		
		if neighbor_slot:
			var line = Line2D.new()
			line.width = line_width * 0.8
			var col = thread_colors.get(type, Color.WHITE)
			col.a = 0.5 # Transparent
			line.default_color = col
			line.begin_cap_mode = Line2D.LINE_CAP_ROUND
			line.end_cap_mode = Line2D.LINE_CAP_ROUND
			
			add_child(line)
			_ghost_lines.append(line)
			
			var start_pos = neighbor_slot.get_global_rect().get_center()
			# End pos is the mouse cursor (simulating where the card will drop)
			var end_pos = mouse_pos
			
			line.add_point(line.to_local(start_pos))
			line.add_point(line.to_local(end_pos))

func hide_ghost_connections() -> void:
	_clear_ghost_lines()

func _clear_ghost_lines() -> void:
	for line in _ghost_lines:
		line.queue_free()
	_ghost_lines.clear()
