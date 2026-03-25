class_name QuestData
extends Resource

enum CompletionType { DIALOG, INTERACTION, PUZZLE }

@export var id: String = ""
@export var title: String = ""
@export var objective: String = ""
@export var completion_type: CompletionType = CompletionType.DIALOG
@export var completion_target: String = ""
# completion_target matches:
# - npc_id               (DIALOG)
# - interactable_object_name  (INTERACTION)
# - puzzle_id            (PUZZLE)
