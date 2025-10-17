# BattleManager.gd
# Jadikan ini sebagai Autoload/Singleton dengan nama "BattleManager"
extends Node

# Signal yang akan dipancarkan saat battle dimulai dan selesai
signal battle_started
signal battle_ended(player_won: bool)

# Variabel sementara untuk menyimpan data PENTING selama battle.
var previous_scene_path: String
var prev_enemy_id = ""
var active_enemy_id: String
var active_enemy_scene_path: String # Ditambahkan kembali untuk referensi BattleScene
var previous_player_position: Vector3 = Vector3.ZERO # <-- LOKASI TERAKHIR PLAYER
@export var battle_scene_path: String = "res://Scenes/Battle Scene.tscn"

# `enemy_scene_path` ditambahkan sebagai parameter
func start_battle(enemy_id: String, enemy_scene_path: String, player_position: Vector3):
	# 1. Simpan data-data penting sebelum pindah scene
	previous_scene_path = get_tree().current_scene.scene_file_path
	active_enemy_id = enemy_id
	active_enemy_scene_path = enemy_scene_path # Simpan path scene musuh
	previous_player_position = player_position # <-- Posisi player disimpan di sini
	
	# 2. Pancarkan signal bahwa battle dimulai
	battle_started.emit()
	
	# 3. Pindah ke scene pertarungan
	get_tree().change_scene_to_file(battle_scene_path)


func end_battle(player_won: bool):
	if player_won:
		SaveManager.mark_enemy_as_defeated(active_enemy_id)
		SaveManager.save_game()
		print("Player won against ", active_enemy_id)
	
	# Bersihkan data temporer setelah battle selesai
	prev_enemy_id = active_enemy_id
	active_enemy_id = ""
	active_enemy_scene_path = ""
	
	# Pancarkan signal bahwa battle telah berakhir
	battle_ended.emit(player_won)
	
	# Kembali ke scene sebelumnya
	if not previous_scene_path.is_empty():
		get_tree().change_scene_to_file(previous_scene_path)
