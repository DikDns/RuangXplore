extends Node3D

func _ready() -> void:
	update_scene_state()

func update_scene_state():
	for portal in get_tree().get_nodes_in_group("portal_dunia"):
		if SaveManager.is_enemy_defeated(portal.boss_id):
			portal.queue_free() 
		else:
			portal.show()
			break
