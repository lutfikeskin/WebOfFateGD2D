@tool
extends SceneTree

func _init():
	print("Starting card resource update...")
	update_card_resources("res://WebOfFate/data/cards/")
	print("Finished updating card resources.")
	quit()

func update_card_resources(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if file_name != "." and file_name != "..":
					update_card_resources(path + "/" + file_name)
			elif file_name.ends_with(".tres"):
				var full_path = path + "/" + file_name
				var resource = load(full_path)
				if resource is CardData:
					var card_id = resource.id
					if card_id:
						print("Updating: " + card_id)
						resource.display_name = "CARD_NAME_" + card_id
						resource.description = "CARD_DESC_" + card_id
						ResourceSaver.save(resource, full_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

