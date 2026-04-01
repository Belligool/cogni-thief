extends Node

signal transition_started
signal transition_finished
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
	var next = _data.next_scene
	var quests = _data.next_day_quests
	_data = null
	transition_finished.emit()
	# Load new quests for every transition (new day)
	if not quests.is_empty():
		QuestManager.loaded_quests(quests)
	get_tree().change_scene_to_file(next)

func _show_line(index: int) -> void:
	# if index is out of range or -1, the narration is over
	if index < 0 or index >= _data.lines.size():
		_end()
		return
	_narration_line_index = index
	print("LINE: ", _data.lines[index])
	# For UI signal
	narration_line_changed.emit(_data.lines[index])
		
func _advance() -> void:
	if not is_active:
		return
	_show_line(_narration_line_index + 1)
	
func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event.is_action_pressed("next_narration"):
		_advance()
	
func get_data() -> NarrationData:
	return _data
