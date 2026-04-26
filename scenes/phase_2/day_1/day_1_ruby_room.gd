extends Node2D

@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var player_bubble = $Player/SpeechBubble

@export var intro_dialog: DialogData
@export var scene_id: String = "ruby_bedroom_day1"

var shake_strength: float = 0.0
var shake_fade: float = 5.0
var randomStrength: float = 30.0

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

func _play_premise() -> void:
	player.is_frozen = true
	await get_tree().create_timer(1.0).timeout
	DialogManager.start(intro_dialog)
	QuestManager.mark_intro_done(scene_id)
	player.is_frozen = false

func start_cutscene(cutscene_id: String) -> void:
	if cutscene_id != scene_id: return
	
	shake_strength = randomStrength
	
	await get_tree().create_timer(0.5).timeout
	await _play_bubble(player_bubble, "mc", "The... warm lady from that picture?", true)
	await get_tree().create_timer(0.8).timeout
	await _play_bubble(player_bubble, "mc", "Mamma..? I'm- Matthijs' is sorry..", false)
		
	await _play_bubble(player_bubble, "mc", "Yes, Mamma.", false)
	var tween = create_tween()
	await tween.finished
	
	await get_tree().create_timer(1).timeout
	await _play_bubble(player_bubble, "mc", "That was involuntary.", true)
	await _play_bubble(player_bubble, "mc", "Seems like Matthijs is a good child.", false)
	await _play_bubble(player_bubble, "mc", "Especially to his Mamma", false)
	await _play_bubble(player_bubble, "mc", "..I should follow her.", false)
	player.is_frozen = false
	
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/phase_2/day_1/day1_ruby_room.tscn" )

	
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
