extends CanvasLayer

@onready var background: ColorRect = $Background
@onready var narration_label: Label = $Background/NarrationLabel

var _tween: Tween = null

var _full_text: String = ""
var _chars_shown: int = 0
var _typing: bool = false
var _typing_speed: float = 0.05
var _typing_timer: float = 0.0
var _is_playing: bool = false

func _ready() -> void:
	print("narration ui ready")
	TransitionManager.transition_started.connect(_on_transition_started)
	TransitionManager.narration_line_changed.connect(_on_line_changed)
	TransitionManager.narration_finished.connect(_on_last_line_done)
	background.modulate.a = 0.0
	hide()
 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not _typing:
		return
	_typing_timer += delta
	if _typing_timer >= _typing_speed:
		_typing_timer = 0.0
		_chars_shown += 1
		narration_label.text = _full_text.left(_chars_shown)
		if _chars_shown >= _full_text.length():
			_typing = false
			
func _on_transition_started() -> void:
	if _is_playing:
		return
	print("transition started fired!")
	_is_playing = true
	show()
	narration_label.modulate.a = 0.0
	narration_label.text = ""
	_tween = create_tween()
	_tween.tween_property(background, "modulate:a", 1.0, 1.0)
	await _tween.finished
	TransitionManager.show_first_line()
	
func _on_line_changed(text: String) -> void:
	print("line changed fired: ", text)
	if narration_label.text != "":
		_tween = create_tween()
		_tween.tween_property(narration_label, "modulate:a", 0.0, 0.4)
		await _tween.finished
	narration_label.modulate.a = 1.0
	_full_text = text
	_chars_shown = 0
	_typing_timer = 0
	narration_label.text = ""
	_typing = true
	
func _unhandled_input(event: InputEvent) -> void:
	if not TransitionManager.is_active:
		return
	if event.is_action_pressed("next_narration"):
		if _typing:
			_typing = false
			narration_label.text = _full_text
		else:
			TransitionManager._advance()
	
func _on_last_line_done() -> void:
	# Fade text
	_tween = create_tween()
	_tween.tween_property(narration_label, "modulate:a", 0.0, 0.5)
	await _tween.finished
	# Fade background to black
	_tween = create_tween()		
	_tween.tween_property(background, "modulate:a", 0.0, 1.0)
	await _tween.finished
	_is_playing = false 
	hide()
	TransitionManager.finish()
