class_name DialogLine
extends Resource

@export var speaker: String = ""
@export var text: String = ""
@export var choices: Array[DialogChoice] = []
@export var is_dialog_thought: bool = false
@export var typing_speed: float
@export var translation: String = ""
# Empty choices = no decision, player just presses confirm to advance
