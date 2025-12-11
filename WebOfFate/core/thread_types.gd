class_name ThreadTypes

enum Type {
	NONE,
	WHITE, # Silk
	RED,   # Blood
	GOLD,  # Destiny
	PURPLE # Shadow
}

# Thread properties and logic can go here
static func get_color(type: Type) -> Color:
	match type:
		Type.WHITE: return Color.WHITE
		Type.RED: return Color.RED
		Type.GOLD: return Color.GOLD
		Type.PURPLE: return Color.PURPLE
		_: return Color.TRANSPARENT

