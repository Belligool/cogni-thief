extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D
@onready var audio = $AudioStreamPlayer2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var thought_bubble = player.get_node("SpeechBubble")
@export var next_scene: String = ""
@export var spawn_point_id: String = ""
@export var dialog: DialogData


var flag_name: String = "unlock_matthijs_door"

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	DialogManager.line_changed.connect(_on_line_changed)
	DialogManager.dialog_ended.connect(_on_dialog_ended)
	QuestManager.trigger_flag.connect(_evaluate_availibilty)
	_evaluate_availibilty()

func _evaluate_availibilty(quest: QuestData = null) -> void:
	if quest != null:
		if quest.flag == flag_name:
			interaction_area.monitoring = true
			interaction_area.monitorable = true
			return
	else:
		if (QuestManager.get_current_day() == 1)  and !QuestManager.is_flag_active(flag_name):
			interaction_area.monitoring = false
			interaction_area.monitorable = false
		elif (QuestManager.get_current_day() == 2):
			interaction_area.monitoring = false
			interaction_area.monitorable = false

func _on_interact():
	audio.play()
	await audio.finished
	TransitionManager.change_scene(next_scene, spawn_point_id)
	await TransitionManager.scene_change_finished

func _on_line_changed(line: DialogLine) -> void:
	if not DialogManager.is_active:
		return
	if DialogManager._current.npc_id != interaction_area.interactable_object_name:
		return
	thought_bubble.show_line(line)
	
func _on_dialog_ended(_npc_id: String) -> void:
	thought_bubble.clear()
