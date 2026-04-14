extends Node2D

@export var intro_dialog: DialogData
@export var scene_id: String = "corridor_day1"

#func _ready() -> void:
	#if not QuestManager.was_intro_seen(scene_id):
		#_play_premise()
#
#func _play_premise() -> void:
	#await get_tree().create_timer(1.0).timeout
	#DialogManager.start(intro_dialog)
	#QuestManager.mark_intro_dome(scene_id)
