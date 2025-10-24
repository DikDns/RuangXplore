extends CharacterBody3D
class_name Player

#--- REFERENSI NODE BARU (DARI SCRIPT BARU) ---
@onready var view_y := $view_y
@onready var view_x := $view_y/view_x
@onready var body := $body # Asumsi ini adalah node 3D/Mesh player

#--- BATTLE STATS (DARI SCRIPT LAMA) ---
var max_hp: int = 100
var current_hp: int = 100
var is_in_battle: bool = false

#--- MOVEMENT VARS (GABUNGAN) ---
const run_speed = 5.0 # Diambil dari SPEED script baru
const sprint_speed = 8.0 # Bisa lo ganti, ini nilai dari script lama (5.0)
const jump_speed = 4.5 # Diambil dari JUMP_VELOCITY script baru
@onready var camera_sensitivity := 0.01 # Diambil dari sensitivity script baru

#--- NODE REFERENCES (DARI SCRIPT LAMA) ---
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var projectile_spawn_point = $ProjectileSpawnPoint
@onready var actionable_finder: Area3D = $Direction/ActionableFinder

#--- MOBILE UI REFERENCES (DARI SCRIPT LAMA) ---
var mobile_ui: Control
var jump_button: TextureButton
var sprint_button: TextureButton
var interact_button: TextureButton

#--- VARS LAIN (DARI SCRIPT LAMA) ---
var fireball_scene = preload("res://Scenes/Projectiles/Fireball.tscn")
var is_jumping = false

#--- REFACTOR VARS INPUT (DARI SCRIPT LAMA) ---
var _input_dir = Vector2.ZERO
var _is_sprint_pressed = false
var _is_jump_pressed = false
var _is_interact_pressed = false
var _jump_button_was_pressed = false
var _interact_button_was_pressed = false
#------------------------------------------------------------------

func _ready():
	# --- KONEKSI KE SINGLETONS ---
	if BattleManager.has_signal("battle_started"):
		BattleManager.battle_started.connect(_on_battle_started)
	BattleManager.battle_ended.connect(_on_battle_ended)
	
	if SaveManager:
		current_hp = SaveManager.get_player_hp()

	#--- SETUP UI ---
	mobile_ui = get_tree().get_root().find_child("MobileUI", true, false)
	if mobile_ui:
		jump_button = mobile_ui.find_child("JumpButton")
		sprint_button = mobile_ui.find_child("SprintButton")
		interact_button = mobile_ui.find_child("InteractButton")
	
	# Logic mouse capture desktop dihapus


func _input(event: InputEvent) -> void:
	if is_in_battle: return
	
	# Logic kamera hanya untuk ScreenDrag (karena mouse emulasi touch)
	if event is InputEventScreenDrag:
		view_x.rotation.x -= event.relative.y * camera_sensitivity
		view_y.rotation.y -= event.relative.x * camera_sensitivity
		view_x.rotation.x = clampf(view_x.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	
	# Logic InputEventMouseMotion dihapus


func _process(_delta):
	# Dari script LAMA
	if is_in_battle: return
	handle_movement_animation()


func _physics_process(delta: float) -> void:
	_get_inputs() # Dari script LAMA
	
	# Add the gravity (dari script BARU)
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		is_jumping = false # Dari script LAMA

	# Handle movement (dari script LAMA)
	if not is_in_battle:
		handle_movement_input(delta)
	else:
		velocity.x = move_toward(velocity.x, 0, run_speed)
		velocity.z = move_toward(velocity.z, 0, run_speed)

	move_and_slide() # Dari script BARU


# Fungsi dari script LAMA
func _get_inputs():
	# --- PERBAIKAN 1 ---
	# Balikin ke standar script "player baru" asli lo: ("ui_up", "ui_down")
	# "ui_up" (W) akan ngasih nilai -1
	_input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	_is_sprint_pressed = Input.is_action_pressed("ui_sprint") or (sprint_button and sprint_button.is_pressed())
	_is_jump_pressed = Input.is_action_just_pressed("ui_jump") or (jump_button and jump_button.is_pressed() and not _jump_button_was_pressed)
	_is_interact_pressed = Input.is_action_just_pressed("ui_accept") or (interact_button and interact_button.is_pressed() and not _interact_button_was_pressed)
	
	if jump_button: _jump_button_was_pressed = jump_button.is_pressed()
	if interact_button: _interact_button_was_pressed = interact_button.is_pressed()


# Fungsi dari script LAMA (DIMODIFIKASI)
func handle_movement_input(_delta):
	# Jump logic
	if _is_jump_pressed and is_on_floor():
		velocity.y = jump_speed
		is_jumping = true
	
	# Interact logic
	if _is_interact_pressed:
		var actionables = actionable_finder.get_overlapping_areas()
		if not actionables.is_empty():
			actionables[0].action()

	# Movement logic
	if _input_dir.length() > 0:
		# --- PERBAIKAN 2 ---
		# Kita pake logic dari script "player baru" asli lo.
		# Ini udah bener nerjemahin input kamera dan WASD.
		var direction: Vector3 = (view_y.global_basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()
		
		# --- MODIFIKASI KUNCI ---
		# Putar $body, BUKAN si CharacterBody-nya
		var target_rotation = atan2(direction.x, direction.z)
		body.rotation.y = lerp_angle(body.rotation.y, target_rotation, 0.1)

		var current_speed = sprint_speed if _is_sprint_pressed else run_speed
		
		# Ganti `movement_dir` jadi `direction`
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, run_speed)
		velocity.z = move_toward(velocity.z, 0, run_speed)


# Fungsi dari script LAMA
func handle_movement_animation():
	if is_jumping:
		if animation_state.get_current_node() != "jump": animation_state.travel("jump")
	elif _input_dir.length() > 0:
		if _is_sprint_pressed:
			if animation_state.get_current_node() != "sprint": animation_state.travel("sprint")
		else:
			if animation_state.get_current_node() != "walk": animation_state.travel("walk")
	else:
		if animation_state.get_current_node() != "idle": animation_state.travel("idle")

#--- FUNGSI BATTLE (DARI SCRIPT LAMA) ---

func _on_battle_started():
	is_in_battle = true
	print("Player entering battle state.")
	# Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Dihapus

func _on_battle_ended(player_won: bool):
	is_in_battle = false
	
	# Logic mouse capture desktop dihapus
		
	if not player_won:
		current_hp = max_hp
		SaveManager.set_player_hp(current_hp)
		print("Player lost. HP has been restored.")
	else:
		print("Player won the battle!")
		SaveManager.set_player_hp(current_hp)

func take_damage(amount: int):
	current_hp -= amount
	SaveManager.set_player_hp(current_hp)
	print("Player kena damage! HP sisa: ", current_hp)

func attack(target_enemy: Node3D) -> Area3D:
	print("Player mulai menyerang!")
	animation_state.travel("attack-melee-right")
	
	var fireball_instance = fireball_scene.instantiate()
	get_parent().add_child(fireball_instance)
	
	fireball_instance.global_transform = projectile_spawn_point.global_transform
	fireball_instance.target = target_enemy
	
	return fireball_instance
