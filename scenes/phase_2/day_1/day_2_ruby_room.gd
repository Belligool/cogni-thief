extends Node2D

@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var player_bubble = $Player/SpeechBubble
@onready var initial_point = PlayerManager.get_total_points()


@export var intro_dialog: DialogData
@export var scene_id: String = "ruby_bedroom_day1"
@export var intro_narration: NarrationData

var shake_strength: float = 0.0
var shake_fade: float = 5.0
var randomStrength: float = 30.0
var _cutscene_map: Dictionary = {} 
var _skip_bubble = false 

func _process(delta: float) -> void:
	if QuestManager.was_cutscene_seen("ruby_bedroom_day1"):
		pass
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		camera.offset = initialPos + _shake_camera()
	else:
		camera.offset = initialPos
	
func _on_premise_line_changed(line: DialogLine) -> void:
	if not DialogManager.is_active:
		return
	if DialogManager._current == null:
		return
	# only handle the premise dialog
	if DialogManager._current.npc_id != "premise":  # ← match npc_id in intro_dialog.tres
		return 
	if line.speaker == "mc":
		player_bubble.show_line(line)

func _on_premise_dialog_ended(_npc_id: String) -> void:
	player_bubble.clear()

func start_cutscene(cutscene_id: String) -> void:
	var current_points = PlayerManager.get_total_points()
	var points_gained = current_points - initial_point
	
	if cutscene_id == "ruby_bedroom_day1":
		await _cutscene_map["ruby_room_day1_after_premise"].call()
	elif cutscene_id == "aftermath_ruby_conversation":
		if points_gained > 0:
			await _cutscene_map["ruby_room_day_1_aftermath_good"].call()
			_on_end_cutscene()
		elif points_gained == 0:
			await _cutscene_map["ruby_room_day_1_aftermath_neutral"].call()
			_on_end_cutscene()
		else:
			await _cutscene_map["ruby_room_day_1_aftermath_bad"].call()
			_on_end_cutscene()

func _ready() -> void:
	DialogManager.line_changed.connect(_on_premise_line_changed)
	DialogManager.dialog_ended.connect(_on_premise_dialog_ended)	
	if not QuestManager.was_intro_seen(scene_id):
		await _play_premise()
	_cutscene_map = {
		"ruby_room_day_1_aftermath_good": _ruby_room_day_1_aftermath_good,
		"ruby_room_day_1_aftermath_neutral": _ruby_room_day_1_aftermath_neutral,
		"ruby_room_day_1_aftermath_bad": _ruby_room_day_1_aftermath_bad,	
		"ruby_room_day1_after_premise": _ruby_room_day_1_after_premise,
	}
	QuestManager.trigger_cutscene.connect(start_cutscene)
	

func _play_premise() -> void:
	player.is_frozen = true
	await get_tree().create_timer(1.0).timeout
	DialogManager.start(intro_dialog)
	QuestManager.mark_intro_done(scene_id)
	player.is_frozen = false
	
func _ruby_room_day_1_after_premise():
	player.is_frozen = true
	player.animated_sprite.play("idle")
	
	await get_tree().create_timer(1).timeout
	await _play_bubble(player_bubble, "mc", "10. 14 PM?", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "From how dark it is now, I’m guessing PM means night?", false)
	
	await _play_bubble(player_bubble, "mc", "And what are… these lines of words?", false)
	
	await _play_bubble(player_bubble, "mc", "Weird...These lines are weird", false)
	
	await _play_bubble(player_bubble, "mc", "but somehow I can make it make sense?", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "These redline...", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "My fingers moved on their own.", false)
	
	await _play_bubble(player_bubble, "mc", " All this felt so foreign", false)
	
	await _play_bubble(player_bubble, "mc", "yet this body...it remembered", false)
	
	await _play_bubble(player_bubble, "mc", "How could this body remember it all so clearly...I wonder?", false)
	await get_tree().create_timer(0.8).timeout
	
	await _play_bubble(player_bubble, "mc", "...this is annoying...How many times do I need to do this?", false)
	
	await _play_bubble(player_bubble, "mc", "Why am I tearing up?", false)
	await get_tree().create_timer(0.5).timeout

	await _play_bubble(player_bubble, "mc","...so emotional", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Is it because of this huge tummy?", false)
	
	await _play_bubble(player_bubble, "mc", "Let’s just finish these first", false)
	
	shake_strength = randomStrength
	await get_tree().create_timer(1).timeout
	
	await _play_bubble(player_bubble, "mc", "What is that?", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Mr. Ahmad Idris?", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "HR Manager?", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Who is he?", false )
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "...", false)
	await get_tree().create_timer(1).timeout
	
	shake_strength = randomStrength
	await _play_bubble(player_bubble, "mc", "A PROMOTION!!!", false)
	await get_tree().create_timer(1).timeout
	
	await _play_bubble(player_bubble, "mc", "'Meet me at my office on Monday 09.30 a.m'", false)
	
	await _play_bubble(player_bubble, "mc", "'But you must live in Alamtanah Residence...until the contract ends'", false)
	
	shake_strength = randomStrength
	await _play_bubble(player_bubble, "mc", "WHAT???", false)
	await get_tree().create_timer(1).timeout

	await _play_bubble(player_bubble, "mc", "Do i really have to move out?", false)

	await _play_bubble(player_bubble, "mc", "What should I do?", false)
	await get_tree().create_timer(0.1).timeout
	
	player_bubble.hide() 
	player_bubble.clear() 
	player_bubble.set_process(false)
	
	var choices: Array[DialogChoice] = [
		DialogChoice.new(),  
		DialogChoice.new(),
		DialogChoice.new(),
	]
	
	choices[0].label = "Do I have to move?"
	choices[0].point_type = DialogChoice.PointType.GOOD

	choices[1].label = "Not my problem"
	choices[1].point_type = DialogChoice.PointType.NEUTRAL

	choices[2].label = "Do I really have to stay?"
	choices[2].point_type = DialogChoice.PointType.BAD

	DialogManager.show_choices(choices)

	await DialogManager.choice_made
	player_bubble.set_process(true)
	start_cutscene("aftermath_ruby_conversation")
	
func _ruby_room_day_1_aftermath_good():
	player.is_frozen = true

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
	
	await InterludeManager.interlude_finished
	
func _ruby_room_day_1_aftermath_neutral():
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "Not my problem", true) 
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "How cares?", true) 
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "I still have a lot of things to do....", true)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "This tasks wouldn't be finished by itself", true)
	await get_tree().create_timer(0.5).timeout

	await InterludeManager.interlude_finished
	
func _ruby_room_day_1_aftermath_bad():
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "Do I really have to stay?", true)
	await get_tree().create_timer(0.5).timeout
	
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
	
	await InterludeManager.interlude_finished
		
func _play_bubble(bubble_node, speaker_name, text_content, is_thought, translation: String = "") -> void:
	var data = DialogLine.new()
	data.text = text_content
	data.is_dialog_thought = is_thought
	data.speaker = speaker_name
	data.translation = translation
	
	bubble_node.show_line(data)
	await _wait_for_input(bubble_node)
	
	bubble_node.clear()

func _wait_for_input(bubble_node) -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			if bubble_node.is_typing():
				bubble_node.skip_typing()
			else:
				break
	
func _shake_camera() -> Vector2:
	var rng = RandomNumberGenerator.new()
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_skip_bubble = true

func _on_end_cutscene():
	QuestManager.set_phase(2)
	QuestManager.set_day(3)
	InteractionManager.can_interact = true
	TransitionManager.start(intro_narration)
