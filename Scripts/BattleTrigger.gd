extends Area3D

@export var enemy_scene: PackedScene
@export var enemy_id: String = "unique_enemy_id"

@onready var confirmation_ui = $CanvasLayer/ConfirmationUI

func _ready():
	confirmation_ui.hide()
	
	if enemy_id in BattleManager.defeated_enemies:
		queue_free() 
		return

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	confirmation_ui.get_node("Panel/HBoxContainer/YesButton").pressed.connect(_on_yes_pressed)
	confirmation_ui.get_node("Panel/HBoxContainer/NoButton").pressed.connect(_on_no_pressed)


func _on_body_entered(body):
	if body.is_in_group("player"):
		confirmation_ui.show()

func _on_body_exited(body):
	if body.is_in_group("player"):
		confirmation_ui.hide()

func _on_yes_pressed():
	BattleManager.start_battle(enemy_scene.resource_path, get_tree().current_scene.scene_file_path)

func _on_no_pressed():
	confirmation_ui.hide()
