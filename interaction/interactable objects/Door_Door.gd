extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	QuestManager.notify_interaction("Door_Door")
