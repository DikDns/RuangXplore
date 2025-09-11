extends Node3D

var player: Player
var enemy: Enemy
var current_question: QuizQuestion

@onready var player_spawn_point = $PlayerSpawnPoint
@onready var enemy_spawn_point = $EnemySpawnPoint
@onready var battle_ui = $BattleUI
@onready var battle_camera = $BattleCamera

func _ready():
	var enemy_scene_path = BattleManager.current_enemy_scene_path
	
	if enemy_scene_path.is_empty():
		get_tree().change_scene_to_file("res://Scenes/Main.tscn")
		return

	# Munculkan Player dan Enemy
	player = load("res://Scenes/Player.tscn").instantiate()
	enemy = load(enemy_scene_path).instantiate()
	
	add_child(player)
	add_child(enemy)
	
	# --- FIX ROTASI & PLAYER TERBANG DI SINI ---
	# 1. Gunakan global_transform untuk menyalin posisi DAN rotasi dari Marker.
	player.global_transform = player_spawn_point.global_transform
	enemy.global_transform = enemy_spawn_point.global_transform
	
	# 2. Reset kecepatan player jadi nol biar gak terbang.
	player.velocity = Vector3.ZERO
	# ---------------------------------------------
	
	# --- FIX SKALA DI SINI ---
	# Atur skala player dan enemy agar sesuai dengan battle scene.
	# Lo bisa ganti angka 0.5 ini sesuai selera.
	player.scale = Vector3(0.5, 0.5, 0.5)
	enemy.scale = Vector3(0.5, 0.5, 0.5)
	# -------------------------
	
	# --- FIX KAMERA DI SINI ---
	# 1. Matikan kamera bawaan player
	var player_camera = player.get_node("ThirdPersonCamera/Camera")
	player_camera.current = false
	
	# 2. Pastikan BattleCamera yang jadi kamera utama
	battle_camera.make_current()
	# -------------------------
	
	# Matikan kontrol player di battle scene
	player.is_in_battle = true
	
	# Setup HP
	player.current_hp = BattleManager.player_current_hp
	enemy.current_hp = enemy.max_hp
	
	# Hubungkan tombol jawaban dari UI ke skrip ini
	for i in 4:
		battle_ui.get_node("QuizPanel/VBoxContainer").get_child(i).pressed.connect(
			func(): _on_answer_button_pressed(i)
		)
	
	start_battle()

func start_battle():
	# Update UI HP
	battle_ui.update_hp(player.current_hp, player.max_hp, enemy.current_hp, enemy.max_hp)
	
	# Mulai dengan dialog
	battle_ui.show_dialogue(enemy.intro_dialogue)
	await get_tree().create_timer(3.0).timeout # Tunggu 3 detik
	
	# Sembunyikan dialog dan tampilkan pertanyaan pertama
	battle_ui.hide_dialogue()
	ask_next_question()

func ask_next_question():
	if enemy.questions.is_empty():
		# Jika soal habis, anggap player menang
		end_battle(true)
		return
		
	# Ambil soal acak dan hapus dari list agar tidak muncul lagi
	var available_questions = enemy.questions.duplicate() # Duplikasi array agar tidak merusak aslinya
	if available_questions.is_empty(): # Pengaman jika semua soal sudah dipakai
		end_battle(true)
		return
	
	current_question = available_questions.pick_random()
	enemy.questions.erase(current_question) # Hapus dari array original
	
	battle_ui.display_question(current_question)

func _on_answer_button_pressed(index: int):
	battle_ui.disable_buttons()
	
	if index == current_question.correct_answer_index:
		# Jawaban Benar
		enemy.current_hp -= 25 # Kurangi HP musuh
		player.attack() # Panggil fungsi attack dari player
	else:
		# Jawaban Salah
		player.take_damage(10) # Panggil fungsi take_damage dari player
		
	# Update UI HP
	battle_ui.update_hp(player.current_hp, player.max_hp, enemy.current_hp, enemy.max_hp)
	
	await get_tree().create_timer(1.5).timeout # Jeda sebelum pertanyaan berikutnya
	
	# Cek kondisi menang/kalah
	if enemy.current_hp <= 0:
		end_battle(true) # Player menang
	elif player.current_hp <= 0:
		end_battle(false) # Player kalah
	else:
		ask_next_question()

func end_battle(player_won: bool):
	# Cukup panggil fungsi end_battle di BattleManager.
	# BattleManager sudah tahu siapa musuh yang dikalahkan.
	if player_won:
		BattleManager.player_current_hp = player.current_hp
	
	BattleManager.end_battle(player_won)
