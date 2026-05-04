extends Node2D

@onready var moeder = $Moeder
@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var player_bubble = $Player/SpeechBubble
@onready var moeder_bubble = $Moeder/SpeechBubble

@export var intro_dialog: DialogData
@export var scene_id: String = "matthijs_bedroom_day1"

var shake_strength: float = 0.0
var shake_fade: float = 5.0
var randomStrength: float = 30.0
var _skip_bubble = false

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

func _ready() -> void:
	DialogManager.line_changed.connect(_on_premise_line_changed)
	DialogManager.dialog_ended.connect(_on_premise_dialog_ended)
	if not QuestManager.was_intro_seen(scene_id):
		_play_premise()
	QuestManager.trigger_cutscene.connect(start_cutscene) 
	_hide_npc(moeder)

func _play_premise() -> void:
	player.is_frozen = true
	await get_tree().create_timer(1.0).timeout
	DialogManager.start(intro_dialog)
	QuestManager.mark_intro_done(scene_id)
	player.is_frozen = false

func start_cutscene(cutscene_id: String) -> void:
	if cutscene_id != scene_id: return
	InteractionManager.can_interact = false
	
	moeder.show()
	_mamma_face_player()
	
	shake_strength = randomStrength
	await get_tree().create_timer(1).timeout
	
	await _walk_player_to_moeder()
	
	await _play_bubble(moeder_bubble, "???", "Schatje...", false, "Sweetie...")
	await _play_bubble(moeder_bubble, "???", "Are you awake?", false)
	
	
	await _play_bubble(moeder_bubble, "???", "Liefje?", false, "Little treasure?")
	await get_tree().create_timer(0.5).timeout
	await _play_bubble(player_bubble, "mc", "The... warm lady from that picture?", true)
	await get_tree().create_timer(0.8).timeout
	await _play_bubble(player_bubble, "mc", "Mamma..? I'm- Matthijs' is sorry..", false)
	
	await _play_bubble(moeder_bubble, "Mamma", "Worry not, Schatje.", false, "Worry not, Sweetie.")
	await _play_bubble(moeder_bubble, "Mamma", "You just woke up.", false)
	await _play_bubble(moeder_bubble, "Mamma", "Have you not?", false)
	await _play_bubble(moeder_bubble, "Mamma", "It's time for afternoon tea.", false)
	await _play_bubble(moeder_bubble, "Mamma", "Father is waiting for you.", false)
	await _play_bubble(moeder_bubble, "Mamma", "Be sure to look presentable.", false)
	await _play_bubble(moeder_bubble, "Mamma", "verstaan?", false, "understand?  ")
	
	await _play_bubble(player_bubble, "mc", "Yes, Mamma.", false)
	var tween = create_tween()
	tween.tween_property(moeder, "modulate:a", 0.0, 1)
	await tween.finished
	_hide_npc(moeder)
	
	await get_tree().create_timer(1).timeout
	await _play_bubble(player_bubble, "mc", "That was involuntary.", true)
	await _play_bubble(player_bubble, "mc", "Seems like Matthijs is a good child.", false)
	await _play_bubble(player_bubble, "mc", "Especially to his Mamma", false)
	await _play_bubble(player_bubble, "mc", "..I should follow her.", false)
	player.is_frozen = false
	InteractionManager.can_interact = true
	
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/phase_2/day_1/day1_ruby_room.tscn" )

	
func _play_bubble(bubble_node, speaker_name, text_content, is_thought, translation: String = "") -> void:
	var data = DialogLine.new()
	data.text = text_content
	data.is_dialog_thought = is_thought
	data.speaker = speaker_name
	data.translation = translation
	
	bubble_node.show_line(data)
	await _wait_for_input(bubble_node)
	
	bubble_node.clear()
	
func _mamma_face_player():
	var mamma_sprite = moeder.get_node("AnimatedSprite2D") # Adjust path if needed
	if player.global_position.x < moeder.global_position.x:
		# Player is to the left, so Mamma flips left
		mamma_sprite.flip_h = true
	else:
		# Player is to the right, Mamma faces default (right)
		mamma_sprite.flip_h = false

func _walk_player_to_moeder() -> void:
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
	
	var walk_duration = 2
	var tween = create_tween()
	tween.tween_property(player, "global_position", target_pos, walk_duration)
	
	await tween.finished
	
	player_sprite.play("idle")
	
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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_skip_bubble = true

func _wait_for_input(bubble_node) -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			if bubble_node.is_typing():
				bubble_node.skip_typing()
			else:
				break
