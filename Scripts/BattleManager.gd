extends Node

# Data Player
var player_max_hp: int = 100
var player_current_hp: int = 100

# Data Battle Saat Ini
var previous_scene_path: String
var current_enemy_scene_path: String
var current_enemy_id: String

# Data Progres
var defeated_enemies: Array[String] = []

func start_battle(player: Player, enemy_scene: PackedScene, enemy_id: String):
	# Simpan semua data yang dibutuhkan sebelum pindah scene
	player_current_hp = player.current_hp
	previous_scene_path = get_tree().current_scene.scene_file_path
	current_enemy_scene_path = enemy_scene.resource_path
	current_enemy_id = enemy_id
	
	# Pindah ke scene pertarungan
	get_tree().change_scene_to_file("res://Scenes/Battle Scene.tscn")

func end_battle(player_won: bool):
	if player_won:
		# Jika menang, catat ID musuh yang dikalahkan
		if not current_enemy_id in defeated_enemies:
			defeated_enemies.append(current_enemy_id)
	else:
		# Jika kalah, reset HP player
		player_current_hp = player_max_hp
	
	# Hapus data battle saat ini
	current_enemy_scene_path = ""
	current_enemy_id = ""
	
	# Kembali ke scene sebelumnya
	if not previous_scene_path.is_empty():
		get_tree().change_scene_to_file(previous_scene_path)
