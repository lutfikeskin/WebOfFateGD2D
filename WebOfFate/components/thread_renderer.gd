class_name ThreadRenderer extends Control

@export var line_width: float = 4.0
@export var default_color: Color = Color.WHITE
@export var red_thread_color: Color = Color(0.8, 0.2, 0.2)
@export var gold_thread_color: Color = Color(0.8, 0.7, 0.1)
@export var purple_thread_color: Color = Color(0.6, 0.2, 0.8)

var _lines: Dictionary = {} # connection_key -> Line2D

func _ready() -> void:
	# Defer setup to ensure slots are positioned
	# We wait a frame or two to be safe with layout
	get_tree().process_frame.connect(setup_threads)

func setup_threads() -> void:
	# Clear existing lines
	for line in _lines.values():
		line.queue_free()
	_lines.clear()

	var slots = LoomManager.get_all_slots()
	var processed_pairs = []

	for slot in slots:
		var connections = LoomManager.get_connections_for_slot(slot.slot_id)
		for conn in connections:
			var target_id = conn["target_slot"]
			var pair = [min(slot.slot_id, target_id), max(slot.slot_id, target_id)]
			
			if processed_pairs.has(pair):
				continue
			processed_pairs.append(pair)
			
			var target_slot = LoomManager.get_slot(target_id)
			if target_slot:
				_create_line(slot, target_slot, conn["type"])

func _create_line(slot1: Control, slot2: Control, type: int) -> void:
	var line = Line2D.new()
	line.width = line_width
	line.default_color = _get_color_for_type(type)
	line.antialiased = true
	
	# Add to scene
	add_child(line)
	
	# Store reference
	var key = "%d-%d" % [min(slot1.slot_id, slot2.slot_id), max(slot1.slot_id, slot2.slot_id)]
	_lines[key] = line
	
	# Set initial positions
	_update_line_positions(line, slot1, slot2)

func _process(_delta: float) -> void:
	# Keep lines connected to slots (in case of layout changes/resizing)
	update_all_line_positions()

func update_all_line_positions() -> void:
	var slots = LoomManager.get_all_slots()
	var processed_pairs = []
	
	for slot in slots:
		var connections = LoomManager.get_connections_for_slot(slot.slot_id)
		for conn in connections:
			var target_id = conn["target_slot"]
			var pair = [min(slot.slot_id, target_id), max(slot.slot_id, target_id)]
			if processed_pairs.has(pair): continue
			processed_pairs.append(pair)
			
			var key = "%d-%d" % [pair[0], pair[1]]
			if _lines.has(key):
				var target_slot = LoomManager.get_slot(target_id)
				if target_slot:
					_update_line_positions(_lines[key], slot, target_slot)

func _update_line_positions(line: Line2D, slot1: Control, slot2: Control) -> void:
	var start_pos = slot1.global_position + slot1.size / 2.0
	var end_pos = slot2.global_position + slot2.size / 2.0
	
	line.clear_points()
	line.add_point(line.to_local(start_pos))
	line.add_point(line.to_local(end_pos))

func _get_color_for_type(type: int) -> Color:
	match type:
		LoomManager.ThreadType.RED: return red_thread_color
		LoomManager.ThreadType.GOLD: return gold_thread_color
		LoomManager.ThreadType.PURPLE: return purple_thread_color
		_: return default_color

func highlight_connection(slot_id1: int, slot_id2: int, active: bool) -> void:
	var key = "%d-%d" % [min(slot_id1, slot_id2), max(slot_id1, slot_id2)]
	if _lines.has(key):
		var line = _lines[key]
		if active:
			line.width = line_width * 2.5
			var base_color = _get_original_color_for_line(slot_id1, slot_id2)
			line.default_color = base_color.lightened(0.5)
		else:
			line.width = line_width
			line.default_color = _get_original_color_for_line(slot_id1, slot_id2)

func _get_original_color_for_line(slot_id1: int, slot_id2: int) -> Color:
	var conns = LoomManager.get_connections_for_slot(slot_id1)
	for c in conns:
		if c["target_slot"] == slot_id2:
			return _get_color_for_type(c["type"])
	return default_color
