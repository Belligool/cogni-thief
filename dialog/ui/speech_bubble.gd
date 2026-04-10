extends Node2D

#TODO UI MASIH BELOM BENER

@onready var sprite: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")
@onready var container: MarginContainer = $MarginContainer
@onready var bubble_bg: NinePatchRect = $MarginContainer/BubbleContainer
@onready var dialog_text:RichTextLabel = $MarginContainer/MarginContainer/DialogText

var _full_text: String = ""
var _chars_shown: int = 0
var _typing: bool = false
var _typing_speed: float = 0.03
var _typing_timer: float = 0.0

func _ready() -> void: 
	hide()
	var texture_height = sprite.sprite_frames.get_frame_texture("idle", 0).get_height()
	position.y = -texture_height * sprite.scale.y + 40
	print(position.y)
		
func _process(delta: float) -> void:
	bubble_bg.size = container.size
	bubble_bg.position = Vector2.ZERO
	
	if not _typing:
		return
	_typing_timer += delta
	if _typing_timer >= _typing_speed:
		_typing_timer = 0.0
		_chars_shown += 1
		dialog_text.text = _full_text.left(_chars_shown)
		if _chars_shown >= _full_text.length():
			_typing = false

func show_line(text: String) ->  void:
	show()
	_full_text = text
	_chars_shown = 0
	_typing_timer = 0.0
	dialog_text.text = ""
	_typing = true
	
func skip_typing() -> void:
	if _typing:
		_typing = false
		dialog_text.text = _full_text
		
func clear() -> void:
	hide()
	dialog_text.text = ""
	_full_text = ""
	_typing = false
