extends Node
class_name Bullet_Manager

var bullets_file_path = "res://gameplay/bullets/"

var bullet_scenes : Dictionary[String, PackedScene]
var bullet_database : Array[Dictionary]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_bullets_from_disk()
	create_bullet_database()
	print(bullet_scenes)
	print(bullet_database)
	print("validating")
	validate_bullet_data()

func add_bullet_to_dict(bullet_name:String, bullet_scene:PackedScene) -> void:
	bullet_scenes.get_or_add(bullet_name, bullet_scene)

func get_random_bullet(b_rarity: Globals.Rarity) -> PackedScene:
	var bullets_by_rarity = bullet_database.filter(func(entry): return entry.rarity == b_rarity)
	
	return bullets_by_rarity[randi_range(0, bullets_by_rarity.size())]

func load_bullets_from_disk() -> void:
	var dir_one = DirAccess.open(bullets_file_path)
	if dir_one == null:
		return
	dir_one.list_dir_begin()
	var dir_name = dir_one.get_next()
	while dir_name != "":  #loop over directories until null
		if dir_one.current_is_dir():
			var dir_two = DirAccess.open(bullets_file_path + "/" + dir_name)
			dir_two.list_dir_begin()
			var file_name = dir_two.get_next()
			while file_name != "": #loop over files until null
				if file_name.ends_with(".tscn"):
					var scene = load(bullets_file_path + "/" + dir_name + "/" + file_name)
					bullet_scenes.get_or_add(file_name.trim_suffix(".tscn"), scene)
				file_name = dir_two.get_next()
			dir_two.list_dir_end()
		dir_name = dir_one.get_next()
	dir_one.list_dir_end()
	pass


func create_bullet_database() -> void:
	for key in bullet_scenes:
		var state = bullet_scenes[key].get_state()
		var property_count : int = state.get_node_property_count(0)
		var data : Dictionary = {"bullet_name": key}  # Add name for reference
		for i in range(property_count):
			var prop_name = state.get_node_property_name(0, i)
			var prop_value = state.get_node_property_value(0, i)
			if not prop_name == "script":
				data[prop_name] = prop_value
		bullet_database.append(data)

func validate_bullet_data() -> void:
	var validate_successful = true
	for key in bullet_scenes:
		if bullet_scenes[key] == null:
			validate_successful = false
			print(key + " showing null in bullet_data")
	for i in bullet_database.size():
		var data = bullet_database[i]
		if data.get("damage")== 0.1:
			validate_successful = false
			print(data[0] + " damage set to" + data.get("damage"))
		if data.get("speed") == 0.1:
			validate_successful = false
			print(data[0] + " speed set to" + data.get("speed"))
		if data.get("rarity") == 0:
			validate_successful = false
			print(data[0] + " rarity set to" + data.get("rarity"))
	
	print("Validation Successful = " , validate_successful)
	pass
