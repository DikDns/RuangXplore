extends CharacterBody3D
class_name Enemy

# --- STATS & DATA ---
@export var enemy_id: String = ""
@export var max_hp: int = 100
@export var intro_dialogue: String = "Bersiaplah untuk kuis!"
@export var questions: Array[QuizQuestion]

var current_hp: int

# --- PHYSICS ---
const gravity = 10 # Gunakan nilai gravitasi yang sama dengan Player

func _physics_process(delta):
	# Terapkan gravitasi jika monster tidak di lantai.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# Hentikan gerakan ke bawah jika sudah di lantai
		velocity.y = 0

	# Panggil move_and_slide() agar fisika (termasuk gravitasi) diterapkan.
	move_and_slide()
