extends Node

# Autoload for managing and accessing game data (Cards, Synergies)

var _cards: Dictionary = {}
var _synergies: Array[SynergyData] = []

# Paths to data directories
const CARDS_PATH = "res://WebOfFate/cards/" # Recursive search
const SYNERGIES_PATH = "res://WebOfFate/data/synergies/"

func _ready() -> void:
	_load_all_data()

## Reloads all data resources. useful for debugging or mods.
func reload_data() -> void:
	_cards.clear()
	_synergies.clear()
	_load_all_data()

func get_card_data(id: String) -> CardData:
	if _cards.has(id):
		return _cards[id]
	return null

func get_all_synergies() -> Array[SynergyData]:
	return _synergies

func _load_all_data() -> void:
	print("DataManager: Loading data...")
	_scan_cards_recursive(CARDS_PATH)
	_scan_synergies_recursive(SYNERGIES_PATH)
	print("DataManager: Loaded %d cards and %d synergies." % [_cards.size(), _synergies.size()])

func _scan_cards_recursive(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name != "." and file_name != "..":
					_scan_cards_recursive(path + file_name + "/")
			else:
				if file_name.ends_with(".tres") or file_name.ends_with(".res"):
					var res = load(path + file_name)
					if res is CardData:
						if res.id == "":
							printerr("DataManager: Card resource '%s' has no ID!" % file_name)
						elif _cards.has(res.id):
							printerr("DataManager: Duplicate card ID '%s' in '%s'!" % [res.id, file_name])
						else:
							_cards[res.id] = res
			file_name = dir.get_next()
	else:
		printerr("DataManager: Failed to open cards directory: " + path)

func _scan_synergies_recursive(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name != "." and file_name != "..":
					_scan_synergies_recursive(path + file_name + "/")
			else:
				if file_name.ends_with(".tres") or file_name.ends_with(".res"):
					var res = load(path + file_name)
					if res is SynergyData:
						_synergies.append(res)
			file_name = dir.get_next()
	else:
		# If directory doesn't exist yet, just warn and continue (might be creating it later)
		# print("DataManager: Synergies directory not found (yet): " + path)
		pass
