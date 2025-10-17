extends Area3D
class_name Portal

# Variabel yang bisa di-set dari editor
@export_file("*.tscn") var target_scene_path: String
@export var portal_name: String = "Lokasi Misterius"
@export var boss_id: String = "monster_kubus"

@onready var confirmation_ui = $ConfirmationUI
@onready var info_label = $ConfirmationUI/PanelContainer/MarginContainer/VBoxContainer/InfoLabel
@onready var yes_button = $ConfirmationUI/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/YesButton
@onready var no_button = $ConfirmationUI/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/NoButton

var player_in_area: Player = null

func _ready():
	# Sembunyikan UI di awal
	confirmation_ui.hide()
	
	# Set teks label sesuai nama portal
	info_label.text = "Masuk ke %s?" % portal_name
	
	# Hubungkan sinyal dari node ke fungsi di skrip ini
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	yes_button.pressed.connect(_on_yes_button_pressed)
	no_button.pressed.connect(_on_no_button_pressed)

func _on_body_entered(body: Node3D):
	# Cek apakah yang masuk adalah Player
	if body is Player:
		player_in_area = body
		confirmation_ui.show()
		# Tampilkan mouse biar bisa klik UI
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_body_exited(body: Node3D):
	# Cek apakah yang keluar adalah Player
	if body is Player:
		player_in_area = null
		confirmation_ui.hide()

func _on_yes_button_pressed():
	if not target_scene_path.is_empty():
		# Pindah scene!
		get_tree().change_scene_to_file(target_scene_path)

func _on_no_button_pressed():
	confirmation_ui.hide()
