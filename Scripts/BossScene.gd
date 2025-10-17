extends Node3D

@export var boss_id: String = "unique_boss_id_1" # <-- Ganti ini di Inspector untuk tiap boss
@export var post_battle_dialogue: DialogueResource
@export var post_battle_win_title: String = "boss_defeated"
@export var post_battle_lose_title: String = "lose"
@export var place_name = "kubus"

@onready var boss_node = $Boss 
@onready var portal_node = $PortalSekolah
@onready var player = $Player

func _ready() -> void:
	update_scene_state()
	
	if BattleManager.previous_player_position != Vector3.ZERO:
		player.global_position = BattleManager.previous_player_position
		BattleManager.previous_player_position = Vector3.ZERO

func update_scene_state():
	for keroco in get_tree().get_nodes_in_group(place_name + "_kerocos"):
		if SaveManager.is_enemy_defeated(keroco.enemy_id):
			keroco.queue_free()
	
	if SaveManager.is_enemy_defeated(boss_id):
		boss_node.queue_free()
		portal_node.show()
		
		if post_battle_dialogue:
			DialogueManager.show_dialogue_balloon(post_battle_dialogue, post_battle_win_title)
		return
	else:
		boss_node.show()
		portal_node.queue_free()
	
	
	if BattleManager.prev_enemy_id.is_empty(): return
	
	if not SaveManager.is_enemy_defeated(BattleManager.prev_enemy_id):
			DialogueManager.show_dialogue_balloon(post_battle_dialogue, post_battle_lose_title)
