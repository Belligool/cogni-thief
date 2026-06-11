extends Node2D

@onready var caretaker = $caretaker
@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var player_bubble = $Player/SpeechBubble
@onready var caretaker_bubble = $caretaker/SpeechBubble
@onready var door = $Door/Door_Door

@export var scene_id: String = "margaretha_room_day3"
@export var end_phase_transition: NarrationData

var shake_strength: float = 0.0
var shake_fade: float = 5.0
var _is_cutscene_playing := false

func _ready() -> void:
	# Hide caretaker off-screen to the right, she will walk in automatically
	caretaker.modulate.a = 1.0
	caretaker.show()
	caretaker.process_mode = Node.PROCESS_MODE_INHERIT
	_set_interactable(caretaker, false)

	# Place her off to the right side, outside the visible area
	caretaker.global_position.x = player.global_position.x + 300.0

	await get_tree().process_frame
	await _start_day_cutscene()

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		camera.offset = initialPos + _shake_camera()
	else:
		camera.offset = initialPos

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		pass

# ==========================================
# MAIN CUTSCENE
# ==========================================

func _start_day_cutscene() -> void:
	if _is_cutscene_playing:
		return
	_is_cutscene_playing = true
	InteractionManager.can_interact = false
	player.is_frozen = true

	# Brief pause so scene is fully visible before anything moves
	await get_tree().create_timer(0.8).timeout

	# Maya walks toward the player from the right
	var approach_pos = player.global_position.x + 60.0
	await _sprite_walk(caretaker, approach_pos, 50.0)

	_sprite_face(caretaker, player.global_position.x)
	_sprite_face(player, caretaker.global_position.x)

	# Maya delivers the message
	await _play_bubble(player_bubble, "mc", "Hm? What's this", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "It's another message, from your daughter, mam", false)

	# MC reads the message
	await get_tree().create_timer(1.0).timeout
	await _play_bubble(player_bubble, "mc", "Im sorry for never listening to you", true)
	await _play_bubble(player_bubble, "mc", "I know you always wanted the best for me", true)
	await _play_bubble(player_bubble, "mc", "But Little Jos wasn't something i was willing to give up", true)
	await _play_bubble(player_bubble, "mc", "Miss you, from Elise", true)

	await get_tree().create_timer(0.5).timeout
	await _play_bubble(player_bubble, "mc", "...Sigh", true)
	await _play_bubble(player_bubble, "mc", "The old woman sure has a lot of complicated emotions", true)
	await _play_bubble(player_bubble, "mc", "But reading this message now...", true)

	player_bubble.clear()
	await get_tree().process_frame

	# Show choices
	var choices: Array[DialogChoice] = [
		DialogChoice.new(),
		DialogChoice.new(),
		DialogChoice.new()
	]
	choices[0].label = "Ask about Elise's son"
	choices[0].point_type = DialogChoice.PointType.GOOD
	choices[1].label = "Thank Maya"
	choices[1].point_type = DialogChoice.PointType.NEUTRAL
	choices[2].label = "Reject the message"
	choices[2].point_type = DialogChoice.PointType.BAD

	DialogManager.show_choices(choices)
	var chosen_choice = await DialogManager.choice_made

	match chosen_choice.point_type:
		DialogChoice.PointType.GOOD: await _aftermath_good()
		DialogChoice.PointType.NEUTRAL: await _aftermath_neutral()
		DialogChoice.PointType.BAD: await _aftermath_bad()

	await _ending_sequence()

# ==========================================
# CHOICE BRANCHES
# ==========================================

func _aftermath_good() -> void:
	await _play_bubble(player_bubble, "mc", "Maya, have you met Elise's son before?", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Yes, he's very sweet, if not a little mischievous.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "He seems rather lonely though, with her mother working full time and all.", false)

	await get_tree().create_timer(1.0).timeout
	await _play_bubble(player_bubble, "mc", "I shouldn't have left her alone.", true)
	await _play_bubble(player_bubble, "mc", "I should've been there to help.", true)

	# Maya awkward shuffle animation
	var anim = caretaker.get_node("AnimatedSprite2D")
	anim.flip_h = not anim.flip_h
	await get_tree().create_timer(0.4).timeout
	anim.flip_h = not anim.flip_h
	await get_tree().create_timer(0.4).timeout

	await _play_bubble(caretaker_bubble, "Caretaker", "Mam? Is everything alright?", false)
	await _play_bubble(player_bubble, "mc", "...Yes, tell Elise that... little Jos and her can visit any time.", false)

	await get_tree().create_timer(0.5).timeout
	await _play_bubble(caretaker_bubble, "Caretaker", "I see, I'll make sure she receives the message.", false)

func _aftermath_neutral() -> void:
	await _play_bubble(player_bubble, "mc", "It seems like the old woman no longer has the capacity to care.", true)
	await _play_bubble(player_bubble, "mc", "Thank you, Maya.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Excuse me, mam. But are you not going to answer her?", false)

func _aftermath_bad() -> void:
	await _play_bubble(player_bubble, "mc", "*Scoffs*", false)
	await _play_bubble(player_bubble, "mc", "She never learned her lesson at all.", false)
	await _play_bubble(player_bubble, "mc", "Stubborn as always.", false)
	await _play_bubble(player_bubble, "mc", "Came back crying every time she was hurt despite every warning.", false)

	# MC shoves the tablet at Maya, Maya steps back
	var backup_pos = caretaker.global_position.x + 20.0
	await _sprite_walk(caretaker, backup_pos, 60.0)
	_sprite_face(caretaker, player.global_position.x)

	await _play_bubble(player_bubble, "mc", "I don't want you showing me that again.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "...You don't need to worry about that, mam.", false)
	await _play_bubble(player_bubble, "mc", "Hm?", false)

# ==========================================
# ENDING: MAYA RESIGNS
# ==========================================

func _ending_sequence() -> void:
	await get_tree().create_timer(0.5).timeout
	await _play_bubble(caretaker_bubble, "Caretaker", "...I'm resigning.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "I'm leaving by Thursday at the latest.", false)

	await _play_bubble(player_bubble, "mc", "Fine.", false)
	await _play_bubble(player_bubble, "mc", "I can handle myself.", false)

	# Maya walks to the door and fades out
	var door_node = get_node_or_null("Door/Door_Door")
	if door_node:
		await _sprite_walk(caretaker, door_node.global_position.x, 40.0)
		door_node.hide()

	var fade = create_tween()
	fade.tween_property(caretaker, "modulate:a", 0.0, 0.5)
	await fade.finished
	_hide_npc(caretaker)

	if door_node:
		door_node.show()

	await get_tree().create_timer(1.0).timeout
	await _play_bubble(player_bubble, "mc", "Did I make the right choice?", true)

	player.is_frozen = false
	InteractionManager.can_interact = true
	_is_cutscene_playing = false

	if end_phase_transition != null:
		TransitionManager.start(end_phase_transition)
	else:
		printerr("Forgot to slot in End Phase Transition data!")

# ==========================================
# HELPER FUNCTIONS
# ==========================================

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
		speed = 40.0
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
