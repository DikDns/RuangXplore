extends Control

# Variabel ini akan jadi "saklar" global yang bisa dibaca oleh skrip Player
var joystick_vector := Vector2.ZERO
var is_jump_pressed := false
var is_sprint_pressed := false
var is_interact_pressed := false

# Hubungkan node dari scene ke skrip
@onready var virtual_joystick = $"Virtual Joystick"
@onready var jump_button = $MarginContainer/Panel/HBoxContainer/VBoxContainer/JumpButton
@onready var sprint_button = $MarginContainer/Panel/HBoxContainer/SprintButton
@onready var interact_button = $MarginContainer/Panel/HBoxContainer/VBoxContainer/InteractButton

func _ready():
	# Hubungkan sinyal dari joystick dan tombol ke fungsi di skrip ini
	jump_button.connect("toggled", func(is_toggled): is_jump_pressed = is_toggled)
	sprint_button.connect("toggled", func(is_toggled): is_sprint_pressed = is_toggled)
	interact_button.connect("pressed", _on_interact_button_pressed)
	
func _on_interact_button_pressed():
	# Karena tombol interaksi cuma perlu sekali tekan, kita set true lalu langsung false
	is_interact_pressed = true
	# Kita set false lagi di frame berikutnya biar gak dianggap neken terus
	await get_tree().process_frame
	is_interact_pressed = false
