extends CanvasLayer

@onready var container: Control = $Container
@onready var objective_label: Label = $Container/Objective

var _tween: Tween = null
var _visible_duration: float = 3

func _ready() -> void:
	QuestManager.quest_started.connect(_on_quest_updated)
	QuestManager.quest_completed.connect(_on_quest_updated)
	container.modulate.a = 0.0
	container.mouse_entered.connect(_on_mouse_entered)
	container.mouse_exited.connect(_on_mouse_exited)
	# Failsafe autoload 
	var current = QuestManager.get_current_quest()
	if current != null:
		objective_label.text = current.objective
		_fade_in_then_out()

func _on_quest_updated(_quest: QuestData) -> void:
	var current = QuestManager.get_current_quest()
	print("current quest: ", current)
	if current == null:
		_fade_out()
		return
	objective_label.text = current.objective
	print("objective: ", current.objective)
	_fade_in_then_out()
	
func _on_mouse_entered() -> void:
	var current = QuestManager.get_current_quest()	
	if current == null:
		return
	_fade(1.0)

func _on_mouse_exited() -> void:
	_fade(0.0)
	
func _fade_in_then_out() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(container, "modulate:a", 1.0, 0.5)
	_tween.tween_interval(_visible_duration)
	_tween.tween_property(container, "modulate:a", 0.0, 0.5)
	print("tween created")
	pass

func _fade(target_alpha: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(container, "modulate:a", target_alpha, 0.3)

func _fade_out() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(container, "modulate:a", 0.0, 0.5)
