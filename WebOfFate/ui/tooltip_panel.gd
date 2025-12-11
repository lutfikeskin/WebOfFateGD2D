extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescLabel
@onready var stats_label: Label = %StatsLabel
@onready var tags_container: HBoxContainer = %TagsContainer

func _ready() -> void:
	TooltipManager.show_tooltip.connect(_on_show_tooltip)
	TooltipManager.hide_tooltip.connect(_on_hide_tooltip)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
	if visible:
		# Follow mouse slightly offset
		var target_pos = get_global_mouse_position() + Vector2(15, 15)
		
		# Keep inside screen
		var vp_size = get_viewport_rect().size
		if target_pos.x + size.x > vp_size.x:
			target_pos.x = vp_size.x - size.x
		if target_pos.y + size.y > vp_size.y:
			target_pos.y = vp_size.y - size.y
			
		global_position = target_pos

func _on_show_tooltip(info: Dictionary, _pos: Vector2) -> void:
	title_label.text = info.title
	desc_label.text = info.description
	
	var dp = info.get("dp", 0)
	var chaos = info.get("chaos", 0)
	stats_label.text = "DP: %d | Chaos: %d" % [dp, chaos]
	
	# Clear tags
	for child in tags_container.get_children():
		child.queue_free()
		
	for tag in info.tags:
		var tag_lbl = Label.new()
		tag_lbl.text = tr(tag.capitalize())
		tag_lbl.add_theme_font_size_override("font_size", 12)
		tag_lbl.add_theme_color_override("font_color", Color.LIGHT_BLUE)
		tags_container.add_child(tag_lbl)
	
	visible = true

func _on_hide_tooltip() -> void:
	visible = false

