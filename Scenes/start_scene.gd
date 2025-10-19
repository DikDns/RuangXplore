extends Control
@export var pengarturan: NinePatchRect  # NinePatchRect3

func toggle_visibility(object):
	object.visible = !object.visible

func _on_mulai_pressed() -> void:
	SaveManager.reset_save_data()
	get_tree().change_scene_to_file("res://Scenes/Sekolah.tscn")

func _on_keluar_pressed() -> void:
	get_tree().quit()

func _on_pengaturan_pressed():
	toggle_visibility(pengarturan)

func _on_muat_ulang_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Sekolah.tscn")


func _on_button_pressed() -> void:
	print("bisa anying")
