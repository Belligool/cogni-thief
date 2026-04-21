extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var player = get_tree().get_first_node_in_group("player")
@onready var thought_bubble = player.get_node("SpeechBubble")
@export var dialog: DialogData
@export var puzzle_dialog: DialogData
@export var puzzle_id: String = ""


func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	DialogManager.line_changed.connect(_on_line_changed)
	DialogManager.dialog_ended.connect(_on_dialog_ended)

func _on_interact():
	DialogManager.start(dialog)
	await DialogManager.dialog_ended

func _on_line_changed(line: DialogLine) -> void:
	if not DialogManager.is_active:
		return
	if DialogManager._current.npc_id != interaction_area.interactable_object_name:
		return
	thought_bubble.show_line(line)
	
func _on_dialog_ended(_npc_id: String) -> void:
	thought_bubble.clear()
