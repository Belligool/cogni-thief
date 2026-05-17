extends Node2D

@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var player_bubble = $Player/SpeechBubble
@onready var desktop_bubble = $desktop/SpeechBubble 
@onready var initial_point = PlayerManager.get_total_points()


@export var intro_dialog: DialogData
@export var scene_id: String = "ruby_bedroom_day3"
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
	
	if cutscene_id == "ruby_bedroom_day3":
		await _cutscene_map["ruby_room_day3_after_premise"].call()
	elif cutscene_id == "aftermath_mom_conversation":
		if points_gained > 0:
			await _cutscene_map["ruby_room_day_3_aftermath_good"].call()
			_on_end_cutscene()
		elif points_gained == 0:
			await _cutscene_map["ruby_room_day_3_aftermath_neutral"].call()
			_on_end_cutscene()
		else:
			await _cutscene_map["ruby_room_day_3_aftermath_bad"].call()
			_on_end_cutscene()
			
func _ready() -> void:
	DialogManager.line_changed.connect(_on_premise_line_changed)
	DialogManager.dialog_ended.connect(_on_premise_dialog_ended)	
	_cutscene_map = {
		"ruby_room_day_3_aftermath_good": _ruby_room_day_3_aftermath_good,
		"ruby_room_day_3_aftermath_neutral": _ruby_room_day_3_aftermath_neutral,
		"ruby_room_day_3_aftermath_bad": _ruby_room_day_3_aftermath_bad,	
		"ruby_room_day3_after_premise": _ruby_room_day_3_after_premise,
	}
	QuestManager.trigger_cutscene.connect(start_cutscene)
	if not QuestManager.was_intro_seen(scene_id):
		await _play_premise()
	
func _play_premise() -> void:
	player.is_frozen = true
	await get_tree().create_timer(1.0).timeout
	
	var desktop = get_node("desktop")
	var interaction_area = desktop.get_node("InteractionArea")
	interaction_area.monitoring = false
	interaction_area.monitorable = false
	
	DialogManager.start(intro_dialog)
	QuestManager.mark_intro_done(scene_id)
	player.is_frozen = false
	
	print("DEBUG: Waiting for dialog_ended")
	await DialogManager.dialog_ended
	print("DEBUG: dialog_ended signal received")
	
	await get_tree().create_timer(0.5).timeout
	print("DEBUG: About to call start_auto_cutscene")
	desktop.start_auto_cutscene()
	print("DEBUG: start_auto_cutscene called")

func _ruby_room_day_3_after_premise():
	player.is_frozen = true
	player.animated_sprite.play("idle")
	
	InterludeManager.show_interlude(["I worked so hard to finish my tasks.","We able to finish this faster than I thought.", "I hope we can support each other"])
	await InterludeManager.interlude_finished
	await get_tree().create_timer(1).timeout
	
	await _play_bubble(player_bubble, "mc", "Wow...", false)
	await _play_bubble(player_bubble, "mc", "It's already 08.12 p.m.", false)
	await _play_bubble(player_bubble, "mc", "I can't believe I finished all my deadline this night", false)
	await _play_bubble(player_bubble, "mc", "I think I will have a rest for a while", false)
	
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Oh...mom it's calling me...", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(desktop_bubble, "desktop", "Ruby...Hi...", false)
	await _play_bubble(player_bubble, "mc", "Hi...mom!", false)
	
	await _play_bubble(desktop_bubble, "desktop", "How are you doing, sweety?", false)
	await _play_bubble(player_bubble, "mc", "I'm...fine...", false)
	
	await _play_bubble(desktop_bubble, "desktop", "Are you alright? You don't look so good, sweety", false)
	
	await _play_bubble(player_bubble, "mc", "You see umm...", false)
	await _play_bubble(player_bubble, "mc", "My boss offers me a better position...fine...", false)
	await _play_bubble(player_bubble, "mc", "but I have to move to Jakarta and stay there...", false)
	await _play_bubble(player_bubble, "mc", "What should I do?", false)
	await _play_bubble(player_bubble, "mc", "I cannot just leave my husband like this...", false)
	
	await _play_bubble(desktop_bubble, "desktop", "Hmm...", false)
	await _play_bubble(desktop_bubble, "desktop", "it’s alright, Ruby...", false)
	await _play_bubble(desktop_bubble, "desktop", "but ask your husband first...", false)
	await _play_bubble(desktop_bubble, "desktop", "He will be worried about you...", false)
	
	await _play_bubble(player_bubble, "mc", "Actually...", false)
	await _play_bubble(player_bubble, "mc", "I really want to stay away from him...", false)
	await _play_bubble(player_bubble, "mc", "Last night his face looked like he was drunk...", false)
	await _play_bubble(player_bubble, "mc", "He ran away...", false)
	await _play_bubble(player_bubble, "mc", "He didn’t even go home until now...", false)
	await get_tree().create_timer(0.5).timeout
	
	shake_strength = randomStrength
	await _play_bubble(desktop_bubble, "desktop", "WHAT???", false)
	await get_tree().create_timer(0.5).timeout
	
	shake_strength = randomStrength
	await _play_bubble(desktop_bubble, "desktop", "REALLY???", false)
	await get_tree().create_timer(0.5).timeout
	
	shake_strength = randomStrength
	await _play_bubble(desktop_bubble, "desktop", "OH MY GOD!", false)
	await get_tree().create_timer(1).timeout
	
	await _play_bubble(player_bubble, "mc", "That’s why...I want to run away from him...", false)
	await _play_bubble(player_bubble, "mc", "I can’t take this anymore...", false)
	await _play_bubble(player_bubble, "mc", "Mom...what should I do?", false)
	await get_tree().create_timer(1).timeout
	
	await _play_bubble(desktop_bubble, "desktop", "I think you should move out...", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Wh...What???", false)
	await _play_bubble(desktop_bubble, "desktop", "If that’s bothering you that much...you should go!", false)
	await _play_bubble(desktop_bubble, "desktop", "We still need your help, Ruby! We need to live!", false)
	
	await _play_bubble(desktop_bubble, "desktop", "If he doesn’t want to work together...then divorce him!", false)
	await _play_bubble(desktop_bubble, "desktop", "He promised that he will help us!", false)
	await _play_bubble(desktop_bubble, "desktop", "And now he betrayed you!", false)
	await _play_bubble(desktop_bubble, "desktop", "Just find another man that can help us!", false)
	
	await _play_bubble(player_bubble, "mc", "But...I’m pregnant now...", false)
	
	await _play_bubble(desktop_bubble, "desktop", "You can take care of yourself!", false)
	await _play_bubble(desktop_bubble, "desktop", "You’re already an adult!", false)
	await _play_bubble(desktop_bubble, "desktop", "You have priorities to do!If he doesn’t want to work together...then divorce him!", false)
	await _play_bubble(desktop_bubble, "desktop", "Just leave him alone!", false)
	
	await _play_bubble(player_bubble, "mc", "B...but...", false)
	
	await _play_bubble(desktop_bubble, "desktop", "Whatever!", false)
	await _play_bubble(desktop_bubble, "desktop", "I don’t want to hear about it ever again from you!", false)
	await _play_bubble(desktop_bubble, "desktop", "Just obey your mother!", false)
	
	await get_tree().create_timer(1).timeout
	
	desktop_bubble.hide()
	desktop_bubble.clear() 
	
	InterludeManager.show_interlude(["Mom just ignore what I want", "She obviously only care for herself", "She doesn't care about her child one bit", "But...", "No matter how it is", "I still have to make decision"])
	await InterludeManager.interlude_finished
	
	await _play_bubble(player_bubble, "mc", "I don't know what to do...", true)
	await _play_bubble(player_bubble, "mc", "Should I run away?", true)
	
	player_bubble.hide() 
	player_bubble.clear()
	
	player_bubble.set_process(false)
	
	var choices: Array[DialogChoice] = [
		DialogChoice.new(),  
		DialogChoice.new(),
		DialogChoice.new(),
	]
	
	choices[0].label = "I guess not..."
	choices[0].point_type = DialogChoice.PointType.GOOD

	choices[1].label = "Don't know..."
	choices[1].point_type = DialogChoice.PointType.NEUTRAL

	choices[2].label = "Of course..."
	choices[2].point_type = DialogChoice.PointType.BAD

	DialogManager.show_choices(choices)

	await DialogManager.choice_made
	player_bubble.set_process(true)
	start_cutscene("aftermath_mom_conversation")
	
func _ruby_room_day_3_aftermath_good():
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "I guess not...", true)
	
	await _play_bubble(player_bubble, "mc", "Whetever she love or she hate it", true)
	
	await _play_bubble(player_bubble, "mc","She cannot just leave her husband like this", true)
	await _play_bubble(player_bubble, "mc", "I better tell my mom and my boss to reject this", true)
	
	await _play_bubble(player_bubble, "mc", "Well then...I'm going to sleep", true)
	
	InterludeManager.show_interlude(["The next morning...", "I immediately text my boss and my mom", "I told them to not runaway from him", "I don’t think that’s the best idea to move out.","I will try to find my way to solve this without running away from him.", "I’ll probably tell my boss and my friends that I’m pregnant.", "I hope that they understand my condition.", "I believe that I can fix him someday..."])
	await InterludeManager.interlude_finished
	
func _ruby_room_day_3_aftermath_neutral():
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "Don't know...", true)
	await _play_bubble(player_bubble, "mc", "It doesn't matter...", true)
	await _play_bubble(player_bubble, "mc", "I still have work to do...", true)
	
	await _play_bubble(player_bubble, "mc", "There are still 5 deadline...", true)
	await _play_bubble(player_bubble, "mc", "Maybe I'll reconsider it later...", true)
	
	await _play_bubble(player_bubble, "mc", "Well then...I'm going to sleep", true)
	
	InterludeManager.show_interlude(["The next morning...", "I prepared things to go to work", "I still a lot of things to do...", "That's why...", "I just do whatever I can"])
	await InterludeManager.interlude_finished
	
func _ruby_room_day_3_aftermath_bad():
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "Of course..", true)
	await _play_bubble(player_bubble, "mc", "It's the only way to save herself", true)
	await _play_bubble(player_bubble, "mc", "Who cares about him?", true)
	await _play_bubble(player_bubble, "mc", "He's the one who destroy himself", true)
	await _play_bubble(player_bubble, "mc", "Be a better husband, my dearest", true)
	await _play_bubble(player_bubble, "mc", "I dont know you will survive this or not", true)
	await _play_bubble(player_bubble, "mc", "You just have to dig your own grave, my dearest", true)
	
	InterludeManager.show_interlude(["The next morning...", "I quickly ran away from her house", "I moved to the apartment without her husband knowing.", "I blocked her phone number from her husband", "There's no chance that he will screw my life"])
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
	await get_tree().create_timer(0.2).timeout
	QuestManager.set_day(1)
	QuestManager.set_phase(3)
	InteractionManager.can_interact = true
	TransitionManager.start(intro_narration)
