extends Node

signal transition_started
signal narration_finished(scene: String)
signal narration_line_changed(text: String)
signal scene_change_started
signal scene_change_finished

var is_active: bool = false
var _data: NarrationData = null
var _narration_line_index: int = 0
var _pending_spawn: String = ""
var _pending_scene: String = ""

#TODO Testing and UI belom

func start(data: NarrationData) -> void:
	if is_active:
		return
	_data = data
	is_active = true
	transition_started.emit()
	
func _end() -> void:
	is_active = false
	narration_finished.emit(_data.next_scene)

func _show_line(index: int) -> void:
	# if index is out of range or -1, the narration is over
	if _data == null:
		return
	if index < 0 or index >= _data.lines.size():
		_end()
		return
	_narration_line_index = index
	print("LINE: ", _data.lines[index])
	# For UI signal
	narration_line_changed.emit(_data.lines[index])
		
func _advance() -> void:
	if not is_active or _data == null:
		return
	_show_line(_narration_line_index + 1)
	
func get_data() -> NarrationData:
	return _data

func show_first_line() -> void:
	_show_line(0)
	
func finish() -> void:
	is_active = false
	var quests = _data.next_day_quests
	_data = null
	# Load new quests for every transition (new day)
	if not quests.is_empty():
		print("loading quests")
		QuestManager.loaded_quests(quests)
	
func change_scene(next_scene: String, spawn_point_id: String = "") -> void:
	if is_active:
		return
	is_active = true
	_pending_spawn = spawn_point_id
	_pending_scene = next_scene
	scene_change_started.emit()
	
func finish_scene_change() -> void:
	var next = _pending_scene # temp store
	var spawn = _pending_spawn
	_pending_scene = ""
	_pending_spawn = ""
	get_tree().change_scene_to_file(next)
	await get_tree().process_frame
	await get_tree().process_frame
	is_active = false
	scene_change_finished.emit(spawn)
