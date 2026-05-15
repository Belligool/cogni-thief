extends CanvasLayer

@onready var container: Control = $Container
@onready var objective_label: Label = $Container/Objective

var _tween: Tween = null
var _visible_duration: float = 3

func _ready() -> void:
	QuestManager.quest_started.connect(_on_quest_updated)
	QuestManager.quest_completed.connect(_on_quest_updated)
	TransitionManager.transition_started.connect(_on_narration)
	InterludeManager.interlude_started.connect(_on_narration)
	TransitionManager.narration_finished.connect(_on_done)
	InterludeManager.interlude_finished.connect(_on_done)
	# Failsafe autoload 
	var current = QuestManager.get_current_quest()
	if current != null:
		objective_label.text = current.objective
		container.modulate.a = 0.0
		_fade(1.0)
		#_fade_in_then_out()
		
func _on_narration():
	_fade(0.0)
	
func _on_done(_narration_data=null):
	_fade(1.0)
	
func _fade_in_then_out() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(container, "modulate:a", 1.0, 0.5)
	_tween.tween_interval(_visible_duration)
	_tween.tween_property(container, "modulate:a", 0.0, 0.5)
	print("tween created")
	pass
	
func _on_quest_updated(_quest: QuestData) -> void:
	var current = QuestManager.get_current_quest()
	print("current quest: ", current)
	if current == null:
		_fade_out()
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(container, "modulate:a", 0.0, 0.5)
	_tween.tween_callback(func(): objective_label.text = current.objective)
	_tween.tween_property(container, "modulate:a", 1.0, 0.5)
	print("objective: ", current.objective)

func _fade(target_alpha: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(container, "modulate:a", target_alpha, 1.0)

func _fade_out() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(container, "modulate:a", 0.0, 1.0 )
