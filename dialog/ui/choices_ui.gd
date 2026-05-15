extends CanvasLayer

#TODO POSITION UI MASIH BELOM 

@onready var container: VBoxContainer = $ChoicesContainer
var _buttons: Array[Button] = []

func _ready() -> void:
	DialogManager.line_changed.connect(_on_line_changed)
	DialogManager.dialog_ended.connect(_on_dialog_ended)
	
	
	for child in container.get_children():
		if child is Button:
			_buttons.append(child)
			
	container.hide()
	
func _on_line_changed(line: DialogLine) -> void:
	_clear()
	if line.choices.is_empty():
		return
	_build(line.choices)
	
func _on_dialog_ended(_npc_id: String) -> void:
	_clear()
	
func _clear() -> void:
	container.hide()
	for btn in _buttons:
		btn.hide()
		for c in btn.pressed.get_connections():
			btn.pressed.disconnect(c.callable)
			
func _build(choices: Array) -> void:
	for i in choices.size():
		if i >= _buttons.size():
			break
		var btn: Button = _buttons[i]
		var choice: DialogChoice = choices[i]
		btn.text = choice.label
		btn.show() 
		btn.pressed.connect(func(): _on_choice_pressed(choice))
	container.show()
	
func _on_choice_pressed(choice: DialogChoice) -> void:
	_clear()
	DialogManager.choose(choice)
