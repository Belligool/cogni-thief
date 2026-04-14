extends Node2D

@onready var moeder = $Moeder
@onready var player_bubble = $Player/SpeechBubble
@onready var moeder_bubble = $Moeder/SpeechBubble

@export var intro_dialog: DialogData
@export var scene_id: String = "matthijs_bedroom_day1"

func _ready() -> void:
	if not QuestManager.was_intro_seen(scene_id):
		_play_premise()
	QuestManager.trigger_cutscene.connect(start_cutscene) 
	moeder.hide()

func _play_premise() -> void:
	await get_tree().create_timer(1.0).timeout
	DialogManager.start(intro_dialog)
	QuestManager.mark_intro_dome(scene_id)

func start_cutscene(cutscene_id: String) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if cutscene_id != scene_id: return
	
	moeder.show()
	_mamma_face_player()
	await _walk_player_to_moeder()
	
	await _play_bubble(moeder_bubble, "???", "Schatje.. Darling, are you awake?", false)
	
	#_shake_camera(0.4, 8.0)
	
	await _play_bubble(moeder_bubble, "???", "Liefje?", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "Matthijs", "Mamma..? I'm- Matthijs' is sorry..", false)
	
	await _play_bubble(moeder_bubble, "Mamma", "Worry not, Schatje. You just woke up from your nap, have you not?", false)
	await _play_bubble(moeder_bubble, "Mamma", "It's time for afternoon tea. Your father is waiting for you.", false)
	await _play_bubble(moeder_bubble, "Mamma", "Be sure to look presentable, verstaan?", false)
	
	moeder.hide()
	
	await _play_bubble(player_bubble, "Matthijs", "That was involuntary.", true)
	player.is_frozen = false
	
func _play_bubble(bubble_node, speaker_name, text_content, is_thought) -> void:
	var data = DialogLine.new()
	data.text = text_content
	data.is_dialog_thought = is_thought
	data.speaker = speaker_name
	
	bubble_node.show_line(data)
	
	var wait_time = (text_content.length() * 0.05) + 1.5
	await get_tree().create_timer(wait_time).timeout
	
	bubble_node.clear()
	
func _mamma_face_player():
	var mamma_sprite = moeder.get_node("AnimatedSprite2D") # Adjust path if needed
	var player = get_tree().get_first_node_in_group("player")
	if player.global_position.x < moeder.global_position.x:
		# Player is to the left, so Mamma flips left
		mamma_sprite.flip_h = true
	else:
		# Player is to the right, Mamma faces default (right)
		mamma_sprite.flip_h = false

func _walk_player_to_moeder() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var player_sprite = player.get_node("AnimatedSprite2D")
	
	player.is_frozen = true
	
	var target_pos = moeder.global_position
	if player.global_position.x < moeder.global_position.x:
		target_pos.x -= 40
		player_sprite.flip_h = false
	else:
		target_pos.x += 40
		player_sprite.flip_h = true
		
	player_sprite.play("walk")
	
	var walk_duration = 1.5
	var tween = create_tween()
	tween.tween_property(player, "global_position", target_pos, walk_duration)
	
	await tween.finished
	
	player_sprite.play("idle")
	
#func _shake_camera(duration: float, strength: float) -> void:
	#var cam = get_viewport().get_camera_2d()
	#if not cam: return
	#
	#var tween = create_tween()
	#for i in range(8):
		#var rand_offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		#tween.tween_property(cam, "offset", rand_offset, duration / 8)
		#
		#tween.tween_property(cam, "offset", Vector2.ZERO, 0.1)
#mother_cutscene
