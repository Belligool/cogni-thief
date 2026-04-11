extends Node

signal transition_started
signal transition_finished
signal narration_finished
signal narration_line_changed(text: String)

var is_active: bool = false
var _data: NarrationData = null
var _narration_line_index: int = 0

#TODO Testing and UI belom

func start(data: NarrationData) -> void:
	if is_active:
		return
	_data = data
	is_active = true
	transition_started.emit()
	
func _end() -> void:
	is_active = false
	narration_finished.emit()

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
	var next = _data.next_scene
	var quests = _data.next_day_quests
	_data = null
	transition_finished.emit()
	# Load new quests for every transition (new day)
	if not quests.is_empty():
		print("loading quests")
		QuestManager.loaded_quests(quests)
	get_tree().change_scene_to_file(next)
