extends Node2D

@onready var audio = $AudioListener2D
@onready var sprite: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")
@onready var container: MarginContainer = $MarginContainer
@onready var bubble_bg: NinePatchRect = $MarginContainer/BubbleContainer
@onready var dialog_text:RichTextLabel = $MarginContainer/MarginContainer/VBoxContainer/DialogText
@onready var translation_text: RichTextLabel = $MarginContainer/MarginContainer/VBoxContainer/TranslationText

@export var thought_margin: Vector4 = Vector4(15, 12, 4, 12) # Left, Top, Right, Bottom
@export var normal_margins: Vector4 = Vector4(16, 16, 16, 16)
@export var normal_texture: Texture2D
@export var thought_texture: Texture2D

var _full_text: String = ""
var _chars_shown: int = 0
var _typing: bool = false
var _typing_speed: float = 0.03
var _typing_timer: float = 0.0
var _speaker: String = ""
var _is_visible_and_active: bool = false
var _full_translation: String = ""
var _translation_chars_shown: int = 0

func _ready() -> void: 
	hide()
	# Position handling for the bubble to always be ontop of the current talking sprite
func _process(delta: float) -> void:
	if not _is_visible_and_active or not _typing:
		return
	bubble_bg.size = container.size
	bubble_bg.position = Vector2.ZERO
	var texture_height = sprite.sprite_frames.get_frame_texture("idle", 0).get_height()
	position.y = -texture_height * sprite.scale.y + 28
	#position.x = -10
	
	if not _typing:
		return
	_typing_timer += delta
	if _typing_timer >= _typing_speed:
		_typing_timer = 0.0
		_chars_shown += 1
		
		var current_char = _full_text[_chars_shown - 1]
		dialog_text.text = _full_text.left(_chars_shown)
		
		if _full_translation != "" and _translation_chars_shown < _full_translation.length():
			_translation_chars_shown += 1
			translation_text.text = _full_translation.left(_translation_chars_shown)
		
		# Only play sound if the character isn't a space
		if current_char.strip_edges() != "" and current_char != ".":
			_play_voice_blip()
		
		if _chars_shown >= _full_text.length():
			_typing = false
			dialog_text.text = _full_text
			
			if _full_translation != "":
				translation_text.text = _full_translation
				_translation_chars_shown = _full_translation.length()
		
		var last_char = _full_text[_chars_shown - 1]
		if last_char in [".", "!", "?", "—"]:
			_typing_timer = -0.5 # Wait an extra 0.5 seconds
		elif last_char in [",", ";", ":"]:
			_typing_timer = -0.4 # Wait an extra 0.4  seconds

func show_line(data: DialogLine) ->  void:
	show()
	_is_visible_and_active = true 
	_speaker = data.speaker
	dialog_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	dialog_text.custom_minimum_size.x = 0
	
	_translation_chars_shown = 0
	
	_full_text = data.text
	dialog_text.text = ""
	
	await get_tree().process_frame
	
	var max_width = 65
	#print (_full_text.length())
	
	if _full_text.length() > max_width:
		dialog_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		dialog_text.custom_minimum_size.x = 250
	else:
		dialog_text.custom_minimum_size.x = dialog_text.get_content_width()
	
	## Flip the bubble if its not the mc
	#if data.speaker != "mc":
		#bubble_bg.flip_h = true
	#else: 
		#bubble_bg.flip_h = false
	
	# Handle UI if dialog is thought or not
	if data.is_dialog_thought and thought_texture:
		bubble_bg.texture = thought_texture
		#bubble_bg.modulate.a = 0.5
		_update_margin(thought_margin)
		
	elif normal_texture:
		bubble_bg.texture = normal_texture
		#bubble_bg.modulate.a = 1.0
		_update_margin(normal_margins)
	
	_full_translation = data.translation
	translation_text.text = ""
	if data.translation != "":
		translation_text.show()
	else:
		translation_text.hide()

	_chars_shown = 0
	_typing_timer = 0.0
	_typing = true
	
func skip_typing() -> void:
	if _typing:
		_typing = false
		dialog_text.text = _full_text
		translation_text.text = _full_translation
		_translation_chars_shown = _full_translation.length()
		
func _update_margin(m: Vector4) -> void:
	bubble_bg.patch_margin_left = int(m.x)
	bubble_bg.patch_margin_top = int(m.y)
	bubble_bg.patch_margin_right = int(m.z)
	bubble_bg.patch_margin_bottom = int(m.w)

func clear() -> void:
	hide()
	_is_visible_and_active = false
	dialog_text.text = ""
	_full_text = ""
	_typing = false
	_full_translation = ""
	_translation_chars_shown = 0
	translation_text.text = ""
	translation_text.hide()

func _play_voice_blip() -> void:
	if _speaker != "mc":
		audio.pitch_scale = randf_range(1.5,2.0) 
		audio.play()
	else:
		audio.pitch_scale = randf_range(0.7, 1.1) 
		audio.play()
