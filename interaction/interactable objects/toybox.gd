extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var player = get_tree().get_first_node_in_group("player")
@onready var thought_bubble = player.get_node("SpeechBubble")
@export var dialogs_per_day: Array[DialogData] = []
@export var dialog: DialogData

func _ready() -> void:
	dialog = _get_current_dialog()
	print("current day: ", QuestManager.get_current_day())
	print("dialog assigned: ", dialog)
	print("dialog npc_id: ", dialog.npc_id if dialog else "null")
	print("interactable_object_name: ", interaction_area.interactable_object_name)
	interaction_area.interact = Callable(self, "_on_interact")
	DialogManager.line_changed.connect(_on_line_changed)
	DialogManager.dialog_ended.connect(_on_dialog_ended)
	_evaluate_availability()

func _get_current_dialog() -> DialogData:
	if not dialogs_per_day.is_empty():
		var day = QuestManager.get_current_day()
		var index = day-1
		return dialogs_per_day[index]
	return dialog

func _evaluate_availability() -> void:
	var available = true
	if (QuestManager.get_current_day() == 2) and PlayerManager.is_item_used("toybox"):
		PlayerManager.reset_used_item("toybox")
		interaction_area.monitoring = available
		interaction_area.monitorable = available
		return
		 
	if (QuestManager.get_current_day() == 3) or PlayerManager.is_item_used("toybox"):
		available = false
	interaction_area.monitoring = available
	interaction_area.monitorable = available
	return

func _on_interact():
	print("interacting, dialog: ", dialog)
	print("dialog npc_id: ", dialog.npc_id)
	DialogManager.start(dialog)
	await DialogManager.dialog_ended
	PlayerManager.add_used_item("toybox")
	_evaluate_availability()

func _on_line_changed(line: DialogLine) -> void:
	print("line changed, current npc_id: ", DialogManager._current.npc_id if DialogManager._current else "null")
	if not DialogManager.is_active:
		return
	if DialogManager._current.npc_id != interaction_area.interactable_object_name:
		print("gamasuk")
		return
	thought_bubble.show_line(line)
	
func _on_dialog_ended(_npc_id: String) -> void:
	thought_bubble.clear()
