extends Control

@onready var player_hp_bar = $PlayerHPBar
@onready var enemy_hp_bar = $EnemyHPBar
@onready var dialogue_panel = $DialoguePanel
@onready var dialogue_label = $DialoguePanel/DialogueLabel
@onready var quiz_panel = $QuizPanel
@onready var question_label = $QuizPanel/QuestionLabel
@onready var answer_buttons_container = $QuizPanel/VBoxContainer

# Fungsi untuk update tampilan HP bar
func update_hp(player_hp, player_max_hp, enemy_hp, enemy_max_hp):
	player_hp_bar.max_value = player_max_hp
	player_hp_bar.value = player_hp
	enemy_hp_bar.max_value = enemy_max_hp
	enemy_hp_bar.value = enemy_hp

# Fungsi untuk menampilkan dialog awal
func show_dialogue(text: String):
	dialogue_label.text = text
	dialogue_panel.show()

# Fungsi untuk menyembunyikan dialog
func hide_dialogue():
	dialogue_panel.hide()

# Fungsi untuk menampilkan pertanyaan dan jawaban
func display_question(question: QuizQuestion):
	question_label.text = question.question_text
	for i in 4:
		var button = answer_buttons_container.get_child(i)
		button.text = question.answers[i]

func disable_buttons():
	for button in answer_buttons_container.get_children():
		button.disabled = true

func hide_quiz_panel():
	quiz_panel.hide()

func show_quiz_panel():
	quiz_panel.show()
	for button in answer_buttons_container.get_children():
		button.disabled = false
