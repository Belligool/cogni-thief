extends Node

signal dialog_started(npc_id: String)
signal line_changed(line: DialogLine)
signal dialog_ended(npc_id: String)

var is_active: bool = false
var _current: DialogData = null
var _line_index: int = 0

func start(dialog: DialogData) -> void:
	if is_active:
		return # Don't disturb current dialog
	_current = dialog
	_line_index = 0
	is_active = true
	dialog_started.emit(dialog.npc_id)
	_show_line(0)
	
func advance() -> void:
	if not is_active:
		return
	if _current.lines[_line_index].choices.is_empty():
		_show_line(_line_index + 1)
		
func choose(choice: DialogChoice) -> void:
	if not is_active:
		return
	match choice.point_type:
		DialogChoice.PointType.GOOD      : PlayerManager.add_good_point()
		DialogChoice.PointType.BAD       : PlayerManager.add_bad_point()
		DialogChoice.PointType.NEUTRAL   : PlayerManager.add_neutral_point()
		DialogChoice.PointType.NO_EFFECT : pass
	# jump to whatever line this choice points to if branching is a feature else just make an increment
	_show_line(choice.next_line_index)
	
func _show_line(index: int) -> void:
	# if index is out of range or -1, the dialog is over
	if index < 0 or index >= _current.lines.size():
		_end()
		return
	_line_index = index
	print("LINE: ", _current.lines[index].text)
	line_changed.emit(_current.lines[index])
	
func _end() -> void:
	var npc_id = _current.npc_id
	var is_quest = _current.is_quest_dialog
	is_active = false
	_current = null
	dialog_ended.emit(npc_id)
	if is_quest:
		QuestManager.notify_dialog_ended(npc_id)
		

# For testing	
func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event.is_action_pressed("next_dialog"):
		advance()
		
