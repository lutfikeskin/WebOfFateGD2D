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

# Stores Line2D nodes: key is [min_id, max_id], value is Line2D
var _lines: Dictionary = {}
var _ghost_lines: Array[Line2D] = []

func _process(_delta: float) -> void:
	update_all_line_positions()

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
