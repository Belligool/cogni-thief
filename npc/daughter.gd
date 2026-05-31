extends Node2D

@onready var interaction_area: NpcInteractionArea = $NpcInteractionArea
@onready var bubble: Node2D = $SpeechBubble
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var dialog: DialogData
@export var dialogs_per_day: Array[DialogData] = []
@export var one_time_only: bool = false     
@export var current_flag: String = "lock"

var player = null
var player_bubble = null

func _ready() -> void:
	interaction_area.action_name = "talk"
	interaction_area.interact = Callable(self, "_on_interact")
	player = get_tree().get_first_node_in_group("player")
	if player:
		player_bubble = player.get_node_or_null("SpeechBubble")
		
	DialogManager.line_changed.connect(_on_line_changed)
	DialogManager.dialog_ended.connect(_on_dialog_ended)
	QuestManager.trigger_flag.connect(_evaluate_availability)
	dialog = _get_current_dialog()
	_evaluate_availability()

func _evaluate_availability(quest: QuestData = null) -> void:
	var available = true
	if quest != null:
		if quest.flag_target != interaction_area.interactable_object_name:
			return
		else:
			if !quest.flag.contains("unlock"):
				available = false
			interaction_area.monitoring = available
			interaction_area.monitorable = available
			return
	else:
		if PlayerManager.interacted_npc.has("daughter"):
			available = false
		elif current_flag == "lock":
			available = false
		interaction_area.monitoring = available
		interaction_area.monitorable = available
		return

func _get_current_dialog() -> DialogData:
	if not dialogs_per_day.is_empty():
		var day = QuestManager.get_current_day()
		var index = day - 1
		if index >= 0 and index < dialogs_per_day.size():
			return dialogs_per_day[index]
	return dialog

func _on_interact() -> void:
	var current_dialog = _get_current_dialog()
	if current_dialog == null:
		return
		
	if player != null:
		var direction = player.global_position - global_position
		if direction.x < 0:
			animated_sprite.flip_h = true
		elif direction.x > 0:
			animated_sprite.flip_h = false
			
	DialogManager.start(current_dialog)
	PlayerManager.add_interacted_npc("daughter")
	await DialogManager.dialog_ended
	
func _on_line_changed(line: DialogLine) -> void:
	if not DialogManager.is_active:
		return
	if DialogManager._current == null:
		return
	if DialogManager._current.npc_id != interaction_area.interactable_object_name:
		return
		
	bubble.clear()
	if player_bubble:
		player_bubble.clear()
		
	if line.speaker != "mc":
		bubble.show_line(line)
	else:
		if player_bubble:
			player_bubble.show_line(line)
		
func _on_dialog_ended(_npc_id: String) -> void:
	bubble.clear()
	if player_bubble:
		player_bubble.clear()
	_evaluate_availability()
