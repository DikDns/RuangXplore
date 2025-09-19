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

#--- NODE REFERENCES ---
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var camera = $ThirdPersonCamera/Camera
@onready var tpc_node = $ThirdPersonCamera
@onready var projectile_spawn_point = $ProjectileSpawnPoint

var fireball_scene = preload("res://Scenes/Projectiles/Fireball.tscn")
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

func _process(_delta):
	# Logika animasi dipisah berdasarkan kondisi battle
	if is_in_battle:
		# Saat battle, kita cuma cek kapan animasi attack selesai biar bisa balik ke idle.
		var current_node_name = animation_state.get_current_node()
		if (current_node_name == "attack-melee-right") and not animation_state.is_playing():
			animation_state.travel("idle")
	else:
		# Kalo gak battle, jalanin animasi pergerakan seperti biasa.
		handle_movement_animation()

func _physics_process(delta):
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

func handle_movement_input(_delta):
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = jump_speed
		is_jumping = true

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	
	if input_dir.length() > 0:
		var forward = -camera.global_transform.basis.z
		var right = camera.global_transform.basis.x
		forward.y = 0; right.y = 0
		forward = forward.normalized(); right = right.normalized()
		var movement_dir = (forward * input_dir.y + right * input_dir.x).normalized()

		var target_rotation = atan2(movement_dir.x, movement_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.1)

		if Input.is_action_pressed("ui_sprint"):
			velocity.x = movement_dir.x * sprint_speed
			velocity.z = movement_dir.z * sprint_speed
		else:
			velocity.x = movement_dir.x * run_speed
			velocity.z = movement_dir.z * run_speed
	else:
		velocity.x = move_toward(velocity.x, 0, run_speed)
		velocity.z = move_toward(velocity.z, 0, run_speed)

func handle_movement_animation():
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

#--- FUNGSI BATTLE ---
func take_damage(amount: int):
	current_hp -= amount
	print("Player kena damage! HP sisa: ", current_hp)
	# Nanti bisa tambah animasi get_hit di sini

func attack(target_enemy: Node3D) -> Area3D:
	print("Player mulai menyerang!")
	
	# 1. Mainkan animasi serangan
	animation_state.travel("attack-melee-right")
	
	# 3. Baru munculkan fireball
	var fireball_instance = fireball_scene.instantiate()
	get_parent().add_child(fireball_instance)
	
	# 4. Munculkan di titik spawn, bukan di tengah badan
	fireball_instance.global_transform = projectile_spawn_point.global_transform
	
	fireball_instance.target = target_enemy
	
	# 5. Kembalikan instance fireball agar BattleScene bisa connect sinyal
	return fireball_instance
