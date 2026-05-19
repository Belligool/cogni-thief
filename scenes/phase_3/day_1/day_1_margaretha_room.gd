extends Node2D

@onready var caretaker = $caretaker
@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var player_bubble = $Player/SpeechBubble
@onready var caretaker_bubble = $caretaker/SpeechBubble

@export var intro_dialog: DialogData
@export var scene_id: String = "margaretha_room_day1"
@export var day_2_transition: NarrationData

var shake_strength: float = 0.0
var shake_fade: float = 5.0
var randomStrength: float = 30.0
var _skip_bubble = false
var _is_cutscene_playing := false 
var _cutscene_map: Dictionary = {}

func _ready() -> void:
	DialogManager.line_changed.connect(_on_premise_line_changed)
	DialogManager.dialog_ended.connect(_on_premise_dialog_ended)
	QuestManager.trigger_cutscene.connect(start_cutscene)
	
	_cutscene_map = {
		"caretaker_arrival": _start_caretaker_cutscene
	}
	_hide_npc(caretaker)
	
	if not QuestManager.was_intro_seen(scene_id):
		_play_premise()
		
	if QuestManager.was_cutscene_seen("caretaker_arrival"):
		caretaker.show()
		caretaker.process_mode = Node.PROCESS_MODE_INHERIT

func _play_premise() -> void:
	player.is_frozen = true
	await get_tree().create_timer(1.0).timeout
	DialogManager.start(intro_dialog)
	QuestManager.mark_intro_done(scene_id)
	player.is_frozen = false

func _on_premise_line_changed(line: DialogLine) -> void:
	if not DialogManager.is_active:
		return
	if DialogManager._current == null: 
		return
	if DialogManager._current.npc_id != "premise":
		return
	player_bubble.clear()
	if line.speaker == "mc":
		player_bubble.show_line(line)

func _on_premise_dialog_ended(_npc_id: String) -> void:
	if _npc_id == "premise":
		player_bubble.clear()

func start_cutscene(cutscene_id: String) -> void:
	if _cutscene_map.has(cutscene_id):
		await _cutscene_map[cutscene_id].call()

func _wait_for_typing(bubble_node) -> void:
	while bubble_node.is_typing():
		await get_tree().process_frame

func _play_bubble(bubble_node, speaker_name, text_content, is_thought, translation: String = "") -> void:
	var data = DialogLine.new()
	data.text = text_content
	data.is_dialog_thought = is_thought
	data.speaker = speaker_name
	data.translation = translation
	
	bubble_node.show_line(data)
	await _wait_for_input(bubble_node)
	await _wait_for_typing(bubble_node)
	bubble_node.clear()
	await get_tree().process_frame # Buffer frame to stop process loop

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		camera.offset = initialPos + _shake_camera()
	else:
		camera.offset = initialPos

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_skip_bubble = true

func _start_caretaker_cutscene() -> void:
	if _is_cutscene_playing:
		return
	_is_cutscene_playing = true
	InteractionManager.can_interact = false
	player.is_frozen = true
	caretaker.show()
	caretaker.process_mode = Node.PROCESS_MODE_INHERIT
	await get_tree().create_timer(0.8).timeout
	shake_strength = randomStrength
	
	_sprite_face(player, caretaker.global_position.x)
	await _walk_player_to_sprite(caretaker, 40.0)
	_sprite_face(caretaker, player.global_position.x)
	
	await _play_bubble(player_bubble, "mc", "M… a… y… a…", true)
	await _play_bubble(player_bubble, "mc", "Maya?", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Good day, ma’am", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "You didn’t sleep well again...", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "...did you?", false)
	await _play_bubble(player_bubble, "mc", "I can’t respond to her question.", true)
	await _play_bubble(player_bubble, "mc", "...", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Your daughter has sent a message this morning.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Do you want me to read it?", false)
	await _play_bubble(player_bubble, "mc", "My body is too tense...", true)
	await _play_bubble(player_bubble, "mc", "...just at the mention of a daughter.", true)
	await _play_bubble(player_bubble, "mc", "This feels uncomfortable, Sharp...", true)
	await _play_bubble(player_bubble, "mc", "...but this was different than anger.", true)
	await _play_bubble(player_bubble, "mc", "What is this?", true)
	
	
	var choices: Array[DialogChoice] = [
		DialogChoice.new(),
		DialogChoice.new(),
		DialogChoice.new()
	]
	choices[0].label = "What did she say?"
	choices[0].point_type = DialogChoice.PointType.GOOD
	choices[1].label = "Later."
	choices[1].point_type = DialogChoice.PointType.NEUTRAL
	choices[2].label = "Stop mentioning her."
	choices[2].point_type = DialogChoice.PointType.BAD
	
	DialogManager.show_choices(choices)
	var chosen_choice = await DialogManager.choice_made
	
	match chosen_choice.point_type:
		DialogChoice.PointType.GOOD: await _caretaker_aftermath_good()
		DialogChoice.PointType.NEUTRAL: await _caretaker_aftermath_neutral()
		DialogChoice.PointType.BAD: await _caretaker_aftermath_bad()
			
	_on_end_cutscene()

func _caretaker_aftermath_good() -> void:
	await _play_bubble(player_bubble, "mc", "What did she say?", false)
	_maya_jump()
	await get_tree().create_timer(0.3).timeout
	await _play_bubble(caretaker_bubble, "Caretaker", "She asked if you're doing well.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "She said she hasn't heard from you in a while.", false)
	await _play_bubble(player_bubble, "mc", "Simple. Those words were too simple to my liking. Mamma wouldn't ask more questions..", true)
	await _play_bubble(player_bubble, "mc", "And yet this body—the owner of this heart, seems to like the news.", true)
	await _play_bubble(player_bubble, "mc", "I can feel my chest getting warmer..", true)
	await _play_bubble(caretaker_bubble, "Caretaker", "Do you want to reply to her?", false)
	await _play_bubble(player_bubble, "mc", "Seems like something is going on between this body and that daughter of hers.", true)
	await _play_bubble(player_bubble, "mc", "I shouldn't act rashly.", true)
	await _play_bubble(player_bubble, "mc", "No.", false)
	await _play_bubble(player_bubble, "mc", "Not yet. Not now.", true)
	await _fade_out_caretaker()

func _caretaker_aftermath_neutral() -> void:
	await _play_bubble(player_bubble, "mc", "Later.", false)
	await get_tree().create_timer(0.5).timeout
	await _play_bubble(caretaker_bubble, "Caretaker", "Alright.", false)
	await _fade_out_caretaker()

func _caretaker_aftermath_bad() -> void:
	await _play_bubble(player_bubble, "mc", "Stop mentioning her.", false)
	_maya_jump()
	await get_tree().create_timer(0.3).timeout
	await _play_bubble(caretaker_bubble, "Caretaker", "...Understood.", false)
	await _fade_out_caretaker()
	await _play_bubble(player_bubble, "mc", "Silent. Too silent. And the tension in the air is undeniable.", true)
	await _play_bubble(player_bubble, "mc", "There is a deep wound inside her, and it seems to be related to her daughter...", true)
	await _play_bubble(player_bubble, "mc", "I should find more information tomorrow.", true)

func _maya_jump() -> void:
	var jump_tween = create_tween()
	var start_y = caretaker.position.y
	jump_tween.tween_property(caretaker, "position:y", start_y - 15, 0.1)
	jump_tween.tween_property(caretaker, "position:y", start_y, 0.1)

func _fade_out_caretaker() -> void:
	var tween = create_tween()
	tween.tween_property(caretaker, "modulate:a", 0.0, 1.0)
	await tween.finished
	_hide_npc(caretaker)

func _on_end_cutscene() -> void:
	player.is_frozen = false
	InteractionManager.can_interact = true
	_is_cutscene_playing = false
	QuestManager.set_day(2)
	
	if day_2_transition != null:
		TransitionManager.start(day_2_transition)
	else:
		printerr("Forgot to slot in Day 2 Transition data!")

func _hide_npc(npc: Node2D) -> void:
	npc.hide()
	var interaction = npc.get_node_or_null("NpcInteractionArea")
	if interaction:
		interaction.monitoring = false
		interaction.monitorable = false

func _walk_player_to_sprite(sprite: Node2D, distance: float) -> void:
	var player_sprite = player.get_node("AnimatedSprite2D")
	var target_pos = sprite.global_position
	if player.global_position.x < sprite.global_position.x:
		target_pos.x -= distance
		player_sprite.flip_h = false
	else:
		target_pos.x += distance
		player_sprite.flip_h = true
	player_sprite.play("walk")
	var speed = 50.0 
	var d = abs(player.global_position.x - target_pos.x)
	var walk_duration = d / speed
	var tween = create_tween()
	tween.tween_property(player, "global_position", target_pos, walk_duration)
	await tween.finished
	player_sprite.play("idle")

func _shake_camera() -> Vector2:
	var rng = RandomNumberGenerator.new()
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func _sprite_face(sprite, pos: float):
	var animated_sprite = sprite.get_node("AnimatedSprite2D")
	if sprite.global_position.x < pos:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true

func _wait_for_input(bubble_node) -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			if bubble_node.is_typing():
				bubble_node.skip_typing()
			else:
				break
