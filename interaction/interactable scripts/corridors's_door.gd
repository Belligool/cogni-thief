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
var is_interactable : bool = false

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	QuestManager.trigger_flag.connect(_evaluate_availibilty)
	DialogManager.line_changed.connect(_on_line_changed)
	DialogManager.dialog_ended.connect(_on_dialog_ended)
	if QuestManager.is_flag_active(flag_name):
		is_interactable = true
	
func _evaluate_availibilty(quest: QuestData) -> void:
	if quest.flag == flag_name:
		is_interactable = true
	else:
		return

func _on_interact():
	if is_interactable != true:
		DialogManager.start(dialog)
		await DialogManager.dialog_ended 
		return
	audio.play()
	await audio.finished
	if is_interactable:
		TransitionManager.change_scene(next_scene, spawn_point_id)
		await TransitionManager.scene_change_finished
	else: 
		return

func _on_line_changed(line: DialogLine) -> void:
	if not DialogManager.is_active:
		return
	if DialogManager._current.npc_id != interaction_area.interactable_object_name:
		return
	thought_bubble.show_line(line)
	
func _on_dialog_ended(_npc_id: String) -> void:
	thought_bubble.clear()
