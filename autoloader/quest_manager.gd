extends Node

#TODO MASIH BELOM HANDLE PUZZLE

signal quest_started (quest: QuestData)
signal quest_completed (quest: QuestData)
signal quest_list_loaded
signal trigger_cutscene(scene: String)
signal trigger_flag(flag: String)

var _current_day: int = 0
var triggered_flags: Array[String] = []
var _completed_targets: Array[String] = []
var _completed_cutscenes: Array[String] = []
var _completed_intros: Array[String] = []
var _quests: Array[QuestData] = []
var _current_index: int = 0

func loaded_quests(quests: Array[QuestData]) -> void:
	# Called at the start of each phase with that phase's quest list
	_quests = quests
	_current_index = 0
	quest_list_loaded.emit()
	print("Quest Started")
	print("quests size: ", _quests.size())
	print("current index: ", _current_index)
	_start_current()
	
func get_current_quest() -> QuestData:
	if _quests.is_empty() or _current_index >= _quests.size():
		return null
	return _quests[_current_index]
	
func _start_current() -> void:
	var quest = get_current_quest()
	if quest == null:
		return
	_completed_targets.clear()
	print("emitting quest_started: ", quest.title)
	quest_started.emit(quest)
	
func _try_complete(completion_type: QuestData.CompletionType, target: String) -> void:
	var quest = get_current_quest()
	if quest == null:
		return 
	
	#d
	if quest.completion_type == completion_type and quest.completion_target == target:
		print("comparing target: '", quest.completion_target, "' vs '", target, "'")
		quest_completed.emit(quest)
		_current_index += 1
		_trigger_flag(quest)
		_trigger_cutscene(quest)
		_start_current()
		
	# Handle multiple interaction
	if quest.completion_type == QuestData.CompletionType.MULTI_INTERACTION:
		_try_complete_multi(target)
		return
		
func _trigger_flag(quest: QuestData) -> void:
	if quest.flag != null:
		triggered_flags.append(quest.flag)
		trigger_flag.emit(quest.flag)
		
func _trigger_cutscene(quest: QuestData) -> void:
	if quest.cutscene != null:
		_completed_cutscenes.append(quest.cutscene)
		trigger_cutscene.emit(quest.cutscene)
		print(quest.cutscene)

func is_flag_active(flag_name: String) -> bool:
	return triggered_flags.has(flag_name)

func _try_complete_multi(target: String) -> void:
	var quest = get_current_quest()
	# only track targets that are in the required list
	if not quest.required_targets.has(target):
		return
	# only add if not already completed
	if not _completed_targets.has(target):
		_completed_targets.append(target)
		print("completed target: ", target, " (", _completed_targets.size(), "/", quest.required_targets.size(), ")")
	# check if all required targets are done
	if _completed_targets.size() >= quest.required_targets.size():
		_completed_targets.clear()
		quest_completed.emit(quest)
		_current_index += 1
		_trigger_flag(quest)
		_trigger_cutscene(quest)
		_start_current()


func set_day(day: int) -> void:
	_current_day = day

func get_current_day() -> int:
	return _current_day

func notify_dialog_ended(npc_id: String) -> void:
	_try_complete(QuestData.CompletionType.DIALOG, npc_id)
	
func notify_interaction(object_name: String) -> void:
	_try_complete(QuestData.CompletionType.INTERACTION, object_name)
	
func was_intro_seen(scene_id: String) -> bool:
	return _completed_intros.has(scene_id)
	
func was_cutscene_seen(scene_id: String) -> bool:
	return _completed_cutscenes.has(scene_id)
	
func mark_intro_done(scene_id: String) -> void:
	if not _completed_intros.has(scene_id):
		_completed_intros.append(scene_id)
		
func notify_proximity(target_id: String) -> void:
	_try_complete(QuestData.CompletionType.PROXIMITY, target_id)
