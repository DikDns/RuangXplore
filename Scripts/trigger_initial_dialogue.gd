extends Area3D

@export var dialogue_resource: DialogueResource
@export var dialogue_title: String

@export var npc_node_path: NodePath
@export var spawn_marker_path: NodePath

var has_been_triggered: bool = false

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if has_been_triggered:
		return

	if not body.is_in_group("player"):
		return

	has_been_triggered = true

	print("Dialogue Trigger Activated: ", dialogue_title)

	var npc = get_node_or_null(npc_node_path)
	var spawn_point = get_node_or_null(spawn_marker_path)

	if npc and spawn_point:
		npc.global_transform = spawn_point.global_transform
		npc.show() 

	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_title)
	
	$CollisionShape3D.disabled = true
