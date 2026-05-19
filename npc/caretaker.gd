extends Node2D

@onready var interaction_area: NpcInteractionArea = $NpcInteractionArea
@onready var bubble: Node2D = $SpeechBubble
@export var dialog: DialogData
@export var dialogs_per_day: Array[DialogData] = []
@export var one_time_only: bool = false     # can only interact once
@export var current_flag: String = "lock"


var player = null
var player_bubble = null

func _ready() -> void:
	interaction_area.action_name = "talk"
	interaction_area.interact = Callable(self, "_on_interact")
	player = get_tree().get_first_node_in_group("player")
	player_bubble = player.get_node("SpeechBubble")
	DialogManager.line_changed.connect(_on_line_changed)
	DialogManager.dialog_ended.connect(_on_dialog_ended)
	QuestManager.trigger_flag.connect(_evaluate_availability)
	dialog = _get_current_dialog()
	_evaluate_availability()
  
func _evaluate_availability(quest: QuestData = null) -> void:
	print("evaluating availability for: ", interaction_area.interactable_object_name)
	var available = true
	if quest != null:
		if quest.flag_target != interaction_area.interactable_object_name:
			return
		else:
			print(QuestManager.triggered_flags)
			if !quest.flag.contains("unlock"):
				available = false
			interaction_area.monitoring = available
			interaction_area.monitorable = available
			return
	else:
		print("interacted_npc array: ", PlayerManager.interacted_npc)
		if PlayerManager.interacted_npc.has("caretaker"):
			print('caretaker lock')
			available = false
		elif (QuestManager.is_flag_active('unlock_interact_with_mother_day_1')) and (QuestManager.get_current_day() == 1) and (get_tree().current_scene.name == 'day1_corridor') and !(PlayerManager.is_npc_interacted("moeder")):
			print('caretaker unlock')
			available = true
		elif current_flag == "lock":
			print('caretaker locked')
			available = false
		interaction_area.monitoring = available
		interaction_area.monitorable = available
		return

func _get_current_dialog() -> DialogData:
	if not dialogs_per_day.is_empty():
		var day = QuestManager.get_current_day()
		var index = day-1
		return dialogs_per_day[index]
	return dialog

func _on_interact() -> void:
	var current_dialog = _get_current_dialog()
	if dialog == null:
		return
	print("starting interaction with npc ")
	DialogManager.start(current_dialog)
	PlayerManager.add_interacted_npc("caretaker")
	await DialogManager.dialog_ended
	
func _on_line_changed(line: DialogLine) -> void:
	if not DialogManager.is_active:
		return
	if DialogManager._current == null:
		return
	if DialogManager._current.npc_id != interaction_area.interactable_object_name:
		return
	print("speaker: '", line.speaker, "'")
	bubble.clear()
	player_bubble.clear()
	if line.speaker != "mc":
		bubble.show_line(line)
	else:
		player_bubble.show_line(line)
		
func _on_dialog_ended(_npc_id: String) -> void:
	bubble.clear()
	if player:
		player.get_node("SpeechBubble").clear()
	_evaluate_availability()
