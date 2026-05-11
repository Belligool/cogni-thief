extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var player = get_tree().get_first_node_in_group("player")
@onready var thought_bubble = player.get_node("SpeechBubble")
@export var dialog: DialogData

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	DialogManager.line_changed.connect(_on_line_changed)
	DialogManager.dialog_ended.connect(_on_dialog_ended)
	_evaluate_availability()

func _evaluate_availability() -> void:
	var available = true
	if (QuestManager.get_current_day() == 2 or QuestManager.get_current_day() == 3) or PlayerManager.is_item_used("family_photo"):
		available = false
	interaction_area.monitoring = available
	interaction_area.monitorable = available
	return

func _on_interact():
	DialogManager.start(dialog)
	await DialogManager.dialog_ended
	PlayerManager.add_used_item("family_photo")
	_evaluate_availability()

func _on_line_changed(line: DialogLine) -> void:
	if not DialogManager.is_active:
		return
	if DialogManager._current.npc_id != interaction_area.interactable_object_name:
		return
	thought_bubble.show_line(line)
	
func _on_dialog_ended(_npc_id: String) -> void:
	thought_bubble.clear()
