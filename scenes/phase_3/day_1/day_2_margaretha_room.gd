extends Node2D

@onready var caretaker = $caretaker
@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var player_bubble = $Player/SpeechBubble
@onready var caretaker_bubble = $caretaker/SpeechBubble
@onready var door = $Door/Door_Door
@onready var cabinet = $cabinet

@export var intro_dialog: DialogData
@export var scene_id: String = "margaretha_room_day2"
@export var day_4_transition: NarrationData

var shake_strength: float = 0.0
var shake_fade: float = 5.0
var randomStrength: float = 30.0
var _skip_bubble = false
var _is_cutscene_playing := false 
var _phase: int = 0 

var _cutscene_map: Dictionary = {}

func _ready() -> void:
	DialogManager.line_changed.connect(_on_premise_line_changed)
	DialogManager.dialog_ended.connect(_on_premise_dialog_ended)
	QuestManager.trigger_cutscene.connect(start_cutscene)
	
	_cutscene_map = {
		"caretaker_clean_cabinet": _start_arrival_cutscene,
		"maya_finds_photo": _start_picture_cutscene,
		"check_the_drawer": _start_box_cutscene 
	}
	
	_hide_npc(caretaker)
	_set_interactable(door, true)
	_set_interactable(cabinet, false)
	if not QuestManager.was_intro_seen(scene_id):
		_play_premise()

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		camera.offset = initialPos + _shake_camera()
	else:
		camera.offset = initialPos

	if not _is_cutscene_playing and _phase == 1:
		var dist = abs(player.global_position.x - caretaker.global_position.x)
		if dist < 60.0:
			if QuestManager.has_method("notify_proximity"):
				QuestManager.notify_proximity("caretaker")
			_start_picture_cutscene()

func start_cutscene(cutscene_id: String) -> void:
	if _cutscene_map.has(cutscene_id):
		await _cutscene_map[cutscene_id].call()

func _play_premise() -> void:
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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_skip_bubble = true

func _start_arrival_cutscene() -> void:
	if _is_cutscene_playing:
		return
	_is_cutscene_playing = true
	InteractionManager.can_interact = false
	player.is_frozen = true
	_set_interactable(door, false)
	await _play_bubble(player_bubble, "mc", "Let's try going outside.", true)
	
	door.hide()
	caretaker.modulate.a = 0.0
	caretaker.show()
	caretaker.process_mode = Node.PROCESS_MODE_INHERIT
	
	var fade = create_tween()
	fade.tween_property(caretaker, "modulate:a", 1.0, 0.5)
	await fade.finished
	door.show()
	
	_sprite_face(caretaker, player.global_position.x)
	_sprite_face(player, caretaker.global_position.x)
	
	await _play_bubble(caretaker_bubble, "Caretaker", "You're already awake, Ma'am?", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Did you have a good rest?", false)
	await _play_bubble(player_bubble, "mc", "I've had better sleep.", false)
	
	await _play_bubble(caretaker_bubble, "Caretaker", "Anyways, I had just noticed how dusty your bookshelf had been.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "We don't want you breathing in all that dust, do we?", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "I'll give it a quick clean.", false)
	
	await _sprite_walk(caretaker, cabinet.global_position.x, 50.0)
	_sprite_face(caretaker, cabinet.global_position.x + 10.0) 
	_phase = 1
	_is_cutscene_playing = false
	player.is_frozen = false
	InteractionManager.can_interact = true

func _start_picture_cutscene() -> void:
	if _is_cutscene_playing:
		return
	_is_cutscene_playing = true
	InteractionManager.can_interact = false
	player.is_frozen = true
	
	var right_side_pos = caretaker.global_position.x + 40.0
	await _sprite_walk(player, right_side_pos, 50.0)
	
	_sprite_face(player, caretaker.global_position.x)
	_sprite_face(caretaker, player.global_position.x)
	
	await _play_bubble(caretaker_bubble, "Caretaker", "Oh, look at this!", false)
	await _play_bubble(player_bubble, "mc", "Elise...?", true)
	await _play_bubble(player_bubble, "mc", "Is that...", true)
	await _play_bubble(player_bubble, "mc", "...This old lady's daughter?", true)
	await _play_bubble(caretaker_bubble, "Caretaker", "This...", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Is this you and your daughter?", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "It's hard to believe, but it looks like you two can go well together.", false)
	
	player_bubble.clear()
	await get_tree().process_frame 
	
	var choices: Array[DialogChoice] = [
		DialogChoice.new(),
		DialogChoice.new(),
		DialogChoice.new()
	]
	choices[0].label = "How much did she tell you about me?"
	choices[0].point_type = DialogChoice.PointType.GOOD
	choices[1].label = "It's a long story."
	choices[1].point_type = DialogChoice.PointType.NEUTRAL
	choices[2].label = "Who gave you the right to pry?!"
	choices[2].point_type = DialogChoice.PointType.BAD
	DialogManager.show_choices(choices)
	var chosen_choice = await DialogManager.choice_made
	match chosen_choice.point_type:
		DialogChoice.PointType.GOOD: await _caretaker_aftermath_good()
		DialogChoice.PointType.NEUTRAL: await _caretaker_aftermath_neutral()
		DialogChoice.PointType.BAD: await _caretaker_aftermath_bad()
			
	await _play_bubble(caretaker_bubble, "Caretaker", "Would you like to keep that photo here?", false)
	await _play_bubble(player_bubble, "mc", "Just seeing that picture,", true)
	await _play_bubble(player_bubble, "mc", "...made me uneasy.", true)
	await _play_bubble(player_bubble, "mc", "Put it back inside.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Alright, Ma'am.", false)
	await _play_bubble(player_bubble, "mc", "I wonder...", true)
	await _play_bubble(player_bubble, "mc", "What else is inside the drawer?", true)
	await _play_bubble(player_bubble, "mc", "I need to check later.", true)
	
	_start_day3_transition()

func _caretaker_aftermath_good() -> void:
	await _play_bubble(player_bubble, "mc", "How much did she tell you about me?", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Oh...", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Well... for starters, I know she loved you.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "On my first day here, she gave me a thorough list of what to do and what to avoid.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "She wanted to make absolutely sure you received the best care.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "But I understand that things aren't going smoothly between the two of you.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "... that's all I know.", false)
	await _play_bubble(player_bubble, "mc", "That's not much of an information.", true)
	await _play_bubble(player_bubble, "mc", "Both the old lady...", true)
	await _play_bubble(player_bubble, "mc", "And the daughter...", true)
	await _play_bubble(player_bubble, "mc", "Seems so reluctant,", true)
	await _play_bubble(player_bubble, "mc", "To discuss about their relationship...", true)

func _caretaker_aftermath_neutral() -> void:
	await _play_bubble(player_bubble, "mc", "Yes, it is complicated.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Really? Can I ask why?", false)
	await _play_bubble(player_bubble, "mc", "No, It's a long story...", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Ok... I understand.", false)

func _caretaker_aftermath_bad() -> void:
	shake_strength = randomStrength
	await _play_bubble(player_bubble, "mc", "Who gave you the right to pry?!", false)
	await get_tree().create_timer(0.5).timeout
	await _play_bubble(caretaker_bubble, "Caretaker", "Ma'am, I'm truly sorry if I'm crossing boundaries.", false)
	shake_strength = randomStrength
	await _play_bubble(player_bubble, "mc", "As you should!", false)
	await _play_bubble(player_bubble, "mc", "You don't get to ask me,", false)
	await _play_bubble(player_bubble, "mc", "About my personal life, you hear?", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Y-yes, I'm...", false)
	await _play_bubble(player_bubble, "mc", "Just do what you're paid for!", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Understood, ma'am.", false)
	await get_tree().create_timer(0.5).timeout
	await _play_bubble(player_bubble, "mc", "I can hear her whisper...", true)
	await _play_bubble(caretaker_bubble, "Caretaker", "Just for another week....", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Then I can just... refuse to extend the contract.", false)

# --- DAY 3 TRANSITION & BOX SEQUENCE ---

func _start_day3_transition() -> void:
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.z_index = 100
	get_tree().current_scene.add_child(fade_rect)
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.0)
	await tween.finished
	
	_sprite_face(caretaker, player.global_position.x)
	_sprite_face(player, caretaker.global_position.x)
	
	var tween_in = create_tween()
	tween_in.tween_property(fade_rect, "color:a", 0.0, 1.0)
	await tween_in.finished
	fade_rect.queue_free()
	
	await _play_bubble(caretaker_bubble, "Caretaker", "The bookshelf is clean now, Ma'am.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Would you like me to help you to bed now?", false)
	await _play_bubble(player_bubble, "mc", "I'll sit here for a while longer.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Very well.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Let me know if you need anything.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "I'll have a rest now.", false)
	
	# Maya leaves the room
	await _sprite_walk(caretaker, door.global_position.x, 50.0)
	door.hide()
	var fade = create_tween()
	fade.tween_property(caretaker, "modulate:a", 0.0, 0.5)
	await fade.finished
	_hide_npc(caretaker)
	door.show()
	
	await _play_bubble(player_bubble, "mc", "This is my chance.", true)
	await _play_bubble(player_bubble, "mc", "I should take a look...", true)
	await _play_bubble(player_bubble, "mc", "...at this cabinet.", true)
	_set_interactable(cabinet, true)
	_phase = 3
	player.is_frozen = false
	InteractionManager.can_interact = true
	_is_cutscene_playing = false

func _start_box_cutscene() -> void:
	if _is_cutscene_playing:
		return
	_is_cutscene_playing = true
	InteractionManager.can_interact = false
	player.is_frozen = true
	_set_interactable(cabinet, false)
	_sprite_face(player, cabinet.global_position.x)
	
	await _play_bubble(player_bubble, "mc", "A box?", false)
	await _play_bubble(player_bubble, "mc", "Notes, letters...", false)
	await _play_bubble(player_bubble, "mc", "So many mementos...", false)
	await _play_bubble(player_bubble, "mc", "She kept them all this time?", false)
	await _play_bubble(player_bubble, "mc", "Who could have guessed?", false)
	await _play_bubble(player_bubble, "mc", "The angry woman has a sentimental side.", false)
	await _play_bubble(player_bubble, "mc", "Now what's this?", false)
	
	await get_tree().create_timer(0.5).timeout
	await _play_bubble(player_bubble, "mc", "That fiery, stubborn spirit is genetic, I see.", true)
	await _play_bubble(player_bubble, "mc", "Pushing for STEM over the arts, what a typical parent.", true)
	await _play_bubble(player_bubble, "mc", "What is it about Linguistics though?", true)
	await _play_bubble(player_bubble, "mc", "Is it the one her daughter wanted?", true)
	
	await get_tree().create_timer(0.5).timeout
	await _play_bubble(player_bubble, "mc", "Their relationship is truly complicated.", true)
	await _play_bubble(player_bubble, "mc", "This stubborn old woman cared enough...", true)
	await _play_bubble(player_bubble, "mc", "To keep every single memory...", true)
	await _play_bubble(player_bubble, "mc", "Hidden away in this box...", true)
	await _play_bubble(player_bubble, "mc", "And her daughter cares enough...", true)
	await _play_bubble(player_bubble, "mc", "To pay for top-tier care...", true)
	await _play_bubble(player_bubble, "mc", "To keep her mother safe in her old age.", true)
	await _play_bubble(player_bubble, "mc", "And yet, it seemed like they got into arguments all the time.", true)
	
	player_bubble.clear()
	await get_tree().process_frame 
	
	var choices: Array[DialogChoice] = [
		DialogChoice.new(),
		DialogChoice.new(),
		DialogChoice.new()
	]
	choices[0].label = "Maybe I was too harsh."
	choices[0].point_type = DialogChoice.PointType.GOOD
	choices[1].label = "It was inevitable."
	choices[1].point_type = DialogChoice.PointType.NEUTRAL
	choices[2].label = "You should have listened."
	choices[2].point_type = DialogChoice.PointType.BAD
	DialogManager.show_choices(choices)
	
	var chosen_choice = await DialogManager.choice_made
	match chosen_choice.point_type:
		DialogChoice.PointType.GOOD: 
			await _play_bubble(player_bubble, "mc", "Maybe she needed my help.", true)
		DialogChoice.PointType.NEUTRAL: 
			await _play_bubble(player_bubble, "mc", "What happened between these two was truly complicated.", true)
			await _play_bubble(player_bubble, "mc", "Not something one can simply change.", true)
			await _play_bubble(player_bubble, "mc", "There's nothing to be done that can fix the situation.", true)
		DialogChoice.PointType.BAD: 
			await _play_bubble(player_bubble, "mc", "Now look where you are.", true)
			
	_on_end_cutscene()

func _on_end_cutscene() -> void:
	player.is_frozen = false
	InteractionManager.can_interact = true
	_is_cutscene_playing = false
	QuestManager.set_day(4)
	if day_4_transition != null:
		TransitionManager.start(day_4_transition)
	else:
		printerr("Forgot to slot in Day 4 Transition data!")

# --- HELPER FUNCTIONS ---

func _play_bubble(bubble_node, speaker_name, text_content, is_thought, translation: String = "") -> void:
	bubble_node._typing = false
	bubble_node._full_text = ""
	var data = DialogLine.new()
	data.text = text_content
	data.is_dialog_thought = is_thought
	data.speaker = speaker_name
	data.translation = translation
	bubble_node.show_line(data)
	await _wait_for_input(bubble_node)
	await _wait_for_typing(bubble_node)
	bubble_node.clear()
	await get_tree().process_frame 

func _wait_for_typing(bubble_node) -> void:
	while bubble_node.is_typing():
		await get_tree().process_frame

func _wait_for_input(bubble_node) -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			if bubble_node.is_typing():
				bubble_node.skip_typing()
			else:
				break

func _hide_npc(npc: Node2D) -> void:
	npc.hide()
	var interaction = npc.get_node_or_null("NpcInteractionArea")
	if interaction:
		interaction.monitoring = false
		interaction.monitorable = false

func _sprite_walk(sprite: Node2D, dest: float, speed: float = 0.0) -> void:
	var animated_sprite = sprite.get_node("AnimatedSprite2D")
	if sprite.global_position.x < dest:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	animated_sprite.play("walk")

	if speed == 0:
		speed = 20.0  
	var distance = abs(sprite.global_position.x - dest)
	var walk_duration = distance / speed
	var tween = create_tween()
	tween.tween_property(sprite, "global_position:x", dest, walk_duration)
	await tween.finished
	animated_sprite.play("idle")

func _shake_camera() -> Vector2:
	var rng = RandomNumberGenerator.new()
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func _set_interactable(parent_node: Node2D, state: bool) -> void:
	var area = parent_node.get_node_or_null("InteractionArea")
	if not area:
		area = parent_node.get_node_or_null("NpcInteractionArea")
		
	if area:
		area.set_deferred("monitoring", state)
		area.set_deferred("monitorable", state)

func _sprite_face(sprite: Node2D, target_x: float) -> void:
	var animated_sprite = sprite.get_node("AnimatedSprite2D")
	if sprite.global_position.x < target_x:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
