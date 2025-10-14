extends Area3D

@export var dialogue_resources: DialogueResource
@export var dialogue_start: String = "start"


func action():
	DialogueManager.show_dialogue_balloon(dialogue_resources, dialogue_start)
