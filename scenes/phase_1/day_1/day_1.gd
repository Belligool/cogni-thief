extends Node2D

@export var quests: Array[QuestData] = []

func _ready() -> void:
	QuestManager.loaded_quests(quests)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
