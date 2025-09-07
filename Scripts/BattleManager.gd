extends Node

var current_enemy_scene_path: String
var previous_scene_path: String
var player_current_hp: int = 100
var player_max_hp: int = 100

var defeated_enemies = []

func start_battle(enemy_path: String, return_scene_path: String):
	current_enemy_scene_path = enemy_path
	previous_scene_path = return_scene_path
	get_tree().change_scene_to_file("res://Scenes/Battle Scene.tscn")

func end_battle(player_won: bool, enemy_id: String):
	if player_won:
		if not enemy_id in defeated_enemies:
			defeated_enemies.append(enemy_id)
	
	get_tree().change_scene_to_file(previous_scene_path)
