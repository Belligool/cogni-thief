extends CharacterBody2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $AnimatedSprite2D
@onready var audio = $AudioStreamPlayer2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var is_interactable : bool = false

@export var dialogDay1: DialogData 
@export var dialogDay2: DialogData 

var flag_name: String = "unlock_interact_with_mother"

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	QuestManager.trigger_flag.connect(_on_quest_flag_changed)
	if QuestManager.is_flag_active(flag_name):
		is_interactable = true
	
func _on_quest_flag_changed(flag: String) -> void:
	if flag == flag_name:
		is_interactable = true
	else:
		return

func _on_interact():
	if is_interactable:
		DialogManager.start(dialogDay1)
		await DialogManager.dialog_ended 
		return
	else: 
		return
