extends Node2D

@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var player_bubble = $Player/SpeechBubble
@onready var initial_point = PlayerManager.get_total_points()

@export var intro_narration: NarrationData
@export var intro_dialog: DialogData
@export var scene_id: String = "ruby_bedroom_day1"

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
	
func _on_premise_line_changed(line: DialogLine) -> void:
	if not DialogManager.is_active:
		return
	# only handle the premise dialog
	if DialogManager._current.npc_id != "premise":  # ← match npc_id in intro_dialog.tres
		return
	if line.speaker == "mc":
		player_bubble.show_line(line)

func _on_premise_dialog_ended(_npc_id: String) -> void:
	player_bubble.clear()

func start_cutscene(cutscene_id: String) -> void:
	if cutscene_id != scene_id: 
		return
	
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "10. 14 PM?", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "From how dark it is now, I’m guessing PM means night?", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "And what are… these lines of words?", false)
	await get_tree().create_timer(0.5).tineout
	
	await _play_bubble(player_bubble, "mc", "Weird...These lines are weird", false)
	await get_tree().create_timer(0.5).timeout
	
	
	
	var current_points = PlayerManager.get_total_points()
	var points_gained = current_points - initial_point
	
	if points_gained > 0:
		await _cutscene_map["ruby_room_day_1_aftermath_good"].call()
	elif points_gained == 0:
		await _cutscene_map["ruby_room_day_1_aftermath_neutral"].call()
	else:
		await _cutscene_map["ruby_room_day_1_aftermath_bad"].call()

func _ruby_room_day_1_aftermath_good():
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "What Should I do?", true) 
	await _play_bubble(player_bubble, "mc", "Do I have to move?", true)
	await _play_bubble(player_bubble, "mc", "This body", true)
	
	await get_tree().create_timer(0.8).timeout

	await _play_bubble(player_bubble, "mc", "Who is he?", true)
	await _play_bubble(player_bubble, "mc", "Wait...", true)
	await _play_bubble(player_bubble, "mc", "Isn't he...", true)
	
	await get_tree().create_timer(0.8).timeout
	
	await _play_bubble(player_bubble, "mc", "First Anniversary?", true)
	await _play_bubble(player_bubble, "mc", "May 27th 2017?", true)
	
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Oh, no...", true)
	await _play_bubble(player_bubble, "mc", "No no no no....", true)
	
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Is he really my husband?", true)
	
	await _play_bubble(player_bubble, "mc", "Fine,Fine, Fine", true)
	await _play_bubble(player_bubble, "mc", "I reject this", true)
	
	await get_tree().create_timer(0.8).timeout
	
	await _play_bubble(player_bubble, "mc", "Good Evening...Mr. Idris", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Thank you so much for the offer", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "However", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "after careful consideration with my family...", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "I must refuse the offer of promotion.", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Once again...", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "I would like to express my gratitude for the offer.", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "I hope you can find a suitable candidate for this position.", false)
	
func _ruby_room_day_1_aftermath_neutral():
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "What is this?", true) 
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Oh...", true) 
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "It's just a message from my HR...", true)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "I'll read it later....", true)
	await get_tree().create_timer(0.5).timeout
	
func _ruby_room_day_1_aftermath_bad():
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "I should discuss this...", true)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "but the money…", true)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Even so...", true)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Could this body handle it?", true)
	await get_tree().create_timer(0.8).timeout
	
	await _play_bubble(player_bubble, "mc", "Ugh!!!", true)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Fine then!!!", true)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Let’s do it!", true)
	
	await get_tree().create_timer(0.8).timeout
	
	await _play_bubble(player_bubble, "mc", "Good Evening...Mr. Idris", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Thank you so much for the offer", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "After careful consideration...", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "I would love to accept the new position", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "I would love to discuss the matter even further at your office.", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Once again...", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "I would like to express my gratitude for the offer.", false)
	await get_tree().create_timer(0.5).timeout
	
	
func _ready() -> void:
	DialogManager.line_changed.connect(_on_premise_line_changed)
	DialogManager.dialog_ended.connect(_on_premise_dialog_ended)
	if not QuestManager.was_intro_seen(scene_id):
		_play_premise()
	_cutscene_map = {
		"ruby_room_day_1_aftermath_good": _ruby_room_day_1_aftermath_good,
		"ruby_room_day_1_aftermath_neutral": _ruby_room_day_1_aftermath_neutral,
		"ruby_room_day_1_aftermath_bad": _ruby_room_day_1_aftermath_bad,
	}
	QuestManager.trigger_cutscene.connect(start_cutscene) 

func _play_premise() -> void:
	player.is_frozen = true
	await get_tree().create_timer(1.0).timeout
	DialogManager.start(intro_dialog)
	QuestManager.mark_intro_done(scene_id)
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
	
func _shake_camera() -> Vector2:
	var rng = RandomNumberGenerator.new()
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
	
#mother_cutscene
func _hide_npc(npc: Node2D) -> void:
	npc.hide()
	# hide interaction area so player can't interact with hidden NPC
	var interaction = npc.get_node_or_null("NpcInteractionArea")
	if interaction:
		interaction.monitoring = false
		interaction.monitorable = false
