extends Node3D

var player: Player
var enemy: Enemy
var current_question: QuizQuestion

var all_questions: Array
var available_questions: Array

@onready var player_spawn_point = $PlayerSpawnPoint
@onready var enemy_spawn_point = $EnemySpawnPoint
@onready var battle_ui = $BattleUI
@onready var battle_camera = $BattleCamera

func _ready():
	var enemy_scene_path = BattleManager.current_enemy_scene_path
	
	if enemy_scene_path.is_empty():
		get_tree().change_scene_to_file("res://Scenes/Main.tscn")
		return

	player = load("res://Scenes/Player.tscn").instantiate()
	enemy = load(enemy_scene_path).instantiate()
	
	var mobile_ui = player.find_child("MobileUI", true, false)
	if mobile_ui:
		mobile_ui.visible = false # UI disembunyikan total
	
	add_child(player)
	add_child(enemy)
	
	player.global_transform = player_spawn_point.global_transform
	enemy.global_transform = enemy_spawn_point.global_transform
	
	player.velocity = Vector3.ZERO
	
	player.scale = Vector3(0.5, 0.5, 0.5)
	enemy.scale = Vector3(0.25, 0.25, 0.25)
	
	var player_camera = player.get_node("ThirdPersonCamera/Camera")
	player_camera.current = false
	battle_camera.make_current()
	
	player.is_in_battle = true
	
	player.current_hp = BattleManager.player_current_hp
	enemy.current_hp = enemy.max_hp
	
	all_questions = enemy.questions.duplicate()
	available_questions = all_questions.duplicate()
	
	for i in 4:
		battle_ui.get_node("QuizPanel/VBoxContainer").get_child(i).pressed.connect(
			func(): _on_answer_button_pressed(i)
		)
	
	start_battle()

func start_battle():
	battle_ui.update_hp(player.current_hp, player.max_hp, enemy.current_hp, enemy.max_hp)
	
	battle_ui.show_dialogue(enemy.intro_dialogue)
	await get_tree().create_timer(3.0).timeout
	
	battle_ui.hide_dialogue()
	ask_next_question()

func ask_next_question():
	battle_ui.show_quiz_panel()
	
	if available_questions.is_empty():
		print("Soal habis, mengocok ulang deck!")
		available_questions = all_questions.duplicate()

	current_question = available_questions.pick_random()
	available_questions.erase(current_question)
	
	battle_ui.display_question(current_question)

func _on_answer_button_pressed(index: int):
	battle_ui.disable_buttons()
	battle_ui.hide_quiz_panel()
	
	var projectile: Area3D

	if index == current_question.correct_answer_index:
		projectile = player.attack(enemy)
		projectile.hit_target.connect(_on_projectile_hit_enemy)
	else:
		projectile = enemy.attack(player)
		# Hubungkan sinyal dari proyektil monster ke fungsi damage
		projectile.hit_target.connect(_on_projectile_hit_player)

# --- FUNGSI BARU: Dipanggil saat fireball player kena musuh ---
func _on_projectile_hit_enemy():
	enemy.current_hp -= 25
	print("Correct! Enemy HP: ", enemy.current_hp)
	_check_battle_status()

# --- FUNGSI BARU: Dipanggil saat proyektil monster kena player ---
func _on_projectile_hit_player():
	player.take_damage(10)
	print("Wrong! Player HP: ", player.current_hp)
	_check_battle_status()

# --- FUNGSI BARU: Untuk mengecek status setelah damage ---
func _check_battle_status():
	battle_ui.update_hp(player.current_hp, player.max_hp, enemy.current_hp, enemy.max_hp)
	
	await get_tree().create_timer(0.7).timeout
	
	if enemy.current_hp <= 0:
		end_battle(true)
	elif player.current_hp <= 0:
		end_battle(false)
	else:
		ask_next_question()

func end_battle(player_won: bool):
	if player_won:
		BattleManager.player_current_hp = player.current_hp
	else:
		BattleManager.player_current_hp = player.max_hp

	BattleManager.end_battle(player_won)
