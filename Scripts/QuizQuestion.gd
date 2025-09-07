extends Resource
class_name QuizQuestion

@export var question_text: String = ""
@export var answers: Array[String] = ["", "", "", ""]
@export var correct_answer_index: int = 0
