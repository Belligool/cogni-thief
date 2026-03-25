class_name DialogLine
extends Resource

@export var speaker: String = ""
@export var text: String = ""
@export var choices: Array[DialogChoice] = []
# Empty choices = no decision, player just presses confirm to advance
