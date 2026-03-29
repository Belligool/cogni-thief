extends Node

signal quest_started (quest: QuestData)
signal quest_completed (quest: QuestData)
signal quest_list_loaded

var _quests: Array[QuestData] = []
var _current_index: int = 0

func loaded_quests(quests: Array[QuestData]) -> void:
	# Called at the start of each phase with that phase's quest list
	_quests = quests
	_current_index = 0
	quest_list_loaded.emit()
	print("Quest Started")
	_start_current()
	
func get_current_quest() -> QuestData:
	if _quests.is_empty() or _current_index >= _quests.size():
		return null
	return _quests[_current_index]
	
func _start_current() -> void:
	var quest = get_current_quest()
	if quest == null:
		return
	quest_started.emit()
	
func _try_complete(completion_type: QuestData.CompletionType, target: String) -> void:
	var quest = get_current_quest()
	if quest == null:
		return 
	print("comparing type: ", quest.completion_type, " vs ", completion_type)
	print("comparing target: '", quest.completion_target, "' vs '", target, "'")
	if quest.completion_type == completion_type and quest.completion_target == target:
		quest_completed.emit()
		_current_index += 1
		_start_current()
		
func notify_dialog_ended(npc_id: String) -> void:
	_try_complete(QuestData.CompletionType.DIALOG, npc_id)
	
func notify_interaction(object_name: String) -> void:
	_try_complete(QuestData.CompletionType.INTERACTION, object_name)
