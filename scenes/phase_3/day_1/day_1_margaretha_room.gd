extends Node2D

@onready var caretaker = $caretaker
@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var player_bubble = $Player/SpeechBubble
@onready var caretaker_bubble = $caretaker/SpeechBubble


@export var intro_dialog: DialogData
@export var scene_id: String = "margaretha_room_day1"

var shake_strength: float = 0.0
var shake_fade: float = 5.0
var randomStrength: float = 30.0
var _skip_bubble = false
var _is_cutscene_playing := false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	caretaker.visible = false
	caretaker.process_mode = Node.PROCESS_MODE_DISABLED
	QuestManager.trigger_flag.connect(_on_flag_triggered)
	if QuestManager.is_flag_active("caretaker_spawned"):
		caretaker.visible = true
		caretaker.process_mode = Node.PROCESS_MODE_INHERIT
	pass # Replace with function body.

func _play_bubble(bubble_node, speaker_name, text_content, is_thought, translation: String = "") -> void:
	var data = DialogLine.new()
	data.text = text_content
	data.is_dialog_thought = is_thought
	data.speaker = speaker_name
	data.translation = translation
	
	bubble_node.show_line(data)
	await _wait_for_input(bubble_node)
	
	bubble_node.clear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		camera.offset = initialPos + _shake_camera()
	else:
		camera.offset = initialPos

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_skip_bubble = true

func _on_flag_triggered(flag: String):
	if flag == "caretaker_spawned":
		caretaker.visible = true
		caretaker.process_mode = Node.PROCESS_MODE_INHERIT
		_start_caretaker_cutscene()
		

func _start_caretaker_cutscene() -> void:
	if _is_cutscene_playing:
		return
	_is_cutscene_playing = true
	InteractionManager.can_interact = false
	player.is_frozen = true
	caretaker.visible = true
	caretaker.process_mode = Node.PROCESS_MODE_INHERIT
	await get_tree().create_timer(0.8).timeout
	shake_strength = randomStrength
	await _walk_player_to_caretaker()
	await _play_bubble(caretaker_bubble, "???", "You really shouldn't touch that.", false)
	await _play_bubble(player_bubble, "mc", "...!", true)
	await _play_bubble(player_bubble, "mc", "I didn't even hear her come in.", true)
	await _play_bubble(caretaker_bubble, "Caretaker", "Curiosity is dangerous in this house.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Especially that cabinet.", false)

	await get_tree().create_timer(0.8).timeout

	await _play_bubble(player_bubble, "mc", "...Who are you?", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "Just someone keeping things in order.", false)
	await _play_bubble(caretaker_bubble, "Caretaker", "You should go downstairs.", false)

	# Fade caretaker out
	var tween = create_tween()
	tween.tween_property(caretaker, "modulate:a", 0.0, 1.0)

	await tween.finished

	_hide_npc(caretaker)

	player.is_frozen = false
	InteractionManager.can_interact = true

	_is_cutscene_playing = false

func _hide_npc(npc: Node2D) -> void:
	npc.hide()
	# hide interaction area so player can't interact with hidden NPC
	var interaction = npc.get_node_or_null("NpcInteractionArea")
	if interaction:
		interaction.monitoring = false
		interaction.monitorable = false

func _shake_camera() -> Vector2:
	var rng = RandomNumberGenerator.new()
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func _walk_player_to_caretaker() -> void:
	var player_sprite = player.get_node("AnimatedSprite2D")
	
	player.is_frozen = true
	
	var target_pos = caretaker.global_position
	if player.global_position.x < caretaker.global_position.x:
		target_pos.x -= 40
		player_sprite.flip_h = false
	else:
		target_pos.x += 40
		player_sprite.flip_h = true
		
	player_sprite.play("walk")
	
	var walk_duration = 2
	var tween = create_tween()
	tween.tween_property(player, "global_position", target_pos, walk_duration)
	
	await tween.finished
	
	player_sprite.play("idle")

func _wait_for_input(bubble_node) -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			if bubble_node.is_typing():
				bubble_node.skip_typing()
			else:
				break
