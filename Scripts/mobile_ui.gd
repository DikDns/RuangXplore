extends Control

func _ready():
	# Script ini "mendengarkan" signal dari DialogueManager
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

# Fungsi ini akan otomatis terpanggil ketika dialog dimulai
func _on_dialogue_started(_resource: DialogueResource):
	print("Dialogue started, hiding mobile UI.")
	hide()


# Fungsi ini akan otomatis terpanggil ketika dialog berakhir
func _on_dialogue_ended(_resource: DialogueResource):
	print("Dialogue ended, showing mobile UI.")
	if BattleManager.active_enemy_id.is_empty():
		show()
