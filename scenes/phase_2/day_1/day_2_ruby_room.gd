extends Node2D

@onready var player = $Player
@onready var roby = $roby
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var player_bubble = $Player/SpeechBubble
@onready var desktop_bubble = $desktop/SpeechBubble
@onready var roby_bubble = $roby/SpeechBubble 
@onready var initial_point = PlayerManager.get_total_points()

@export var intro_dialog: DialogData
@export var scene_id: String = "ruby_bedroom_day2_part1"
@export var intro_narration: NarrationData

var shake_strength: float = 0.0
var shake_fade: float = 5.0
var randomStrength: float = 30.0
var _cutscene_map: Dictionary = {} 
var _skip_bubble = false 

func _process(delta: float) -> void:
	if QuestManager.was_cutscene_seen("ruby_bedroom_day2_part1"):
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
		player_bubble.clear()
		player_bubble.show_line(line)
	elif line.speaker == "desktop":
		desktop_bubble.clear()
		desktop_bubble.show_line(line)
	elif line.speaker == "roby":
		roby_bubble.clear()
		roby_bubble.show_line(line)

func _on_premise_dialog_ended(_npc_id: String) -> void:
	player_bubble.clear()

func start_cutscene(cutscene_id: String) -> void:
	var current_points = PlayerManager.get_total_points()
	var points_gained = current_points - initial_point
	
	if cutscene_id == "ruby_bedroom_day2_part1":
		await _cutscene_map["ruby_room_day2_part1_after_premise"].call()
	elif cutscene_id == "aftermath_chat_part1_conversation":
		if points_gained > 0:
			await _cutscene_map["ruby_room_day_2_part_1_aftermath_good"].call()
			_on_end_part1_cutscene()
		elif points_gained == 0:
			await _cutscene_map["ruby_room_day_2_part_1_aftermath_neutral"].call()
			_on_end_part1_cutscene()
		else:
			await _cutscene_map["ruby_room_day_2_part_1_aftermath_bad"].call()
			_on_end_part1_cutscene()
			
	elif cutscene_id == "ruby_bedroom_day2_part2":
		await _cutscene_map["ruby_room_day2_part2_after_part1"].call()
	elif cutscene_id == "aftermath_roby_part2_conversation":
		if points_gained > 0:
			await _cutscene_map["ruby_room_day_2_part_2_aftermath_good"].call()
			_on_end_part2_cutscene()
		elif points_gained == 0:
			await _cutscene_map["ruby_room_day_2_part_2_aftermath_neutral"].call()
			_on_end_part2_cutscene()
		else:
			await _cutscene_map["ruby_room_day_2_part_2_aftermath_bad"].call()
			_on_end_part2_cutscene()

func _ready() -> void:
	DialogManager.line_changed.connect(_on_premise_line_changed)
	DialogManager.dialog_ended.connect(_on_premise_dialog_ended)	
	
	_hide_npc(roby)
	
	_cutscene_map = {
		"ruby_room_day_2_part_1_aftermath_good": _ruby_room_day_2_part_1_aftermath_good,
		"ruby_room_day_2_part_1_aftermath_neutral": _ruby_room_day_2_part_1_aftermath_neutral,
		"ruby_room_day_2_part_1_aftermath_bad": _ruby_room_day_2_part_1_aftermath_bad,
		"ruby_room_day_2_part_2_aftermath_good": _ruby_room_day_2_part_2_aftermath_good,
		"ruby_room_day_2_part_2_aftermath_neutral": _ruby_room_day_2_part_2_aftermath_neutral,
		"ruby_room_day_2_part_2_aftermath_bad": _ruby_room_day_2_part_2_aftermath_bad,
		"ruby_room_day2_part1_after_premise": _ruby_room_day_2_part1_after_premise,
		"ruby_room_day2_part2_after_part1" : _ruby_room_day2_part2_after_part1,
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
	desktop.start_auto_cutscene(scene_id)
	print("DEBUG: start_auto_cutscene called")
	
func _ruby_room_day_2_part1_after_premise():
	player.is_frozen = true
	player.animated_sprite.play("idle")
	
	await get_tree().create_timer(1).timeout
	InterludeManager.show_interlude(["I don't know...", "What the hell is this?", "I just do my article", "I hope I can finish it"])
	await InterludeManager.interlude_finished
	await get_tree().create_timer(1).timeout

	await _play_bubble(player_bubble, "mc", "I’m hungry", false)
	await _play_bubble(player_bubble, "mc", "What time is it?", false)
	await get_tree().create_timer(0.5).timeout
	
	shake_strength = randomStrength
	await _play_bubble(player_bubble, "mc", "WHAT???", false)
	await get_tree().create_timer(0.5).timeout
	
	shake_strength = randomStrength
	await _play_bubble(player_bubble, "mc", "07.42 pm!!!", false)
	await _play_bubble(player_bubble, "mc", "Wait...Arya just messaged me...", false)
	await get_tree().create_timer(1).timeout
	
	
	shake_strength = randomStrength
	await _play_bubble(desktop_bubble, "desktop", "By! This is urgent!", false)
	await _play_bubble(desktop_bubble, "desktop", "Rasyid asked me to finish the article tomorrow morning", false)
	await _play_bubble(desktop_bubble, "desktop", "He said that he really needs the article to be published tomorrow at noon", false)
	await _play_bubble(desktop_bubble, "desktop", "Please By! Pretty please!", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Oh my god!", true)
	await _play_bubble(player_bubble, "mc", "How should i response this?", true)
	
	desktop_bubble.hide()
	desktop_bubble.clear() 
	
	player_bubble.hide() 
	player_bubble.clear()
	
	player_bubble.set_process(false)
	
	var choices: Array[DialogChoice] = [
		DialogChoice.new(),  
		DialogChoice.new(),
		DialogChoice.new(),
	]
	
	choices[0].label = "Hmm...Tomorrow morning..."
	choices[0].point_type = DialogChoice.PointType.GOOD

	choices[1].label = "Let see then..."
	choices[1].point_type = DialogChoice.PointType.NEUTRAL

	choices[2].label = "Really???"
	choices[2].point_type = DialogChoice.PointType.BAD

	DialogManager.show_choices(choices)

	await DialogManager.choice_made
	player_bubble.set_process(true)
	start_cutscene("aftermath_chat_part1_conversation")
	
func _ruby_room_day_2_part_1_aftermath_good():
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "Hmm...Tomorrow morning...", true)
	await _play_bubble(player_bubble, "mc", "Do I have time to finish it?", true)
	await _play_bubble(player_bubble, "mc", "I guess I can’t.", true)
	
	await _play_bubble(player_bubble, "mc", "I’m sorry, Arya", false)
	await _play_bubble(player_bubble, "mc", "It’s too much", false)
	await _play_bubble(player_bubble, "mc", "I still have other work to do", false)
	await _play_bubble(player_bubble, "mc", "How about tomorrow afternoon?", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(desktop_bubble, "desktop", "Wait...", false)
	await _play_bubble(desktop_bubble, "desktop", "That’s unusual from you", false)
	await _play_bubble(desktop_bubble, "desktop", "And it’s kinda unfortunate", false)
	await _play_bubble(desktop_bubble, "desktop", "Rasyid will pay us less than before", false)
	await _play_bubble(desktop_bubble, "desktop", "Well...", false)
	await _play_bubble(desktop_bubble, "desktop", "Fine then...you try to finish it ASAP...", false)
	await _play_bubble(desktop_bubble, "desktop", "Just let me know when it’s over.", false)
	
	await _play_bubble(player_bubble, "mc", "Alright...", false)
	await _play_bubble(player_bubble, "mc", "I'll finish it ASAP", false)

func _ruby_room_day_2_part_1_aftermath_neutral():
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "Let's see then...", true)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Alright...", false)
	await _play_bubble(player_bubble, "mc", "Later I’ll let you know when it’s over...", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(desktop_bubble, "desktop", "Okay.", false)
	await _play_bubble(desktop_bubble, "desktop", "Inform me when you're done", false)
	await get_tree().create_timer(0.5).timeout
	
func _ruby_room_day_2_part_1_aftermath_bad():
	player.is_frozen = true

	await _play_bubble(player_bubble, "mc", "Really???", false)
	
	shake_strength = randomStrength
	await _play_bubble(player_bubble, "mc", "THAT DOESNT MAKE ANY SENSE!!!", false)
	await _play_bubble(player_bubble, "mc", "THAT GUY SHOULD BE ROTTEN IN HELL!!!", false)
	await get_tree().create_timer(0.5).timeout
	
	shake_strength = randomStrength
	await _play_bubble(desktop_bubble, "desktop", "WAIT!!", false)
	await _play_bubble(desktop_bubble, "desktop", "THAT’S REALLY UNUSUAL FROM YOU!!!", false)
	await _play_bubble(desktop_bubble, "desktop", "WHAT’S GOING ON WITH YOU?", false)
	await _play_bubble(desktop_bubble, "desktop", "IT WAS RASYID WHO ASKED ME TO!!!", false)
	
	shake_strength = randomStrength
	await _play_bubble(player_bubble, "mc", "THAT RASYID!!!", false)
	await _play_bubble(player_bubble, "mc", "WHATEVER!!!", false)
	await _play_bubble(player_bubble, "mc", "I DON’T CARE!!!", false)
	await _play_bubble(player_bubble, "mc", "I WILL NEVER DO THIS EVER AGAIN!!!", false)
	
func _on_end_part1_cutscene():
	await get_tree().create_timer(1).timeout
	InterludeManager.show_interlude(["I have no choice then to do this article", "I have to do something about this", "This is just too much!", "Yesterday she had too much work!", "And now she has to do this too!", "What else could it be?"])
	await InterludeManager.interlude_finished	

	start_cutscene("ruby_bedroom_day2_part2")
	
func _ruby_room_day2_part2_after_part1():
	_show_npc(roby)
	initial_point = PlayerManager.get_total_points()
	
	await get_tree().process_frame	
	await get_tree().create_timer(1).timeout
	
	await _play_bubble(roby_bubble, "roby", "Ruby baby…", false)
	await _walk_sprite_to_player(player, -5)
	await get_tree().create_timer(1).timeout
	
	await _play_bubble(roby_bubble, "roby", "I’ve lost my money because I got robbed...", false)
	await _play_bubble(roby_bubble, "roby", "Can you give me some money, please?.", false)
	await _play_bubble(roby_bubble, "roby", "I haven’t eaten since morning...", false)
	await _play_bubble(roby_bubble, "roby", "I’ve lost my money because I got robbed...", false)
	await _play_bubble(roby_bubble, "roby", "Please, baby...", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Umm..who are you?", false)
	await _play_bubble(roby_bubble, "roby", "Huh! Do you not realize that I’m your husband?", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Is he really her husband?", true)
	await _play_bubble(player_bubble, "mc", "Why is he so different from before?", true)
	await _play_bubble(player_bubble, "mc", "Why is he kinda drunk and cranky?", true)
	await _play_bubble(player_bubble, "mc", "What should i do?", true)
	
	player_bubble.hide() 
	player_bubble.clear()
	player_bubble.set_process(false)
	var choices: Array[DialogChoice] = [
		DialogChoice.new(),  
		DialogChoice.new(),
		DialogChoice.new(),
	]
	
	choices[0].label = "You can have this...but..."
	choices[0].point_type = DialogChoice.PointType.GOOD

	choices[1].label = "Here..."
	choices[1].point_type = DialogChoice.PointType.NEUTRAL

	choices[2].label = "No Way!"
	choices[2].point_type = DialogChoice.PointType.BAD

	DialogManager.show_choices(choices)

	await DialogManager.choice_made
	player_bubble.set_process(true)
	start_cutscene("aftermath_roby_part2_conversation")
	
func _ruby_room_day_2_part_2_aftermath_good():
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "You can have this...but...", false)
	await _play_bubble(player_bubble, "mc", "You do whatever I tell you...", false)
	await _play_bubble(player_bubble, "mc", "You must stop drinking alcohol and sleep properly.", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(roby_bubble, "roby", "Wait...what’s wrong, baby?", false)
	await _play_bubble(roby_bubble, "roby", "I’m not drinking", false)
	await _play_bubble(roby_bubble, "roby", "I need your help, please.", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Are you really in debt because of gambling?", false)
	await _play_bubble(player_bubble, "mc", "Do you really go to work?", false)
	await _play_bubble(player_bubble, "mc", "Or are you just wandering around doing nothing and wasting money?", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(roby_bubble, "roby", "What are you talking about?", false)
	await _play_bubble(roby_bubble, "roby", "Of course I go to work!", false)
	await _play_bubble(roby_bubble, "roby", "I’m doing this for you!", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Hmm...then why does your face look weird?", false)
	await _play_bubble(player_bubble, "mc", "What have you done?", false)
	await _play_bubble(player_bubble, "mc", "A worker like me doesn't have a face like that", false)
	await _play_bubble(player_bubble, "mc", "It’s impossible for you to work", false)
	await get_tree().create_timer(0.5).timeout
	
	shake_strength = randomStrength
	await _play_bubble(roby_bubble, "roby", "Listen, you!", false)
	await _play_bubble(roby_bubble, "roby", "You have no respect for me!", false)
	await _play_bubble(roby_bubble, "roby", "I only need the money just for you too, you know", false)
	await _play_bubble(roby_bubble, "roby", "Is it hard to obey your husband?", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Do you even respect me?", false)
	await _play_bubble(player_bubble, "mc", "I've already worked too much for you!", false)
	
	shake_strength = randomStrength
	await _play_bubble(roby_bubble, "roby", "GIVE ME THE MONEY NOW!!!", false)
	await get_tree().create_timer(0.5).timeout
	
	await _play_bubble(player_bubble, "mc", "Please, don’t!", false)
	
	shake_strength = randomStrength
	InterludeManager.show_interlude(["He quickly punched my stomach...", 
	"He punched my face...", 
	"He truly made domestic violence against me..."])
	await InterludeManager.interlude_finished
	await get_tree().create_timer(1).timeout
	
	shake_strength = randomStrength
	await _play_bubble(roby_bubble, "roby", "THAT’S WHAT YOU GET FOR OPPOSING YOUR HUSBAND!!!", false)
	await _play_bubble(roby_bubble, "roby", "REMEMBER, YOU! ONE DAY YOU’LL REGRET THIS!!!", false)
	await _play_bubble(roby_bubble, "roby", "IF YOU DARE! YOU’RE DIG YOUR OWN GRAVE! GOT IT!", false)
	await get_tree().create_timer(1).timeout

func _ruby_room_day_2_part_2_aftermath_neutral():
	player.is_frozen = true
	await _play_bubble(player_bubble, "mc", "Here...just make sure you won’t lose it again...please...", false)
	await _play_bubble(roby_bubble, "roby", "Thank you, my lovely wife...", false)
	await _play_bubble(player_bubble, "mc", "Wait...where are you going?", false)
	await _play_bubble(roby_bubble, "roby", "Oh...I’ll go buy some food...", false)
	await _play_bubble(player_bubble, "mc", "But it’s almost midnight...", false)
	await _play_bubble(roby_bubble, "roby", "Don’t you worry...I know you must be hungry...", false)
	await _play_bubble(player_bubble, "mc", "Really? Are you sure...", false)
	await _play_bubble(roby_bubble, "roby", "Of course! I won’t even dare to upset you...", false)
	
	await _play_bubble(roby_bubble, "roby", "Alright, alright...I’ll be going now...", false)
	
	await _play_bubble(roby_bubble, "roby", "Be Careful, Ruby baby...", false)
	await get_tree().create_timer(1).timeout
	
	
	InterludeManager.show_interlude(["He just ran away...", 
	"He doesn't care one bit about her...", 
	"...",
	"I don't know what to say..."])
	await InterludeManager.interlude_finished
	_hide_npc(roby)
	await get_tree().create_timer(1).timeout
	
	await _play_bubble(player_bubble, "mc", "That’s kinda odd...", true)
	await _play_bubble(player_bubble, "mc", "Is he really buying dinner?", true)
	await get_tree().create_timer(1).timeout

func _ruby_room_day_2_part_2_aftermath_bad():
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "No Way!", false)
	
	shake_strength = randomStrength
	await _play_bubble(player_bubble, "mc", "WHAT’S THE MEANING OF THIS!!!", false)
	await _play_bubble(player_bubble, "mc", "AREN’T YOU SUPPOSE TO GIVE ME MONEY!!!", false)
	await get_tree().create_timer(0.5).timeout
	
	shake_strength = randomStrength
	await _play_bubble(roby_bubble, "roby", "Hey! What’s the meaning of this?", false)
	await _play_bubble(roby_bubble, "roby", "Why are you suddenly against your husband?", false)
	await get_tree().create_timer(0.5).timeout
	
	shake_strength = randomStrength
	await _play_bubble(player_bubble, "mc", "YOU'RE COMPLETELY USELESS!!!", false)
	await _play_bubble(player_bubble, "mc", "YOU SHOULD BE A PROVIDER HUSBAND!!!", false)
	await get_tree().create_timer(0.5).timeout
	
	shake_strength = randomStrength
	await _play_bubble(roby_bubble, "roby", "HEY! DON’T YOU DARE SAY THAT IN FRONT OF ME!!!", false)
	
	shake_strength = randomStrength
	await _play_bubble(player_bubble, "mc", "EARN YOUR MONEY YOURSELF!!!", false)
	await _play_bubble(player_bubble, "mc", "YOU SHOULD BE A PROVIDER LIKE OTHER HUSBAND!!!", false)
	await get_tree().create_timer(0.5).timeout
	
	shake_strength = randomStrength
	await _play_bubble(roby_bubble, "roby", "DAMN YOU!!!", false)
	
	shake_strength = randomStrength
	InterludeManager.show_interlude(["THAT’S WHAT YOU GET!", 
	"TAKE THIS!!!", 
	"TAKE THIS AGAIN!!!",
	"TAKE THIS AGAIN!!!"])
	await InterludeManager.interlude_finished
	await get_tree().create_timer(1).timeout
	
	shake_strength = randomStrength
	await _play_bubble(roby_bubble, "roby", "IF YOU DARE MESSING AROUND WITH ME!!!", false)
	await _play_bubble(roby_bubble, "roby", "YOU’LL GONNA REGRET IT!!!", false)
	await _play_bubble(roby_bubble, "roby", "MARK MY WORD!!!", false)
	await get_tree().create_timer(1).timeout            
	
func _on_end_part2_cutscene():
	QuestManager.set_day(3)
	InteractionManager.can_interact = true
	TransitionManager.start(intro_narration)

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

func _walk_sprite_to_player(sprite, distance: float) -> void:
	var animated_sprite = sprite.get_node("AnimatedSprite2D")
	
	var target_pos = player.global_position
	if sprite.global_position.x < player.global_position.x: 
		target_pos.x -= distance
		animated_sprite.flip_h = false
	else:
		target_pos.x += distance
		animated_sprite.flip_h = true 
		
	animated_sprite.play("walk")
	
	var speed = 50.0  # adjust to match your walk animation speed
	var d = abs(sprite.global_position.x - distance)
	var walk_duration = d / speed
	
	var tween = create_tween()
	tween.tween_property(sprite, "global_position", target_pos, walk_duration)
	
	await tween.finished
	
	animated_sprite.play("idle")

func _sprite_face(sprite, pos: float):
	var animated_sprite = sprite.get_node("AnimatedSprite2D") # Adjust path if needed
	if sprite.global_position.x < pos:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true

func _sprite_walk(sprite, dest: float, speed: float = 0.0) -> void:
	var animated_sprite = sprite.get_node("AnimatedSprite2D")
	if sprite.global_position.x < dest:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
		
	animated_sprite.play("walk")

	if speed == 0:
		speed = 40.0  # adjust to match your walk animation speed
	var distance = abs(sprite.global_position.x - dest)
	var walk_duration = distance / speed
	
	var tween = create_tween()
	tween.tween_property(sprite, "global_position:x", dest, walk_duration)

	await tween.finished
	animated_sprite.play("idle")
	
func _sprite_facing_player(sprite):
	var animated_sprite = sprite.get_node("AnimatedSprite2D") # Adjust path if needed
	if player.global_position.x < sprite.global_position.x:
		# Player is to the left, so Mamma flips left
		animated_sprite.flip_h = true
	else:
		# Player is to the right, Mamma faces default (right)
		animated_sprite.flip_h = false
		
func _hide_npc(npc: Node2D) -> void:
	npc.hide()
	# hide interaction area so player can't interact with hidden NPC
	var interaction = npc.get_node_or_null("NpcInteractionArea")
	if interaction:
		interaction.monitoring = false
		interaction.monitorable = false

func _show_npc(npc: Node2D) -> void:
	npc.show()
	
	# re-enable interaction area
	var interaction = npc.get_node_or_null("NpcInteractionArea")
	if interaction:
		interaction.monitoring = true
		interaction.monitorable = true
