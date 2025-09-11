extends CharacterBody3D
class_name Player

#--- BATTLE STATS ---
var max_hp: int = 100
var current_hp: int = 100
var is_in_battle: bool = false

#--- MOVEMENT VARS ---
const run_speed = 3.0
const sprint_speed = 5.0
const jump_speed = 4.5 # Sedikit disesuaikan agar lebih pas dengan gravitasi
const gravity = 10

#--- NODE REFERENCES ---
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var camera = $ThirdPersonCamera/Camera
@onready var tpc_node = $ThirdPersonCamera

var is_jumping = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	tpc_node.set_process_unhandled_input(false)

func _unhandled_input(event):
	if is_in_battle:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			tpc_node.set_process_unhandled_input(true)
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			tpc_node.set_process_unhandled_input(false)

func _process(delta):
	if is_in_battle:
		if animation_state.get_current_node() != "idle":
			animation_state.travel("idle")
		return
	
	# Hanya proses animasi jika tidak sedang battle
	handle_animation()

func _physics_process(delta):
	# 1. Terapkan gravitasi di luar kondisi, jadi selalu aktif
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		is_jumping = false

	# 2. Proses input gerakan HANYA jika tidak sedang battle
	if not is_in_battle:
		handle_movement_input(delta)
	else:
		# Jika sedang battle, buat player berhenti bergerak
		velocity.x = move_toward(velocity.x, 0, run_speed)
		velocity.z = move_toward(velocity.z, 0, run_speed)

	# 3. Terapkan semua perubahan fisika
	move_and_slide()

# Fungsi untuk menangani input pergerakan
func handle_movement_input(delta):
	# Handle Jump
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = jump_speed
		is_jumping = true

	# --- FIX JALAN KEBALIK DI SINI ---
	# Urutan "ui_down" dan "ui_up" ditukar agar W jadi maju (positif) dan S jadi mundur (negatif)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	
	if input_dir.length() > 0:
		# Calculate movement direction based on camera orientation
		var forward = -camera.global_transform.basis.z
		var right = camera.global_transform.basis.x
		forward.y = 0
		right.y = 0
		forward = forward.normalized()
		right = right.normalized()
		var movement_dir = (forward * input_dir.y + right * input_dir.x).normalized()

		# Player SELALU berputar saat bergerak, tidak peduli kondisi mouse
		var target_rotation = atan2(movement_dir.x, movement_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.1)

		# Apply movement
		if Input.is_action_pressed("ui_sprint"):
			velocity.x = movement_dir.x * sprint_speed
			velocity.z = movement_dir.z * sprint_speed
		else:
			velocity.x = movement_dir.x * run_speed
			velocity.z = movement_dir.z * run_speed
	else:
		# Slow down if no input
		velocity.x = move_toward(velocity.x, 0, run_speed)
		velocity.z = move_toward(velocity.z, 0, run_speed)

func handle_animation():
	var input_dir = Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")
	if is_jumping:
		if animation_state.get_current_node() != "jump":
			animation_state.travel("jump")
	elif input_dir.length() > 0:
		if Input.is_action_pressed("ui_sprint"):
			if animation_state.get_current_node() != "sprint":
				animation_state.travel("sprint")
		else:
			if animation_state.get_current_node() != "walk":
				animation_state.travel("walk")
	else:
		if animation_state.get_current_node() != "idle":
			animation_state.travel("idle")

#--- FUNGSI UNTUK BATTLE ---
func take_damage(amount: int):
	current_hp -= amount
	print("Player kena damage! HP sisa: ", current_hp)
	# Nanti di sini panggil animasi `get_hit`
	# Contoh: animation_state.travel("get_hit")

func attack():
	print("Player menyerang!")
	# Nanti di sini panggil animasi `attack`
	# Contoh: animation_state.travel("attack")
