extends CanvasLayer

@onready var background: ColorRect = $Background
@onready var narration_label: Label = $Background/NarrationLabel
@onready var advance_label: Label = $AdvanceLabel

var _tween: Tween = null
var _advance_tween: Tween = null

var _full_text: String = ""
var _chars_shown: int = 0
var _typing: bool = false
var _typing_speed: float = 0.1
var _typing_timer: float = 0.0
var _is_playing: bool = false
var _has_shown_advance_prompt = false

func _ready() -> void:
	print("narration ui ready")
	TransitionManager.transition_started.connect(_on_transition_started)
	TransitionManager.narration_line_changed.connect(_on_line_changed)
	TransitionManager.narration_finished.connect(_on_last_line_done)
	background.modulate.a = 0.0
	advance_label.modulate.a = 0.0
	hide()
 
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
			_show_advance_prompt()
			
func _on_transition_started() -> void:
	if _is_playing:
		return
	print("transition started fired!")
	_is_playing = true
	_has_shown_advance_prompt = false
	show()
	narration_label.modulate.a = 0.0
	narration_label.text = ""
	_tween = create_tween()
	_tween.tween_property(background, "modulate:a", 1.0, 1.0)
	await _tween.finished
	TransitionManager.show_first_line()
	
func _on_line_changed(text: String) -> void:
	print("line changed fired: ", text)
	_hide_advance_prompt()
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
			_show_advance_prompt()
		else:
			_hide_advance_prompt()
			TransitionManager._advance()
	
func _on_last_line_done(scene: String) -> void:
	_hide_advance_prompt()
	get_tree().change_scene_to_file(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	print("last line done, starting fade")
	_tween = create_tween()
	_tween.tween_property(narration_label, "modulate:a", 0.0, 0.5)
	await _tween.finished
	print("text faded, fading background")
	_tween = create_tween()
	_tween.tween_property(background, "modulate:a", 0.0, 1.0)
	await _tween.finished
	print("background faded, calling finish")
	_is_playing = false
	hide()
	TransitionManager.finish()
	
func _show_advance_prompt() -> void:
	if _has_shown_advance_prompt:
		return
	_has_shown_advance_prompt = true
	if _advance_tween:
		_advance_tween.kill()
	_advance_tween = create_tween()
	# Fades to 1.0 alpha over 0.5 seconds, but waits 1.0 seconds before starting
	_advance_tween.tween_property(advance_label, "modulate:a", 1.0, 0.5).set_delay(1.0)

func _hide_advance_prompt() -> void:
	if _advance_tween:
		_advance_tween.kill()
	advance_label.modulate.a = 0.0
