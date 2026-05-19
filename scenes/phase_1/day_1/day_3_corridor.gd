extends Node2D

@onready var moeder = $Moeder
@onready var player = $Player
@onready var njai1 = $njai1
@onready var njai2 = $njai2
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var initialPlayerPos: Vector2 = Vector2.ZERO
@onready var moeder_bubble = $Moeder/SpeechBubble
@onready var player_bubble = $Player/SpeechBubble
@onready var njai1_bubble = $njai1/SpeechBubble
@onready var njai2_bubble = $njai2/SpeechBubble
@onready var initial_point = PlayerManager.get_total_points()

@export var intro_dialog: DialogData
@export var scene_id: String = "corridor_day3"
@export var intro_narration_good: NarrationData
@export var intro_narration_neutral: NarrationData
@export var intro_narration_bad: NarrationData
 
var shake_strength: float = 0.0
var player_shake_strength: float = 0.0
var shake_fade: float = 5.0
var randomStrength: float = 30.0
var _cutscene_map: Dictionary = {}
var _player_is_shaking: bool = false
var points_gained: float = 0.0

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		camera.offset = initialPos + _shake_camera()
	else:
		camera.offset = initialPos 
	
	if player_shake_strength > 0:
		player_shake_strength  = lerpf(player_shake_strength, 0, shake_fade * delta)
		player.position = initialPlayerPos + _shake_player()
	else:
		if _player_is_shaking:
			print("stop shaking")
			player.position = initialPlayerPos
			_player_is_shaking = false
			
	if QuestManager.was_cutscene_seen("njai_talking_about_mother_day3_phase1"):
		pass
	else:
		#print(QuestManager._completed_cutscenes)
		var dist = abs(player.global_position.x - njai2.global_position.x)
		if dist < 20:
			# We just notify the manager; the manager decides if the quest/cutscene should fire
			QuestManager.notify_proximity("njai")
		
func start_player_shake(strength: float = 5.0) -> void:
	initialPlayerPos = player.position
	player_shake_strength = strength
	_player_is_shaking = true
	
func _ready() -> void:
	_sprite_face(njai2, 17.0)
	DialogManager.line_changed.connect(_on_premise_line_changed)
	DialogManager.dialog_ended.connect(_on_premise_dialog_ended)
	QuestManager.trigger_cutscene.connect(start_cutscene) 
	_cutscene_map = {
		"matthijs_corridor_day_3_aftermath_good": _matthijs_corridor_day_3_aftermath_good,
		"matthijs_corridor_day_3_aftermath_neutral": _matthijs_corridor_day_3_aftermath_neutral,
		"matthijs_corridor_day_3_aftermath_bad": _matthijs_corridor_day_3_aftermath_bad,
		"matthijs_corridor_day3_after_premise": matthijs_corridor_day3_after_premise
	}
	
	if not QuestManager.was_intro_seen(scene_id):
		_play_premise()
	moeder.show()
	var tween = create_tween()
	tween.tween_property(moeder, "modulate:a", 0.0, 0.01)
	await tween.finished
	

func start_cutscene(cutscene_id: String) -> void:
	var current_points = PlayerManager.get_total_points()
	points_gained = current_points - initial_point
	
	if cutscene_id == "njai_talking_about_mother_day3_phase1":
		await _cutscene_map["matthijs_corridor_day3_after_premise"].call()
	elif cutscene_id == "aftermath_njai_conversation":
		if points_gained > 0:
			await _cutscene_map["matthijs_corridor_day_3_aftermath_good"].call()
			_on_end_cutscene()
		elif points_gained == 0:
			await _cutscene_map["matthijs_corridor_day_3_aftermath_neutral"].call()
			_on_end_cutscene()
		else:
			await _cutscene_map["matthijs_corridor_day_3_aftermath_bad"].call()
			_on_end_cutscene()
	
func _matthijs_corridor_day_3_aftermath_good(): 
	await _play_bubble(player_bubble, "mc", "Take deep breaths, Matthijs..", true)
	await _play_bubble(player_bubble, "mc", "Take deep breaths..", true)
	await _play_bubble(player_bubble, "mc", "Don’t go there..", true)
	await _play_bubble(player_bubble, "mc", " Calm down.", true)
	await _play_bubble(player_bubble, "mc", "Should go to my room…", true)
	await _play_bubble(player_bubble, "mc", "Mamma is not my real Mama", true)
	await _play_bubble(player_bubble, "mc", " but she’s always nice. And this body…", true)

	await _sprite_walk(player, -52.0, 20)
	player.animated_sprite.play("idle")
	initialPlayerPos = player.position

	InterludeManager.show_interlude(["I tried to hold back my bubbling anger as I went past those people",
	" letting them know of my arrival as I went to my room."
	])
	await InterludeManager.interlude_finished
	_hide_npc(njai1)
	_hide_npc(njai2)
	moeder.show()
	var tween = create_tween()
	tween.tween_property(moeder, "modulate:a", 1.0, 0.01)
	await _sprite_walk(player, moeder.global_position.x + 30, 20)
	initialPlayerPos = player.position
	player.animated_sprite.play("idle")

	await _play_bubble(moeder_bubble, "moeder", "Is the kaasstengels not to your liking, Schatje?", false, "Is the kaasstengels not to your liking, Darling?")
	await _play_bubble(moeder_bubble, "moeder", "You merely ate a few. Does your tummy hurt?", false)
	_sprite_face(player, moeder.global_position.x)
	await _play_bubble(player_bubble, "mc", "No, Mamma.", false)
	await _play_bubble(player_bubble, "mc", "...", false)
	await _play_bubble(player_bubble, "mc", "Mamma, can Matthijs ask you a question?", false)

	await _play_bubble(moeder_bubble, "moeder", "Natuurlijk! Anything!", false, "Ofcourse! Anything!")
	await _play_bubble(player_bubble, "mc", "Is it true Matthijs should’ve had a baby brother?", false)
	await _play_bubble(moeder_bubble, "moeder", "...", false)
	await _play_bubble(player_bubble, "mc", "Mamma went quiet. Too quiet.", true)
	await _play_bubble(player_bubble, "mc", "Mad? Did I say something wrong?", true)
	await _play_bubble(moeder_bubble, "moeder", "Yes, Matthijs. You should’ve had a little brother.", false)
	await _play_bubble(moeder_bubble, "moeder", "But mistakes can happen.", false)
	await _play_bubble(moeder_bubble, "moeder", "Even when your little brother is still inside Mamma’s tummy", false)
	await _play_bubble(player_bubble, "mc", "..Is Mamma feeling fine?", false)
	await _play_bubble(moeder_bubble, "moeder", "Yes, Mamma is fine, Schatje.", false, "Yes, Mamma is fine, Darling.")
	await _play_bubble(moeder_bubble, "moeder", "Mamma has Matthijs, Mamma has Papa.", false)
	await _play_bubble(player_bubble, "mc", "Mamma is lying..", true)
	await _play_bubble(player_bubble, "mc", "How can I make her feel better?", true)
	await _play_bubble(player_bubble, "mc", "Mamma, want to take a walk after tea?", false)
	await _play_bubble(player_bubble, "mc", "My friends were also talking about a new play in the schouwburg.", false, "My friends were also talking about a new play in the theatre.")
	await _play_bubble(moeder_bubble, "moeder", "Our sweet Schatje… (soft laugh)", false, "Our sweet Darling… (soft laugh)")
	await _play_bubble(moeder_bubble, "moeder", "Let’s go for a walk", false)
	await _play_bubble(moeder_bubble, "moeder", "A breath of fresh air would be delightful", false)
	await _play_bubble(moeder_bubble, "moeder", "Finish your tea and eat more kaasstengels, ja?", false, "Finish your tea and eat more kaasstengels, yes?")
	await _play_bubble(player_bubble, "mc", "Yes, Mamma.", false)

func _matthijs_corridor_day_3_aftermath_neutral():
	await _play_bubble(player_bubble, "mc", "What do you mean?", false)
	_sprite_face(njai1, player.global_position.x)
	_sprite_face(njai2, player.global_position.x)
	await _play_bubble(njai1_bubble, "njai1", "Jongeheer? Our apologies!", false, "Young master? Our apologies!")
	await _play_bubble(njai1_bubble, "njai1", "Truly, truly we meant nothing bad. Mevrouw-", false, "Truly, truly we meant nothing bad. Madam-")
	await _play_bubble(player_bubble, "mc", "What do you mean I should’ve had a younger sibling?", false)
	await _play_bubble(player_bubble, "mc", "What’s a miscarriage?", false)
	await _play_bubble(njai2_bubble, "njai2", "Jongeheer, Mevrouw was with child when you were much younger.", false, "Young master, Madam was with child when you were much younger.")
	await _play_bubble(njai2_bubble, "njai2", "Back then, Mevrouw always went with Mijnheer everywhere. But-", false, "Back then, Madam always went with Sir everywhere. But-")
	
	var tween = create_tween()
	tween.tween_property(moeder, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	_sprite_face(njai1, moeder.global_position.x)
	_sprite_face(njai2, moeder.global_position.x)
	await _play_bubble(player_bubble, "mc", "Why stop? Continue.", false)
	await _play_bubble(moeder_bubble, "moeder", "Explain what, Schatje?", false, "Explain what, Darling?")
	await _play_bubble(player_bubble, "mc", "Mamma?", false)
	await _play_bubble(player_bubble, "mc", "..It’s a secret.", false)
	await _play_bubble(moeder_bubble, "moeder", "A secret?", false)
	await _play_bubble(moeder_bubble, "moeder", "You shouldn’t hide something from Mamma, Schatje.", false, "You shouldn’t hide something from Mamma, Darling.")
	await _play_bubble(moeder_bubble, "moeder", "What was it?", false)
	await _play_bubble(player_bubble, "mc", "Matthijs will tell Mamma when the tea is ready.", false)
	await _play_bubble(moeder_bubble, "moeder", "It seems like our Schatje is pretty stubborn today.", false, "It seems like our Darling is pretty stubborn today.")
	await _play_bubble(moeder_bubble, "moeder", "Very well. Mamma’s certain tea and the kaasstengels Mamma baked should be ready soon.", false)
	await _play_bubble(moeder_bubble, "moeder", "Be a good boy for Mamma and wait for mama in the dining table, ja?", false, "Be a good boy for Mamma and mama in the dining table, ja?")
	await _play_bubble(player_bubble, "mc", "Yes, Mamma.", false)
	
	await _sprite_walk(player, 87.0, 20)
	initialPlayerPos = player.position
	player.animated_sprite.play("idle")
	await _sprite_walk(njai1, -105.0, 30)
	await _sprite_walk(njai2, -105.0, 35)
	await _sprite_face(player, moeder.global_position.x)


	await get_tree().create_timer(1).timeout
	await _sprite_walk(moeder, 71.0, 20)
	await get_tree().create_timer(1.0).timeout

	await _play_bubble(moeder_bubble, "moeder", "Zo, what is this little secret you want to tell, Schatje?", false, "So, what is this little secret you want to tell, Darling?")
	await _play_bubble(player_bubble, "mc", "Ma, is it true that.. ", false)
	await _play_bubble(player_bubble, "mc", "Matthijs should’ve had a little sibling? ", false)
	await _play_bubble(moeder_bubble, "moeder", "..Yes, Schatje.", false, "..Yes, Darlimg.")
	await _play_bubble(player_bubble, "mc", "What happened, Ma? ", false)
	await _play_bubble(moeder_bubble, "moeder", "Accidents.. Can happen, Schatje.", false, "Accidents.. Can happen, Darling.")
	await _play_bubble(moeder_bubble, "moeder", "And back then, it cost your little brother.", false)
	await _play_bubble(player_bubble, "mc", "Matthijs could’ve had a brother?", false)
	await _play_bubble(moeder_bubble, "moeder", "Yes, Schatje.", false, "Yes, Darling.")
	await _play_bubble(moeder_bubble, "moeder", "The physician told Ma and Pa that he’s a boy.", false)
	await _play_bubble(player_bubble, "mc", "Mamma went silent after the talk.", true)
	await _play_bubble(player_bubble, "mc", "She usually asked about my day, about school.", true)
	await _play_bubble(player_bubble, "mc", " What should I do?", true)
	await _play_bubble(moeder_bubble, "moeder", "Schatje, today’s weather seemed suitable for a walk, ja?", false, "Darling, today’s weather seemed suitable for a walk, ja?")
	await _play_bubble(moeder_bubble, "moeder", "Let’s go for a walk after tea time.", false)
	await _play_bubble(player_bubble, "mc", "Yes, Mamma.", false)
	await _sprite_walk(moeder, 200.0, 20)

func _matthijs_corridor_day_3_aftermath_bad():
	await _play_bubble(player_bubble, "mc", "The nerve…", true)
	await _play_bubble(player_bubble, "mc", "You inlanders have the nerve to talk about Mamma.", false)
	_sprite_face(njai1, player.global_position.x)
	_sprite_face(njai2, player.global_position.x)
	await _play_bubble(player_bubble, "mc", "In our house, no less.", false)
	await _play_bubble(player_bubble, "mc", "Have you no shame?", false)

	await _play_bubble(njai1_bubble, "njai1", "Jongeheer? Our apologies!", false, "Young master? Our apologies!")
	await _play_bubble(njai1_bubble, "njai1", "Truly, truly we meant nothing bad. Mevrouw-", false, "Truly, truly we meant nothing bad. Madam-")

	await _play_bubble(player_bubble, "mc", "I’m not interested in any of your reasons.", false)
	await _play_bubble(player_bubble, "mc", "Is it that hard for you inlanders to keep your mouth shut?", false)
	await _play_bubble(njai2_bubble, "njai2", "Jongeheer, please calm down. We-", false, "Young master, please calm down. We-")
	await _play_bubble(player_bubble, "mc", "Calm down? When you talked about my Mamma behind her back?", false)
	await _play_bubble(player_bubble, "mc", "When our family give you work?", false)
	shake_strength = randomStrength
	await _play_bubble(player_bubble, "mc", "Shame on you, inlanders!  (throws whatever is nearby)", false)
	var tween = create_tween()
	tween.tween_property(moeder, "modulate:a", 1.0, 0.5)
	await tween.finished
	await _play_bubble(moeder_bubble, "moeder", "Schatje, what is happening?", false, "Darling, what is happening?")
	await _play_bubble(moeder_bubble, "moeder", "...", false)
	await _play_bubble(player_bubble, "mc", "The spillage. Oh no..", true)
	await _play_bubble(player_bubble, "mc", "Mamma looks angry. Scary..", true)
	await _play_bubble(moeder_bubble, "moeder", "Matthijs. Go to your room. Now.", false)
	await _play_bubble(player_bubble, "mc", "But Mamma-", false)
	await _play_bubble(moeder_bubble, "moeder", "Your. Room. NOW.", false)
	await _play_bubble(player_bubble, "mc", "Yes, Mamma", false)
	await _sprite_walk(player, -52.0, 20)
	player.animated_sprite.play("idle")
	initialPlayerPos = player.position
	
	InterludeManager.show_interlude(["I can only follow Mamma’s orders",
	"until she finally","finally called me to have some tea."
	])
	await InterludeManager.interlude_finished
	_hide_npc(njai1)
	_hide_npc(njai2)
	moeder.show()
	await _sprite_walk(player, moeder.global_position.x + 30, 20)
	initialPlayerPos = player.position
	player.animated_sprite.play("idle")
	_sprite_face(player, moeder.global_position.x)

	await _play_bubble(player_bubble, "mc", "...", false)
	await _play_bubble(moeder_bubble, "moeder", "...", false)
	await _play_bubble(moeder_bubble, "moeder", "Why did Matthijs throw Mamma’s vase?", false)
	await _play_bubble(moeder_bubble, "moeder", "The Matthijs Mamma knew wouldn’t be so rash. What exactly happened?", false)
	await _play_bubble(player_bubble, "mc", "..Those Baboes.. were talking about Mamma.", false)
	await _play_bubble(player_bubble, "mc", "Saying how you.. Had a miscarriage.", false)
	await _play_bubble(player_bubble, "mc", "How it affects the way Ma and Pa treated Matthijs.", false)
	await _play_bubble(player_bubble, "mc", "They, they shouldn’t have done that! Especially not in our house!", false)
	await _play_bubble(player_bubble, "mc", "I know I shouldn’t be this angry", true)
	await _play_bubble(player_bubble, "mc", "Especially when Ma isn’t my real Mamma. And I’m not Matthijs.", true)
	await _play_bubble(player_bubble, "mc", "But this body.. And", true)
	await _play_bubble(player_bubble, "mc", " and how can I not get angry when Ma has been nothing but nice to me? To all of us, even those… those ungrateful inlanders!", true)
	await _play_bubble(moeder_bubble, "moeder", "Schatje, listen to Mamma carefully.", false, "Darling, listen to Mamma carefully.")
	await _play_bubble(moeder_bubble, "moeder", "Yes, they did wrong. But you shouldn’t have broken Mamma’s vase, or anything when you’re mad, ja?", false, "Yes, they did wrong. But you shouldn’t have broken Mamma’s vase, or anything when you’re mad, yes?")
	await _play_bubble(player_bubble, "mc", "Yes, Mamma.. Matthijs is sorry..", false)
	await _play_bubble(moeder_bubble, "moeder", "There’s no need to worry, Schatje.", false, "There’s no need to worry, Darling.")
	await _play_bubble(moeder_bubble, "moeder", "Mamma will take care of it.", false)
	await _play_bubble(moeder_bubble, "moeder", "There’s no need to feel so down upon this.", false)
	await _play_bubble(moeder_bubble, "moeder", " Start eating your kaasstengels, ja?", false, " Start eating your kaasstengels, yes?")
	await _play_bubble(moeder_bubble, "moeder", "Let’s take a walk after this to calm you down.", false)
	await _play_bubble(moeder_bubble, "moeder", "The weather is suitable for a nice walk today.", false)
	await _play_bubble(player_bubble, "mc", "Yes, Mamma.", false)
	await _sprite_walk(moeder, 200.0, 20)

func matthijs_corridor_day3_after_premise():
	player.is_frozen = true
	player.animated_sprite.play("idle")
	
	await _play_bubble(njai1_bubble, "njai1", "Mbok, why does Mijnheer and Mevrouw pamper Young Master so much?", false, "Mbok, why does Sir and Madam pamper Jongeheer so much?")
	await _play_bubble(njai2_bubble, "njai2", "You didn’t know?", false)
	await _play_bubble(njai2_bubble, "njai2", "Mevrouw had a miscarriage a couple years back.", false, "Madam had a miscarriage a couple years back.")

	await _play_bubble(player_bubble, "mc", "How unwise.", true)
	await _play_bubble(player_bubble, "mc", " They’re talking about Ma?", true)
	await _play_bubble(player_bubble, "mc", "Are they foolish?", true)
	await _play_bubble(player_bubble, "mc", "And a miscarriage? What is that?", true)

	await _play_bubble(njai1_bubble, "njai1", "A miscarriage?", false)
	start_player_shake(5.0)
	await _play_bubble(njai1_bubble, "njai1", "So Jongeheer should’ve had a sibling?", false, "So Young Master should’ve had a sibling?")
	await _play_bubble(njai1_bubble, "njai1", "Is that why Mevrouw  doesn’t follow Mijnheer to work?", false, "Is that why Madam  doesn’t follow Sir to work?")
	var choices: Array[DialogChoice] = [
		DialogChoice.new(),  
		DialogChoice.new(),
		DialogChoice.new(),
	]
	choices[0].label = "Take deep breaths.."
	choices[0].point_type = DialogChoice.PointType.GOOD

	choices[1].label = "What do you mean?"
	choices[1].point_type = DialogChoice.PointType.NEUTRAL

	choices[2].label = "The nerve…"
	choices[2].point_type = DialogChoice.PointType.BAD
	DialogManager.show_choices(choices)
	await DialogManager.choice_made

	start_cutscene("aftermath_njai_conversation")


func _on_premise_line_changed(line: DialogLine) -> void:
	if not DialogManager.is_active:
		return
	if DialogManager._current == null:  # ← add this guard
		return
	if DialogManager._current.npc_id != "premise":
		return
	# only handle the premise dialog
	player_bubble.clear()
	njai1_bubble.clear()
	njai2_bubble.clear()
	moeder_bubble.clear()
	if DialogManager._current.npc_id != "premise":  # ← match npc_id in intro_dialog.tres
		return
	if line.speaker == "mc":
		player_bubble.show_line(line)
	elif line.speaker == 'njai1':
		njai1_bubble.show_line(line)
	elif line.speaker == 'njai2':
		njai2_bubble.show_line(line)
	elif line.speaker == 'moeder':
		moeder_bubble.show_line(line)
		
func _on_end_cutscene():
	await get_tree().create_timer(0.2).timeout
	QuestManager.set_day(1)
	QuestManager.set_phase(2)
	InteractionManager.can_interact = true
	if points_gained > 0:
		TransitionManager.start(intro_narration_good)
	elif points_gained == 0:
		TransitionManager.start(intro_narration_neutral)
	else:
		TransitionManager.start(intro_narration_good)

func _on_premise_dialog_ended(_npc_id: String) -> void:
	player_bubble.clear()

func _play_premise() -> void:
	player.is_frozen = true
	await get_tree().create_timer(1.0).timeout
	DialogManager.start(intro_dialog)
	QuestManager.mark_intro_done(scene_id)
	player.is_frozen = false

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
	await get_tree().process_frame
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			get_viewport().set_input_as_handled()
			if bubble_node.is_typing():
				bubble_node.skip_typing()
			else:
				break
		
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
	
func _shake_camera() -> Vector2:
	var rng = RandomNumberGenerator.new()
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func _shake_player() -> Vector2:
	return Vector2(
		randf_range(-player_shake_strength, player_shake_strength),
		randf_range(-player_shake_strength, player_shake_strength)
	)

func _hide_npc(npc: Node2D) -> void:
	npc.hide()
	# hide interaction area so player can't interact with hidden NPC
	var interaction = npc.get_node_or_null("NpcInteractionArea")
	if interaction:
		interaction.monitoring = false
		interaction.monitorable = false
