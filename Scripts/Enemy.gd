extends CharacterBody3D
class_name Enemy

@export var enemy_id: String = ""
@export var dialogue_resource: DialogueResource
@export var dialogue_title: String = "start" 
@export var max_hp: int = 100
@export var questions: Array[QuizQuestion]


var current_hp: int

var projectile_scene = preload("res://Scenes/Projectiles/MonsterProjectile.tscn")

# --- PHYSICS ---
const gravity = 10 # Gunakan nilai gravitasi yang sama dengan Player

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	move_and_slide()

func attack(target_player: Node3D):
	print("Monster menyerang!")
	
	var projectile_instance = projectile_scene.instantiate()
	get_parent().add_child(projectile_instance)
	
	projectile_instance.global_transform = self.global_transform
	projectile_instance.global_position -= self.global_transform.basis.z * 1.0 
	
	projectile_instance.target = target_player
	
	return projectile_instance
