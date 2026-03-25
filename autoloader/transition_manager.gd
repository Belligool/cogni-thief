extends Node

signal transition_started
signal transition_finished

var is_active: bool = false
var _data: NarrationData = null

func start(data: NarrationData) -> void:
	if is_active:
		return
	_data = data
	is_active = true
	transition_started.emit()
	
func finish() -> void:
	is_active = false
	var next = _data.next_scene
	_data = null
	transition_finished.emit()
	get_tree().change_scene_to_file(next)
	
func get_data() -> NarrationData:
	return _data
