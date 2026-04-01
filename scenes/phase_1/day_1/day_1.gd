extends Node2D

@export var quests: Array[QuestData] = []

func _ready() -> void:
	QuestManager.loaded_quests(quests)
