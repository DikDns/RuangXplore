# SaveManager.gd
# Jadikan ini sebagai Autoload/Singleton dengan nama "SaveManager"
extends Node

const SAVE_PATH = "user://savegame.json"

# Ini adalah 'cetakan' untuk data save baru.
# Semua data progres pemain disimpan di sini.
var _default_save_data: Dictionary = {
	"player_name": "Budi",
	"player_hp": 100, 
	"level_unlocked": 1,
	"defeated_enemies": []
}

# Variabel ini menampung data game yang sedang berjalan.
var current_save_data: Dictionary = _default_save_data.duplicate(true)


func _ready():
	load_game()


func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(current_save_data))
	print("Game saved!")


func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Starting new game.")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data_string = file.get_as_text()
	var parse_result = JSON.parse_string(data_string)

	if parse_result != null:
		# Pastikan semua key dari default ada di save data
		for key in _default_save_data.keys():
			if not parse_result.has(key):
				parse_result[key] = _default_save_data[key]
		current_save_data = parse_result
		print("Game loaded successfully.")
	else:
		print("Error loading save file.")


func has_save_data() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func reset_save_data():
	current_save_data = _default_save_data.duplicate(true)
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	print("Save data has been reset.")


func get_unlocked_level() -> int:
	return current_save_data.get("level_unlocked", 1)

func unlock_next_level():
	current_save_data.level_unlocked += 1

func is_enemy_defeated(enemy_id: String) -> bool:
	return enemy_id in current_save_data.get("defeated_enemies", [])


func mark_enemy_as_defeated(enemy_id: String):
	if not is_enemy_defeated(enemy_id):
		current_save_data.defeated_enemies.append(enemy_id)

# --- FUNGSI BARU UNTUK PLAYER HP ---

# Fungsi untuk mengambil HP player dari data save
func get_player_hp() -> int:
	return current_save_data.get("player_hp", 100)

# Fungsi untuk memperbarui HP player di data save
func set_player_hp(new_hp: int):
	current_save_data.player_hp = new_hp
