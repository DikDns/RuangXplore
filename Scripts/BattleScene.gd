extends Node3D

var player: Player
var enemy: Enemy
var current_question: QuizQuestion
var _mobile_ui

var all_questions: Array
var available_questions: Array

@onready var player_spawn_point = $PlayerSpawnPoint
@onready var enemy_spawn_point = $EnemySpawnPoint
@onready var battle_ui = $BattleUI
@onready var battle_camera = $BattleCamera

func _ready():
	var enemy_scene_path = BattleManager.active_enemy_scene_path
	
	if enemy_scene_path.is_empty():
		print("ERROR: Battle scene entered without starting a battle. Returning to main menu.")
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		return

	player = load("res://Scenes/Player.tscn").instantiate()
	enemy = load(enemy_scene_path).instantiate()
	
	_mobile_ui = player.find_child("MobileUI", true, false)
	if _mobile_ui:
		_mobile_ui.hide()
	
	add_child(player)
	add_child(enemy)
	
	player.global_transform = player_spawn_point.global_transform
	enemy.global_transform = enemy_spawn_point.global_transform
	
	player.velocity = Vector3.ZERO
	
	player.scale = Vector3(0.5, 0.5, 0.5)
	enemy.scale = Vector3(0.25, 0.25, 0.25)
	
	var player_camera = player.find_child("Camera")
	player_camera.current = false
	battle_camera.make_current()
	
	player.is_in_battle = true
	
	player.current_hp = SaveManager.get_player_hp()
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
	
	if enemy.dialogue_resource:
		DialogueManager.dialogue_ended.connect(_on_intro_dialogue_finished, CONNECT_ONE_SHOT)
		DialogueManager.show_dialogue_balloon(enemy.dialogue_resource, enemy.dialogue_title)
	else:
		print("No dialogue resource found for this enemy. Starting quiz directly.")
		ask_next_question()

# --- FUNGSI BARU: Dipanggil setelah dialog intro selesai ---
func _on_intro_dialogue_finished(_resource: DialogueResource):
	# Mulai kuis setelah dialog selesai
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
		projectile.hit_target.connect(_on_projectile_hit_player)

func _on_projectile_hit_enemy():
	enemy.current_hp -= 25
	print("Correct! Enemy HP: ", enemy.current_hp)
	_check_battle_status()

func _on_projectile_hit_player():
	player.take_damage(10)
	print("Wrong! Player HP: ", player.current_hp)
	_check_battle_status()

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
	BattleManager.end_battle(player_won)
