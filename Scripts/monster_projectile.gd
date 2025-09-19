extends Area3D

signal hit_target

const SPEED = 5.0
var target: Node3D

func _physics_process(delta):
	if is_instance_valid(target):
		look_at(target.global_position)
		position -= transform.basis.z * SPEED * delta
	else:
		queue_free()

func _on_body_entered(body: Node3D):
	if body is Player:
		print("Proyektil monster kena player!")
		# KIRIM SINYAL SEBELUM HANCUR
		hit_target.emit()
		queue_free()
