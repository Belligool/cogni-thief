extends CanvasLayer

@onready var background: ColorRect = $Background
@onready var interlude_label: Label = $Label

var _tween: Tween = null

func _ready() -> void:
	InterludeManager.interlude_started.connect(_on_started)
	InterludeManager.interlude_finished.connect(_on_finished)
	InterludeManager.interlude_line_change.connect(_on_line_change)
	background.modulate.a = 0.0
	hide()
	
func _on_started() -> void:
	show()
	interlude_label.modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(background, "modulate:a", 1.0, 1.0)
	await  _tween.finished
	interlude_label.text = InterludeManager.get_current_line()
	
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(background, "modulate:a", 1.0, 0.5)
	await _tween.finished
	_tween = create_tween()
	_tween.tween_property(interlude_label, "modulate:a", 1.0, 0.5)
	await _tween.finished
	
func _on_line_change(text: String) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(interlude_label, "modulate:a", 0.0, 0.3)
	await _tween.finished
	_tween = create_tween()
	interlude_label.text = text
	_tween.tween_property(interlude_label, "modulate:a", 1.0, 0.5)
	await _tween.finished
	
func _on_finished() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(interlude_label, "modulate:a", 0.0, 0.3)
	await _tween.finished
	_tween = create_tween()
	_tween.tween_property(background, "modulate:a", 0.0, 0.5)
	await  _tween.finished
	hide()
	
func _unhandled_input(event: InputEvent) -> void:
	if not InterludeManager.is_active:
		return
	if event.is_action_pressed("ui_accept"):
		InterludeManager._advance()
