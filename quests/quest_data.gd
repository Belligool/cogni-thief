class_name QuestData
extends Resource

enum CompletionType { DIALOG, INTERACTION, MULTI_INTERACTION, PROXIMITY }

@export var id: String = ""
@export var title: String = ""
@export var objective: String = ""
@export var completion_type: CompletionType = CompletionType.DIALOG
@export var completion_target: String = ""
@export var required_targets: Array[String] = []
@export var flag: String = ""
@export var cutscene: String = ""
@export var distance: int = 0
# completion_target matches:
# - npc_id               (DIALOG)
# - interactable_object_name  (INTERACTION)
# - puzzle_id            (PUZZLE)
