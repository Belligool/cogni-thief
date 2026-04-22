extends Node2D


@onready var player = $Player
@onready var player_bubble = $Player/SpeechBubble


@export var intro_dialog: DialogData
@export var scene_id: String = "ruby_bedroom_day1"

func _ready() -> void:
	await get_tree().process_frame
	if not QuestManager.was_intro_seen(scene_id):
		_play_premise()
	QuestManager.trigger_cutscene.connect(start_cutscene) 

func _play_premise() -> void:
	player.is_frozen = true
	await get_tree().create_timer(1.0).timeout
	DialogManager.start(intro_dialog)
	QuestManager.mark_intro_dome(scene_id)
	player.is_frozen = false

func start_cutscene(cutscene_id: String) -> void:
	if cutscene_id != scene_id: return
	
	await _play_bubble(player_bubble, "???", "Schatje.. Darling, are you awake?", false, "Sweetie.. Darling, are you awake?")
	
	await _play_bubble(player_bubble, "???", "Liefje?", false, "Darling?")
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "mc..? I'm- Matthijs' is sorry..", false)
	
	await _play_bubble(player_bubble, "mc", "Worry not, Schatje.", false, "Worry not, Sweetie.")
	await _play_bubble(player_bubble, "mc", "You just woke up from your nap.", false)
	await _play_bubble(player_bubble, "mc", "Have you not?", false)
	await _play_bubble(player_bubble, "mc", "It's time for afternoon tea.", false)
	await _play_bubble(player_bubble, "mc", "Your father is waiting for you.", false)
	await _play_bubble(player_bubble, "mc", "Be sure to look presentable, verstaan?", false, "Be sure to look presentable, understood?")
	
	var tween = create_tween()
	await tween.finished
	
	await get_tree().create_timer(1).timeout
	
	await _play_bubble(player_bubble, "mc", "That was involuntary.", true)
	player.is_frozen = false
	
func _play_bubble(bubble_node, speaker_name, text_content, is_thought, translation: String = "") -> void:
	var data = DialogLine.new()
	data.text = text_content
	data.is_dialog_thought = is_thought
	data.speaker = speaker_name
	data.translation = translation
	
	bubble_node.show_line(data)
	
	var wait_time = (text_content.length() * 0.05) + 1.5
	await get_tree().create_timer(wait_time).timeout
	
	bubble_node.clear()
	

#mother_cutscene
