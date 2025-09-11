extends Control

@onready var player_hp_bar = $PlayerHPBar
@onready var enemy_hp_bar = $EnemyHPBar
@onready var dialogue_panel = $DialoguePanel
@onready var quiz_panel = $QuizPanel
@onready var question_label = $QuizPanel/QuestionLabel
@onready var answer_buttons_container = $QuizPanel/VBoxContainer

func show_dialogue(text: String):
	dialogue_panel.show()
	quiz_panel.hide()
	$DialoguePanel/DialogueLabel.text = text

func hide_dialogue():
	dialogue_panel.hide()

func display_question(question: QuizQuestion):
	quiz_panel.show()
	question_label.text = question.question_text
	for i in 4:
		var button = answer_buttons_container.get_child(i)
		button.text = question.answers[i]
		button.disabled = false

func update_hp(player_hp, player_max, enemy_hp, enemy_max):
	player_hp_bar.max_value = player_max
	player_hp_bar.value = player_hp
	enemy_hp_bar.max_value = enemy_max
	enemy_hp_bar.value = enemy_hp

func disable_buttons():
	for button in answer_buttons_container.get_children():
		button.disabled = true
