extends Node2D
@export var pengarturan: NinePatchRect  # NinePatchRect3
@export var konfirmasi_muat_ulang: NinePatchRect  # NinePatchRect4

func toggle_visibility(object):
	object.visible = !object.visible

func _on_mulai_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Sekolah.tscn")

func _on_keluar_pressed() -> void:
	get_tree().quit()

func _on_pengaturan_pressed():
	toggle_visibility(pengarturan)

func _on_muat_ulang_pressed() -> void:
	toggle_visibility(konfirmasi_muat_ulang)
