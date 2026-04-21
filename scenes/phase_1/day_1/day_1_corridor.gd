extends Node2D

@onready var moeder = $Moeder
@onready var player = $Player
@onready var father = $Father
@onready var njai = $Njai
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var player_bubble = $Player/SpeechBubble
@onready var father_bubble = $Father/SpeechBubble
@onready var njai_bubble = $Njai/SpeechBubble
@onready var moeder_bubble = $Moeder/SpeechBubble

@export var intro_narration: NarrationData
@export var intro_dialog: DialogData
@export var scene_id: String = "corridor_day1"

var shake_strength: float = 0.0
var shake_fade: float = 5.0
var randomStrength: float = 30.0
var _cutscene_map: Dictionary = {}

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		camera.offset = initialPos + _shake_camera()
	else:
		camera.offset = initialPos
	
	if not QuestManager.was_cutscene_seen("_cutscene_after_moeder_talk"):
		_mamma_face_player()
	if QuestManager.was_cutscene_seen(scene_id):
		pass
	else:
		#print(QuestManager._completed_cutscenes)
		var dist = abs(player.global_position.x - father.global_position.x)
		if dist < 20:
			# We just notify the manager; the manager decides if the quest/cutscene should fire
			QuestManager.notify_proximity("father")

func _ready() -> void:
	QuestManager.trigger_cutscene.connect(start_cutscene) 
	_cutscene_map = {
		"corridor_day_1_father_mad": _cutscene_corridor_father_mad,
		"corridor_day_1_after_moeder_talk": _cutscene_after_moeder_talk,
		"corridor_day_1_ending": _cutsene_after_sweet_finding
	}
	if QuestManager.was_cutscene_seen("corridor_day_1_father_mad"):
		_hide_npc(father)
		_hide_npc(njai)
		
		if QuestManager.was_cutscene_seen("corridor_day_1_after_moeder_talk"):
			_hide_npc(moeder)
		
func start_cutscene(cutscene_id: String) -> void:
	if not _cutscene_map.has(cutscene_id):
		return
	await _cutscene_map[cutscene_id].call()
	QuestManager._completed_cutscenes.append(cutscene_id)

func _cutsene_after_sweet_finding() -> void:
	player.is_frozen = true
	await get_tree().create_timer(1).timeout
		
	await _play_bubble(player_bubble, "mc", "I should bring a couple!", false)
	await _play_bubble(player_bubble, "mc", "Oh, I need to change my clothes too.", false)
	await _play_bubble(player_bubble, "mc", "Ma promised we’re going to spend some time together outside!", false)
	await _play_bubble(player_bubble, "mc", "I should get ready.", false)

	_sprite_face(player, -52.0)
	_sprite_walk(player, -52)
	player.is_frozen = false
	QuestManager.set_day(2)
	TransitionManager.start(intro_narration)
	

func _cutscene_after_moeder_talk() -> void:
	player.is_frozen = true
	
	_sprite_face(moeder, 180)
	_sprite_walk(moeder, 180)
	await get_tree().create_timer(1).timeout
	
	await _play_bubble(player_bubble, "mc", "Mamma’s sweets taste nice.", false)
	await _play_bubble(player_bubble, "mc", "But I still want some more.", false)
	await _play_bubble(player_bubble, "mc", "Seems like Mamma wouldn’t let me get them by myself.", false)

	await _play_bubble(player_bubble, "mc", "I can feel something in my pocket.", true)
	await _play_bubble(player_bubble, "mc", "...", true)
	shake_strength = 1
	await _play_bubble(player_bubble, "mc", "What’s this?", false)
	await _play_bubble(player_bubble, "mc", "Ohh, a paper. Is that a drawing of.. My drawer?", true)
	await _play_bubble(player_bubble, "mc", "And sweets?", true)
	await _play_bubble(player_bubble, "mc", "I should take a look.", true)
	player.is_frozen = false

func _cutscene_corridor_father_mad() -> void:
	_njai_face_father()
	player.is_frozen = true
	player.animated_sprite.play("idle")
	
	await _play_bubble(father_bubble, "Papa", "Godverdomme!", false, "Goddamn")
	await _play_bubble(father_bubble, "Papa", "can't you do anything right?", false)
	await get_tree().create_timer(0.8).timeout
	await _play_bubble(player_bubble, "mc", "It’s that the man in the photo?", true)
	await _play_bubble(player_bubble, "mc", "Papa?", true)
	await _play_bubble(player_bubble, "mc", "Papa looks scary...", true)
	await _play_bubble(player_bubble, "mc", "The young woman looks scared, too.", true)
	
	shake_strength = randomStrength
	await get_tree().create_timer(1).timeout
	
	await _play_bubble(father_bubble, "Papa", "Komen!", false, "Come!")
	
	_sprite_walk(father, 180)
	_sprite_walk(njai, 180)
	
	await _play_bubble(player_bubble, "mc", "Why is she not doing anything?", true)
	await _play_bubble(player_bubble, "mc", "Mamma and the old woman acted as if everything's fine...?", true)
	await _play_bubble(player_bubble, "mc", "Is this normal?", true)
	
	player.is_frozen = false

func _mamma_face_player():
	var mamma_sprite = moeder.get_node("AnimatedSprite2D") # Adjust path if needed
	if player.global_position.x < moeder.global_position.x:
		# Player is to the left, so Mamma flips left
		mamma_sprite.flip_h = true
	else:
		# Player is to the right, Mamma faces default (right)
		mamma_sprite.flip_h = false
		
func _sprite_face(sprite, pos: float):
	var animated_sprite = sprite.get_node("AnimatedSprite2D") # Adjust path if needed
	if sprite.global_position.x < pos:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true

func _njai_face_father():
	var njai_sprite = njai.get_node("AnimatedSprite2D") # Adjust path if needed
	if njai.global_position.x > father.global_position.x:
		# Player is to the left, so njai flips left
		njai_sprite.flip_h = true
	else:
		# Player is to the right, njai faces default (right)
		njai_sprite.flip_h = false

func _sprite_walk(sprite, dest: float) -> void:
	var animated_sprite = sprite.get_node("AnimatedSprite2D")
	if sprite.global_position.x < dest:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
		
	animated_sprite.play("walk")dd
	
	var walk_duration = 2
	var tween = create_tween()
	tween.tween_property(sprite, "global_position:x", dest, walk_duration)

	await tween.finished

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

func _shake_camera() -> Vector2:
	return Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))


func _hide_npc(npc: Node2D) -> void:
	npc.hide()
	# hide interaction area so player can't interact with hidden NPC
	var interaction = npc.get_node_or_null("NpcInteractionArea")
	if interaction:
		interaction.monitoring = false
		interaction.monitorable = false
