extends Node

signal interlude_started
signal interlude_finished
signal interlude_line_change(line: String)

var is_active: bool = false
var _lines: Array[String] = []
var _current_index: int = 0

func show_interlude(lines: Array[String]) -> void:
	if is_active:
		return
	is_active = true
	_lines = lines
	_current_index = 0
	interlude_started.emit()
	
func _advance() -> void:
	if not is_active:
		return
	_current_index += 1
	if _current_index >= _lines.size():
		end()
		return
	interlude_line_change.emit(_lines[_current_index])

func end() -> void:
	is_active = false
	interlude_finished.emit()

func get_current_line() -> String:
	return _lines[_current_index]
