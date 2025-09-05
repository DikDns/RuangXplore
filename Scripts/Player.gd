extends CharacterBody3D

# Vars
const run_speed = 3.0
const sprint_speed = 5.0
const jump_speed = 3.0
const gravity = 10

@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var camera = $ThirdPersonCamera/Camera

var is_jumping = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	handle_animation()

func _physics_process(delta):
	handle_movement(delta)

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

func handle_movement(delta):
	# Check if the player has landed
	if is_on_floor() and velocity.y == 0:
		is_jumping = false
	# Apply gravity
	velocity.y += -gravity * delta

	# Get input direction
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

		# Rotate player to face movement direction
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
		velocity.x = move_toward(velocity.x, 0, run_speed)
		velocity.z = move_toward(velocity.z, 0, run_speed)

	# Handle jumping
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = jump_speed
		is_jumping = true

	move_and_slide()
