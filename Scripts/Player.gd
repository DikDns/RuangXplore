extends CharacterBody3D
class_name Player

#--- BATTLE STATS ---
var max_hp: int = 100
var current_hp: int = 100
var is_in_battle: bool = false

#--- MOVEMENT VARS ---
const run_speed = 3.0
const sprint_speed = 5.0
const jump_speed = 4.5
const gravity = 10
const touch_camera_sensitivity = 0.005

#--- NODE REFERENCES ---
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var camera = $ThirdPersonCamera/Camera
@onready var tpc_node = $ThirdPersonCamera
@onready var projectile_spawn_point = $ProjectileSpawnPoint
@onready var actionable_finder: Area3D = $Direction/ActionableFinder

#--- MOBILE UI REFERENCES ---
var mobile_ui: Control
var jump_button: TextureButton
var sprint_button: TextureButton
var interact_button: TextureButton

var fireball_scene = preload("res://Scenes/Projectiles/Fireball.tscn")
var is_jumping = false
var camera_touch_index = -1

#--- REFACTOR: Variabel buat nyimpen status input yang konsisten ---
var _input_dir = Vector2.ZERO
var _is_sprint_pressed = false
var _is_jump_pressed = false
var _is_interact_pressed = false
var _jump_button_was_pressed = false
var _interact_button_was_pressed = false
#------------------------------------------------------------------

func _ready():
	mobile_ui = get_tree().get_root().find_child("MobileUI", true, false)
	if mobile_ui:
		jump_button = mobile_ui.find_child("JumpButton")
		sprint_button = mobile_ui.find_child("SprintButton")
		interact_button = mobile_ui.find_child("InteractButton")
		#if not OS.has_feature("mobile"):
			#mobile_ui.hide()

	if not OS.has_feature("mobile"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		tpc_node.set_process_unhandled_input(false)

func _unhandled_input(event):
	if is_in_battle: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			tpc_node.set_process_unhandled_input(true)
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			tpc_node.set_process_unhandled_input(false)
			
	if OS.has_feature("mobile"):
		if event is InputEventScreenTouch:
			if event.position.x > get_viewport().get_visible_rect().size.x / 2:
				if event.is_pressed() and camera_touch_index == -1:
					camera_touch_index = event.index
					tpc_node.set_process_unhandled_input(true)
				elif not event.is_pressed() and event.index == camera_touch_index:
					camera_touch_index = -1
					tpc_node.set_process_unhandled_input(false)

		if event is InputEventScreenDrag and event.index == camera_touch_index:
			var mouse_motion_event = InputEventMouseMotion.new()
			mouse_motion_event.relative = event.relative
			tpc_node._input(mouse_motion_event)

func _process(_delta):
	if is_in_battle: return
	handle_movement_animation()

func _physics_process(delta):
	_get_inputs()

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		is_jumping = false

	if not is_in_battle:
		handle_movement_input(delta)
	else:
		velocity.x = move_toward(velocity.x, 0, run_speed)
		velocity.z = move_toward(velocity.z, 0, run_speed)

	move_and_slide()

# Fungsi baru buat ngumpulin semua input di satu tempat
func _get_inputs():
	# Baca input joystick/keyboard
	_input_dir = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	
	# Cek tombol aksi
	_is_sprint_pressed = Input.is_action_pressed("ui_sprint") or (sprint_button and sprint_button.is_pressed())
	_is_jump_pressed = Input.is_action_just_pressed("ui_jump") or (jump_button and jump_button.is_pressed() and not _jump_button_was_pressed)
	_is_interact_pressed = Input.is_action_just_pressed("ui_accept") or (interact_button and interact_button.is_pressed() and not _interact_button_was_pressed)
	
	# Simpan status tombol UI untuk frame berikutnya
	if jump_button: _jump_button_was_pressed = jump_button.is_pressed()
	if interact_button: _interact_button_was_pressed = interact_button.is_pressed()

func handle_movement_input(_delta):
	# Sekarang, semua fungsi di bawah ini pake variabel _input_dir, _is_sprint_pressed, dll.
	
	if _is_jump_pressed and is_on_floor():
		velocity.y = jump_speed
		is_jumping = true
	
	if _is_interact_pressed:
		var actionables = actionable_finder.get_overlapping_areas()
		if not actionables.is_empty():
			actionables[0].action()

	if _input_dir.length() > 0:
		var forward = -camera.global_transform.basis.z.normalized()
		var right = camera.global_transform.basis.x.normalized()
		forward.y = 0; right.y = 0
		var movement_dir = (forward * _input_dir.y + right * _input_dir.x).normalized()

		var target_rotation = atan2(movement_dir.x, movement_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.1)

		var current_speed = sprint_speed if _is_sprint_pressed else run_speed
		velocity.x = movement_dir.x * current_speed
		velocity.z = movement_dir.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, run_speed)
		velocity.z = move_toward(velocity.z, 0, run_speed)

func handle_movement_animation():
	# Animasi juga pake variabel yang udah konsisten
	if is_jumping:
		if animation_state.get_current_node() != "jump": animation_state.travel("jump")
	elif _input_dir.length() > 0:
		if _is_sprint_pressed:
			if animation_state.get_current_node() != "sprint": animation_state.travel("sprint")
		else:
			if animation_state.get_current_node() != "walk": animation_state.travel("walk")
	else:
		if animation_state.get_current_node() != "idle": animation_state.travel("idle")

#--- FUNGSI BATTLE ---
func take_damage(amount: int):
	current_hp -= amount
	print("Player kena damage! HP sisa: ", current_hp)

func attack(target_enemy: Node3D) -> Area3D:
	print("Player mulai menyerang!")
	animation_state.travel("attack-melee-right")
	
	var fireball_instance = fireball_scene.instantiate()
	get_parent().add_child(fireball_instance)
	
	fireball_instance.global_transform = projectile_spawn_point.global_transform
	fireball_instance.target = target_enemy
	
	return fireball_instance
