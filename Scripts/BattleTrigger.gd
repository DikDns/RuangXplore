extends Area3D

@export var enemy_scene: PackedScene
@export var enemy_id: String # ID ini HARUS SAMA dengan enemy_id di dalam scene musuh

@onready var confirmation_ui = $CanvasLayer/ConfirmationUI
@onready var yes_button = $CanvasLayer/ConfirmationUI/Panel/HBoxContainer/YesButton
@onready var no_button = $CanvasLayer/ConfirmationUI/Panel/HBoxContainer/NoButton

func _ready():
	# Sembunyikan UI di awal
	confirmation_ui.hide()
	# Hubungkan sinyal
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	yes_button.pressed.connect(_on_yes_button_pressed)
	no_button.pressed.connect(_on_no_button_pressed)

func _on_body_entered(body):
	if body.is_in_group("player"):
		confirmation_ui.show()

func _on_body_exited(body):
	if body.is_in_group("player"):
		confirmation_ui.hide()

func _on_yes_button_pressed():
	# Dapatkan node player yang ada di scene saat ini
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		BattleManager.start_battle(player_node, enemy_scene, enemy_id)

func _on_no_button_pressed():
	confirmation_ui.hide()
