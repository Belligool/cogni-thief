extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var player = get_tree().get_first_node_in_group("player")
@onready var thought_bubble = player.get_node("SpeechBubble")
@export var dialog: DialogData
 
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	DialogManager.line_changed.connect(_on_line_changed)
	DialogManager.dialog_ended.connect(_on_dialog_ended)
	_evaluate_availability()

func _on_interact():
	DialogManager.start(dialog)
	await DialogManager.dialog_ended
	PlayerManager.add_used_item("desktop")
	_evaluate_availability()
	
func _evaluate_availability() -> void:
	if PlayerManager.is_item_used("desktop"):
		interaction_area.monitoring = false
		interaction_area.monitorable = false
	return
	
func start_auto_cutscene(cutscene_id: String) -> void:
	"""Called automatically after premise, no interaction needed"""
	print("DEBUG: start_auto_cutscene() on desktop STARTED for: ", cutscene_id)
	PlayerManager.add_used_item("desktop")
	print("DEBUG: Item marked as used")
	_evaluate_availability()
	print("DEBUG: Availability evaluated")
	
	var main_scene = get_parent()
	print("DEBUG: main_scene = ", main_scene)
	print("DEBUG: About to call start_cutscene with: ", cutscene_id)
	main_scene.start_cutscene(cutscene_id)
	print("DEBUG: start_cutscene called on main_scene")
	
func _on_line_changed(line: DialogLine) -> void:
	if not DialogManager.is_active:
		return
	if DialogManager._current == null:  
		return
	if DialogManager._current.npc_id != interaction_area.interactable_object_name:
		return
	thought_bubble.show_line(line)
	
func _on_dialog_ended(_npc_id: String) -> void:
	thought_bubble.clear()
