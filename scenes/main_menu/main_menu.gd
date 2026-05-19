extends Control

@export var intro_narration: NarrationData

@export var float_distance: float = 20.0
@export var float_speed: float = 2.0

@onready var logo: Control = $Logo
@onready var Startbtn: Button = $VBoxContainer/StartButton
@onready var Exitbtn: Button = $VBoxContainer/ExitButton

func _ready() -> void:
	_start_floating()
	_build()
	
func _start_floating() -> void:
	var start_y = logo.position.y
	var tween = create_tween().set_loops()
	
	tween.tween_property(logo, "position:y", start_y - float_distance, float_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(logo, "position:y", start_y, float_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
func _build() -> void:
	Startbtn.pressed.connect(func(): _start())
	Exitbtn.pressed.connect(func(): _quit())

func _start() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	QuestManager.set_day(1)
	QuestManager.set_phase(1)
	TransitionManager.start(intro_narration)
	
func _quit() -> void:
	get_tree().quit() 
