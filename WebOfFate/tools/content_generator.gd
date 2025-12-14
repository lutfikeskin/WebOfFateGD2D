@tool
extends EditorScript

# Paths
const CARD_PATH_BASE = "res://WebOfFate/data/cards/"
const SYN_PATH_BASE = "res://WebOfFate/data/synergies/"

# Enums (Manual copy to avoid dependency issues in tool mode if classes aren't compiled)
enum Category {CHARACTER = 0, ITEM = 1, EVENT = 2, LOCATION = 3, DISASTER = 4}
enum Rarity {COMMON = 0, RARE = 1, EPIC = 2, LEGENDARY = 3}

func _run() -> void:
	print("Starting Content Generation...")
	generate_cards()
	generate_synergies()
	print("Content Generation Complete!")

func generate_cards() -> void:
	var cards = [
		# --- CHARACTERS (15) ---
		{"id": "brave_squire", "name": "Brave Squire", "desc": "A young warrior proving their worth.", "cat": Category.CHARACTER, "dp": 8, "chaos": 3, "tags": ["heroic", "human"], "rarity": Rarity.COMMON},
		{"id": "wizened_sage", "name": "Wizened Sage", "desc": "Knows the secrets of the threads.", "cat": Category.CHARACTER, "dp": 12, "chaos": 1, "tags": ["mystic", "human"], "rarity": Rarity.RARE},
		{"id": "dark_assassin", "name": "Dark Assassin", "desc": "Moves in shadows.", "cat": Category.CHARACTER, "dp": 10, "chaos": 15, "tags": ["violence", "villain"], "rarity": Rarity.RARE},
		{"id": "wandering_minstrel", "name": "Wandering Minstrel", "desc": "Sings songs of old.", "cat": Category.CHARACTER, "dp": 15, "chaos": 5, "tags": ["human", "support"], "rarity": Rarity.COMMON},
		{"id": "high_priestess", "name": "High Priestess", "desc": "Guardian of the sacred texts.", "cat": Category.CHARACTER, "dp": 20, "chaos": 0, "tags": ["mystic", "holy"], "rarity": Rarity.EPIC},
		{"id": "mad_king", "name": "Mad King", "desc": "Once a ruler, now a chaos bringer.", "cat": Category.CHARACTER, "dp": 5, "chaos": 25, "tags": ["villain", "royalty", "tragedy"], "rarity": Rarity.EPIC},
		{"id": "noble_knight", "name": "Noble Knight", "desc": "Defender of the realm.", "cat": Category.CHARACTER, "dp": 18, "chaos": 5, "tags": ["heroic", "violence"], "rarity": Rarity.RARE},
		{"id": "forest_witch", "name": "Forest Witch", "desc": "brews potions in the deep woods.", "cat": Category.CHARACTER, "dp": 12, "chaos": 12, "tags": ["mystic", "nature"], "rarity": Rarity.COMMON},
		{"id": "merchant_prince", "name": "Merchant Prince", "desc": "Trades in secrets and gold.", "cat": Category.CHARACTER, "dp": 15, "chaos": 8, "tags": ["human", "wealth"], "rarity": Rarity.RARE},
		{"id": "fallen_angel", "name": "Fallen Angel", "desc": "Cast out from the heavens.", "cat": Category.CHARACTER, "dp": 30, "chaos": 30, "tags": ["mythic", "tragedy"], "rarity": Rarity.LEGENDARY},
		{"id": "swamp_hag", "name": "Swamp Hag", "desc": "Lurks in the murky waters.", "cat": Category.CHARACTER, "dp": 8, "chaos": 10, "tags": ["villain", "nature"], "rarity": Rarity.COMMON},
		{"id": "grand_inquisitor", "name": "Grand Inquisitor", "desc": "Purges heresy with fire.", "cat": Category.CHARACTER, "dp": 10, "chaos": 20, "tags": ["violence", "holy"], "rarity": Rarity.EPIC},
		{"id": "star_child", "name": "Star Child", "desc": "Born from a falling star.", "cat": Category.CHARACTER, "dp": 25, "chaos": 5, "tags": ["mystic", "alien"], "rarity": Rarity.EPIC},
		{"id": "spider_queen", "name": "Spider Queen", "desc": "Weaves webs of deception.", "cat": Category.CHARACTER, "dp": 15, "chaos": 20, "tags": ["villain", "monster"], "rarity": Rarity.RARE},
		{"id": "lost_traveler", "name": "Lost Traveler", "desc": "Wanders the paths of fate.", "cat": Category.CHARACTER, "dp": 5, "chaos": 5, "tags": ["human", "tragedy"], "rarity": Rarity.COMMON},

		# --- ITEMS (10) ---
		{"id": "ancient_scroll", "name": "Ancient Scroll", "desc": "Contains forgotten prophecies.", "cat": Category.ITEM, "dp": 15, "chaos": 2, "tags": ["mystic", "knowledge"], "rarity": Rarity.COMMON},
		{"id": "cursed_dagger", "name": "Cursed Dagger", "desc": "Hungers for blood.", "cat": Category.ITEM, "dp": 5, "chaos": 15, "tags": ["violence", "cursed"], "rarity": Rarity.COMMON},
		{"id": "golden_chalice", "name": "Golden Chalice", "desc": "A cup fit for kings.", "cat": Category.ITEM, "dp": 20, "chaos": 0, "tags": ["wealth", "holy"], "rarity": Rarity.RARE},
		{"id": "broken_shuttle", "name": "Broken Shuttle", "desc": "A piece of a destroyed loom.", "cat": Category.ITEM, "dp": 2, "chaos": 10, "tags": ["tool", "tragedy"], "rarity": Rarity.COMMON},
		{"id": "mirror_of_truth", "name": "Mirror of Truth", "desc": "Reveals one's true self.", "cat": Category.ITEM, "dp": 25, "chaos": 5, "tags": ["mystic", "relic"], "rarity": Rarity.EPIC},
		{"id": "dragons_tooth", "name": "Dragon's Tooth", "desc": "A sharp trophy from a beast.", "cat": Category.ITEM, "dp": 12, "chaos": 8, "tags": ["trophy", "violence"], "rarity": Rarity.RARE},
		{"id": "phoenix_feather", "name": "Phoenix Feather", "desc": "Warm to the touch.", "cat": Category.ITEM, "dp": 30, "chaos": 0, "tags": ["mystic", "hope"], "rarity": Rarity.LEGENDARY},
		{"id": "iron_shackles", "name": "Iron Shackles", "desc": "Signs of imprisonment.", "cat": Category.ITEM, "dp": 5, "chaos": 10, "tags": ["tool", "oppression"], "rarity": Rarity.COMMON},
		{"id": "royal_scepter", "name": "Royal Scepter", "desc": "Symbol of authority.", "cat": Category.ITEM, "dp": 22, "chaos": 5, "tags": ["wealth", "royalty"], "rarity": Rarity.EPIC},
		{"id": "poison_vial", "name": "Poison Vial", "desc": "A subtle weapon.", "cat": Category.ITEM, "dp": 8, "chaos": 12, "tags": ["violence", "tool"], "rarity": Rarity.COMMON},

		# --- EVENTS (10) ---
		{"id": "sudden_storm", "name": "Sudden Storm", "desc": "Winds howl and lightning strikes.", "cat": Category.EVENT, "dp": 10, "chaos": 15, "tags": ["nature", "disaster"], "rarity": Rarity.COMMON},
		{"id": "celestial_alignment", "name": "Celestial Alignment", "desc": "The stars align in favor.", "cat": Category.EVENT, "dp": 35, "chaos": 0, "tags": ["mystic", "fate"], "rarity": Rarity.EPIC},
		{"id": "peace_treaty", "name": "Peace Treaty", "desc": "Enemies lay down arms.", "cat": Category.EVENT, "dp": 40, "chaos": - 10, "tags": ["political", "hope"], "rarity": Rarity.EPIC},
		{"id": "market_day", "name": "Market Day", "desc": "Trade flourishes.", "cat": Category.EVENT, "dp": 15, "chaos": 5, "tags": ["wealth", "social"], "rarity": Rarity.COMMON},
		{"id": "festival_of_lights", "name": "Festival of Lights", "desc": "Celebration fills the streets.", "cat": Category.EVENT, "dp": 25, "chaos": 2, "tags": ["social", "joy"], "rarity": Rarity.RARE},
		{"id": "dark_ritual", "name": "Dark Ritual", "desc": "Shadows gather.", "cat": Category.EVENT, "dp": 10, "chaos": 30, "tags": ["mystic", "cursed"], "rarity": Rarity.RARE},
		{"id": "royal_wedding", "name": "Royal Wedding", "desc": "Two houses unite.", "cat": Category.EVENT, "dp": 50, "chaos": 10, "tags": ["royalty", "romance"], "rarity": Rarity.LEGENDARY},
		{"id": "famine", "name": "Famine", "desc": "Crops fail.", "cat": Category.EVENT, "dp": 5, "chaos": 20, "tags": ["tragedy", "nature"], "rarity": Rarity.COMMON},
		{"id": "discovery", "name": "Great Discovery", "desc": "New lands found.", "cat": Category.EVENT, "dp": 30, "chaos": 5, "tags": ["knowledge", "hope"], "rarity": Rarity.RARE},
		{"id": "betrayal", "name": "Betrayal", "desc": "A knife in the back.", "cat": Category.EVENT, "dp": 10, "chaos": 40, "tags": ["tragedy", "violence", "betrayal"], "rarity": Rarity.EPIC},

		# --- LOCATIONS (10) ---
		{"id": "ivory_tower", "name": "Ivory Tower", "desc": "Seat of high magic.", "cat": Category.LOCATION, "dp": 20, "chaos": 2, "tags": ["mystic", "structure"], "rarity": Rarity.RARE},
		{"id": "dark_forest", "name": "Dark Forest", "desc": "Many enter, few return.", "cat": Category.LOCATION, "dp": 10, "chaos": 15, "tags": ["nature", "danger"], "rarity": Rarity.COMMON},
		{"id": "sunken_city", "name": "Sunken City", "desc": "Lost beneath the waves.", "cat": Category.LOCATION, "dp": 25, "chaos": 10, "tags": ["mythic", "water"], "rarity": Rarity.EPIC},
		{"id": "crossroads", "name": "Crossroads", "desc": "Where decisions are made.", "cat": Category.LOCATION, "dp": 15, "chaos": 15, "tags": ["mystic", "travel"], "rarity": Rarity.COMMON},
		{"id": "grand_bazaar", "name": "Grand Bazaar", "desc": "Everything plays a price.", "cat": Category.LOCATION, "dp": 18, "chaos": 8, "tags": ["wealth", "place"], "rarity": Rarity.RARE},
		{"id": "throne_room", "name": "Throne Room", "desc": "Center of power.", "cat": Category.LOCATION, "dp": 30, "chaos": 5, "tags": ["royalty", "structure"], "rarity": Rarity.EPIC},
		{"id": "battlefield", "name": "Battlefield", "desc": "Soaked in blood.", "cat": Category.LOCATION, "dp": 10, "chaos": 30, "tags": ["violence", "place"], "rarity": Rarity.RARE},
		{"id": "secret_library", "name": "Secret Library", "desc": "Hidden knowledge.", "cat": Category.LOCATION, "dp": 22, "chaos": 0, "tags": ["knowledge", "place"], "rarity": Rarity.RARE},
		{"id": "temple_of_fate", "name": "Temple of Fate", "desc": "Where the loom resides.", "cat": Category.LOCATION, "dp": 40, "chaos": 0, "tags": ["holy", "structure"], "rarity": Rarity.LEGENDARY},
		{"id": "beggars_alley", "name": "Beggars Alley", "desc": "The lowest point.", "cat": Category.LOCATION, "dp": 5, "chaos": 10, "tags": ["tragedy", "place"], "rarity": Rarity.COMMON},

		# --- DISASTERS (5) ---
		{"id": "plague", "name": "Plague", "desc": "Sickness spreads.", "cat": Category.DISASTER, "dp": 0, "chaos": 40, "tags": ["tragedy", "sickness"], "rarity": Rarity.RARE},
		{"id": "dragon_attack", "name": "Dragon Attack", "desc": "Fire from above.", "cat": Category.DISASTER, "dp": 10, "chaos": 50, "tags": ["violence", "monster"], "rarity": Rarity.EPIC},
		{"id": "earthquake", "name": "Earthquake", "desc": "The ground shakes.", "cat": Category.DISASTER, "dp": 5, "chaos": 35, "tags": ["nature", "disaster"], "rarity": Rarity.COMMON},
		{"id": "civil_war", "name": "Civil War", "desc": "Brother against brother.", "cat": Category.DISASTER, "dp": 10, "chaos": 45, "tags": ["violence", "political"], "rarity": Rarity.EPIC},
		{"id": "void_rift", "name": "Void Rift", "desc": "Reality tears apart.", "cat": Category.DISASTER, "dp": 0, "chaos": 60, "tags": ["mystic", "cursed"], "rarity": Rarity.LEGENDARY}
	] # Total 50

	for data in cards:
		create_card(data)

func generate_synergies() -> void:
	var synergies = [
		{"id": "knight_squire", "c1": "noble_knight", "c2": "brave_squire", "dp": 40, "chaos": - 5, "msg": "The Knight mentors the Squire! A legacy begins."},
		{"id": "assassin_dagger", "c1": "dark_assassin", "c2": "cursed_dagger", "dp": 30, "chaos": 30, "msg": "The Assassin strikes with the Cursed Dagger! Blood flows."},
		{"id": "priestess_temple", "c1": "high_priestess", "c2": "temple_of_fate", "dp": 80, "chaos": - 10, "msg": "The High Priestess consecrates the Temple! Fate aligns."},
		{"id": "king_scepter", "c1": "mad_king", "c2": "royal_scepter", "dp": 30, "chaos": 40, "msg": "The Mad King wields absolute power! Tyranny reigns."},
		{"id": "witch_forest", "c1": "forest_witch", "c2": "dark_forest", "dp": 35, "chaos": 10, "msg": "The Witch draws power from her Woods."},
		{"id": "minstrel_festival", "c1": "wandering_minstrel", "c2": "festival_of_lights", "dp": 50, "chaos": 0, "msg": "The Minstrel leads the celebration! Pure joy."},
		{"id": "mirror_angel", "c1": "mirror_of_truth", "c2": "fallen_angel", "dp": 60, "chaos": 20, "msg": "The Angel sees their fallen grace. A moment of sorrow."},
		{"id": "dragon_tooth_attack", "c1": "dragons_tooth", "c2": "dragon_attack", "dp": 40, "chaos": 40, "msg": "The tooth summons its master! Fire consumes all."},
		{"id": "wedding_treaty", "c1": "royal_wedding", "c2": "peace_treaty", "dp": 100, "chaos": - 20, "msg": "A union seals the peace!  Golden Age begins."},
		{"id": "betrayal_shackles", "c1": "betrayal", "c2": "iron_shackles", "dp": 20, "chaos": 35, "msg": "Treason inevitably leads to chains."},
		{"id": "phoenix_fire", "c1": "phoenix_feather", "c2": "sudden_storm", "dp": 50, "chaos": 10, "msg": "The Phoenix rises amidst the storm!"},
		{"id": "sage_scroll", "c1": "wizened_sage", "c2": "ancient_scroll", "dp": 45, "chaos": - 5, "msg": "The Sage deciphers the ancient prophecy."},
		{"id": "bazaar_prince", "c1": "grand_bazaar", "c2": "merchant_prince", "dp": 40, "chaos": 5, "msg": "The Prince buys the loyalty of the city."}
	]
	
	for data in synergies:
		create_synergy(data)

func create_card(data: Dictionary) -> void:
	var res = CardData.new()
	res.id = data.id
	res.display_name = data.name # Localization key ideally, but putting raw for now
	res.description = data.desc
	res.category = data.cat
	res.base_dp = data.dp
	res.base_chaos = data.chaos
	res.tags.assign(data.tags)
	res.rarity = data.rarity
	
	# Determine path based on category
	var folder = "characters"
	match data.cat:
		Category.ITEM: folder = "items"
		Category.EVENT: folder = "events"
		Category.LOCATION: folder = "locations"
		Category.DISASTER: folder = "disasters"
	
	var path = CARD_PATH_BASE + folder + "/" + data.id + ".tres"
	var err = ResourceSaver.save(res, path)
	if err != OK:
		print("Error saving card: " + path + " Code: " + str(err))
	else:
		print("Saved card: " + path)

func create_synergy(data: Dictionary) -> void:
	var res = SynergyData.new()
	res.id = data.id
	res.card_id_1 = data.c1
	res.card_id_2 = data.c2
	res.result_dp = data.dp
	res.result_chaos = data.chaos
	res.remove_cards = true # Default true
	res.log_message = data.msg
	
	var path = SYN_PATH_BASE + data.id + ".tres"
	var err = ResourceSaver.save(res, path)
	if err != OK:
		print("Error saving synergy: " + path + " Code: " + str(err))
	else:
		print("Saved synergy: " + path)
