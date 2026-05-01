extends Node2D

@onready var moeder = $Moeder
@onready var player = $Player
@onready var child1 = $child1
@onready var child2 = $child2
@onready var saleh = $saleh
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var initialPlayerPos: Vector2 = Vector2.ZERO
@onready var moeder_bubble = $Moeder/SpeechBubble
@onready var player_bubble = $Player/SpeechBubble
@onready var child1_bubble = $child1/SpeechBubble
@onready var child2_bubble = $child2/SpeechBubble
@onready var saleh_bubble = $saleh/SpeechBubble
@onready var initial_point = PlayerManager.get_total_points()

@export var intro_dialog: DialogData
@export var scene_id: String = "matthijs_bedroom_day2"
@export var intro_narration: NarrationData
 
var shake_strength: float = 0.0
var player_shake_strength: float = 0.0
var shake_fade: float = 5.0
var randomStrength: float = 30.0
var _cutscene_map: Dictionary = {}
var _player_is_shaking: bool = false

func _process(delta: float) -> void:
	if !QuestManager.was_cutscene_seen("matthijs_room_day_2_aftermath"):
		_sprite_facing_player(child1)
		_sprite_facing_player(child2)
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
		
func start_player_shake(strength: float = 5.0) -> void:
	initialPlayerPos = player.position
	player_shake_strength = strength
	_player_is_shaking = true
	
func _ready() -> void:
	DialogManager.line_changed.connect(_on_premise_line_changed)
	DialogManager.dialog_ended.connect(_on_premise_dialog_ended)
	QuestManager.trigger_cutscene.connect(start_cutscene) 
	_cutscene_map = {
		"matthijs_room_day_2_aftermath_good": _matthijs_room_day_2_aftermath_good,
		"matthijs_room_day_2_aftermath_neutral": _matthijs_room_day_2_aftermath_neutral,
		"matthijs_room_day_2_aftermath_bad": _matthijs_room_day_2_aftermath_bad
	}
	
	if not QuestManager.was_intro_seen(scene_id):
		_play_premise()
	_hide_npc(moeder)

func start_cutscene(cutscene_id: String) -> void:
	if cutscene_id != "matthijs_room_day_2_aftermath":
		return
	
	var current_points = PlayerManager.get_total_points()
	var points_gained = current_points - initial_point
	
	if points_gained > 0:
		await _cutscene_map["matthijs_room_day_2_aftermath_good"].call()
		_on_end_cutscene()
	elif points_gained == 0:
		await _cutscene_map["matthijs_room_day_2_aftermath_neutral"].call()
		_on_end_cutscene()
	else:
		await _cutscene_map["matthijs_room_day_2_aftermath_bad"].call()
		_on_end_cutscene()
	
func _matthijs_room_day_2_aftermath_good(): 
	_sprite_face(player, saleh.global_position.x)
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "Saleh, here's a car don't break it", false) 
	await _play_bubble(player_bubble, "mc", "That was… hard to say.", true)
	await _play_bubble(player_bubble, "mc", "Why is it so hard to lend him a toy?", true)
	await _play_bubble(player_bubble, "mc", "It’s not like he would steal my toys away, right?", true)
	
	await _walk_sprite_to_player(saleh, 20.0)
	await get_tree().create_timer(1).timeout
	
	await _play_bubble(saleh_bubble, "saleh", "Thank you so much, Matthijs!", false)
	await _play_bubble(player_bubble, "mc", "He was sullen before, but now he’s smiling so wide.", true)
	await _play_bubble(player_bubble, "mc", "Over a borrowed toy?", true)
	
	await _walk_sprite_to_player(child2, 50.0)
	await _play_bubble(child1_bubble, "child1", "Matthijs, you shouldn’t act too nice with inlanders!", false)
	await _play_bubble(child1_bubble, "child1", "Vader told me inlanders have no manners!", false, "Father told me inlanders have no manners!")
	await _play_bubble(child2_bubble, "child2", "Mama told me they even eat with their own hands! ", false)
	await _play_bubble(child2_bubble, "child2", "No spoon, no fork, hands! It’s dirty! ", false)
	
	_sprite_face(player, child1.global_position.x)
	await _play_bubble(player_bubble, "mc", "Shut up. We eat sweets with our hands too.", false)
	await _play_bubble(child1_bubble, "child1", "But Matthijs-", false)
	await _play_bubble(player_bubble, "mc", "Do you want me to take back my toys?", false)
	await _play_bubble(child1_bubble, "child1", "Tjee, there’s no need to be so angry.", false, "Geez, there’s no need to be so angry.")
	await _play_bubble(child1_bubble, "child2", "You’re boring, Matthijs!", false)

	await _play_bubble(player_bubble, "mc", "Bangebroek. You said that yet you keep on playing with my toy.", true, "Scaredy cat. You said that yet you keep on playing with my toy.")
	
	await _sprite_walk(child1, 170)
	await _sprite_walk(child2, 169)
	
	InterludeManager.show_interlude(["It took awhile for Mamma to knock on my door,","ushering us to have some tea before they went back home."
	])
	await InterludeManager.interlude_finished
	_hide_npc(saleh)
	_hide_npc(child1)
	_hide_npc(child2)
	
	moeder.show()
	await _walk_sprite_to_player(moeder, -30)
	
	await _play_bubble(moeder_bubble, "moeder", "Schatje, did you have fun playing with your friends?", false, "Darling, did you have fun playing with your friends?")
	await _play_bubble(player_bubble, "mc", "Mhm. But they’re too loud, Mamma.", false)
	await _play_bubble(player_bubble, "mc", "Saleh is nice, quiet, and polite. Unlike them.", false)
	await _play_bubble(moeder_bubble, "moeder", "Is that so?", false)
	_sprite_face(moeder, player.global_position.x)
	await _play_bubble(player_bubble, "mc", "Mhm. Those friends said some bad things to Saleh, Mamma", false)
	await _play_bubble(player_bubble, "mc", "They’re bad.", false)
	await _play_bubble(player_bubble, "mc", "School didn’t teach us to act like that.", false)
	await _play_bubble(player_bubble, "mc", "...", false)
	await _play_bubble(player_bubble, "mc", "Mamma, what does inlander mean? Is it bad too?", false)
	await _play_bubble(moeder_bubble, "moeder", "Schatje...", false, "Darling...")
	await _play_bubble(moeder_bubble, "moeder", "It’s not bad if it’s the truth, ja?.", false, "It’s not bad if it’s the truth, yes?")
	await _play_bubble(moeder_bubble, "moeder", "Our schatje is so smart.", false, "Our darling is so smart.")
	await _play_bubble(moeder_bubble, "moeder", "But Mamma doesn't want you to think of such trivial matters.", false)
	await _play_bubble(moeder_bubble, "moeder", "You should focus on your study and have fun, ja?", false, "You should focus on your study and have fun, yes?")
	await _play_bubble(player_bubble, "mc", "The truth?", true)
	await _play_bubble(player_bubble, "mc", "But it sounds like those kids were trying to shame him.", true)
	await _play_bubble(player_bubble, "mc", "..weird.", true)
	await _play_bubble(player_bubble, "mc", "Yes, Mamma.", true)


func _matthijs_room_day_2_aftermath_neutral():
	_sprite_face(player, saleh.global_position.x)
	player.is_frozen = true
	
	await _play_bubble(player_bubble, "mc", "That's none of my business.", true) 
	await _play_bubble(player_bubble, "mc", "He’s not even my friend.", true)
	await _play_bubble(player_bubble, "mc", "That's none of my business.", true)
	
	await _walk_sprite_to_player(saleh, 20.0)
	await get_tree().create_timer(1).timeout
	
	await _play_bubble(saleh_bubble, "saleh", "Matthijs, I’m sorry, but can I… borrow one too?", false)
	await _play_bubble(player_bubble, "mc", "You can make it yourself, can’t you?", false)
	
	await _walk_sprite_to_player(child2, 50.0)
	await _play_bubble(child1_bubble, "child1", "Ah, my Mamma told me that you guys can make one from those cans!", false)
	await _play_bubble(child2_bubble, "child1", "I’ve seen an inlander playing with ones made from orange peels!", false)
	await _play_bubble(saleh_bubble, "saleh", "Of course not! I, we would never…", false)
	
	start_player_shake(5.0)
	await _play_bubble(player_bubble, "mc", "Why is he staring at me like that?", true)
	await _sprite_walk(saleh, 169)
	await _play_bubble(player_bubble, "mc", "He left… ah, it’s none of my business.", true)
	await _play_bubble(child2_bubble, "child1", "Who would’ve thought he would run away like that!", false)
	await _play_bubble(child1_bubble, "child1", "Heh, is he too embarrassed to admit it?", false)
	await _play_bubble(child1_bubble, "child1", " That he’s not so different from those inlanders?", false)
	await _play_bubble(player_bubble, "mc", "So loud… I should just play by myself", true) 
	
	moeder.show()
	await _walk_sprite_to_player(moeder, 20.0)
	await _play_bubble(moeder_bubble, "moeder", "Schatje, did something happen?", false, "Darling, did something happen?")
	await _play_bubble(player_bubble, "mc", "He cried, and they’re being too loud about it.", false)
	await _play_bubble(player_bubble, "mc", "Mamma went silent. Did I say something wrong?", true)
	await _play_bubble(moeder_bubble, "moeder", "Nou, afternoon tea would be ready in a moment.", false, "Now, afternoon tea would be ready in a moment.")
	await _play_bubble(moeder_bubble, "moeder", " Do put those toys back inside the box later, ja?", false, " Do put those toys back inside the box later, yes?")
	await _sprite_walk(moeder, 179)

	await _walk_sprite_to_player(child1, -20.0)
	await _sprite_face(child1,  player.global_position.x)
	await _sprite_walk(child2, player.global_position.x -  20.0, 20)
	await _play_bubble(child1_bubble, "child1", "Matthijs! You shouldn’t snitch at times like that!", false)
	await _play_bubble(player_bubble, "mc", "Snitch? But I did nothing?", false)
	await _play_bubble(player_bubble, "mc", "All of you made him cry", false)
	await _play_bubble(child2_bubble, "child2", "But we didn’t hurt him!", false)
	await _play_bubble(child2_bubble, "child2", "Your Mamma could get us in trouble", false)
	await _play_bubble(player_bubble, "mc", "Then that’s your own problem. Not mine.", false)
	await _sprite_walk(child2, 179.0)
	await _sprite_walk(child1, 179.0)
	InterludeManager.show_interlude(["I ignored their hushed complaints","playing by myself until Mamma called all of us for tea time.",
	"They went back home without saying goodbye, clearly upset",
	"After I went back into my room",
	"a knock echoed through the door before the door opened, revealing Mamma."
	])
	await InterludeManager.interlude_finished
	_hide_npc(child1)
	_hide_npc(child2)
	
	await _walk_sprite_to_player(moeder, -20.0)
	await _sprite_face(moeder, player.global_position.x)
	await _sprite_face(player, moeder.global_position.x)
	await _play_bubble(moeder_bubble, "moeder", " Schatje? What happened?", false, "Darling? What happened?")
	await _play_bubble(player_bubble, "mc", "They were mad because I told Mamma they were too loud.?", false)
	await _play_bubble(player_bubble, "mc", "They were loud.", false)
	await _play_bubble(player_bubble, "mc", "Matthijs didn’t say anything wrong, right Mamma?", false)
	
func _matthijs_room_day_2_aftermath_bad():
	_sprite_face(player, saleh.global_position.x)
	player.is_frozen = true
	await _walk_sprite_to_player(saleh, 20.0)
	
	await _play_bubble(player_bubble, "mc", "What? Why are you staring at me like that", false) 
	await _play_bubble(saleh_bubble, "saleh", "Matthijs, I haven’t gotten any-", false)
	await _play_bubble(player_bubble, "mc", "You should’ve brought one.", false)
	await _play_bubble(saleh_bubble, "saleh", "But Matthijs-", false)
	
	shake_strength = randomStrength
	await _play_bubble(player_bubble, "mc", "SHUT UP!", false)

	# Lempar barang kalo memungkinkan
	await _play_bubble(player_bubble, "mc", "His presence, his voice, everything! It’s annoying!", true)
	await _play_bubble(child1_bubble, "child1", "What? You’re going to keep on begging?", false)
	await _play_bubble(child1_bubble, "child1", " Ma told me you inlanders could even make toys from cans!", false)
	await _play_bubble(child2_bubble, "child2", "Ah, vader told me inlanders can make cars from orange peels too!", false, "Ah, father told me inlanders can make cars from orange peels too!")
	shake_strength = randomStrength
	await _play_bubble(saleh_bubble, "saleh", "You… ALL OF YOU ARE MEAN!", false)
	await _sprite_walk(saleh, 169)
	_hide_npc(saleh)
	await _play_bubble(child1_bubble, "child1", "Matthijs, Matthijs, did you see his face?", false)
	await _play_bubble(child1_bubble, "child1", "Look at him crying! Huilie-balkie!", false, "Look at him crying! Cry Baby!")
	moeder.show()
	await _walk_sprite_to_player(moeder, 20.0)
	await _play_bubble(moeder_bubble, "moeder", "Schatje, did something happen?", false, "Darling? Did something happened?")
	await _play_bubble(player_bubble, "mc", "...", false)
	await _play_bubble(player_bubble, "mc", "No, Mamma.", false)
	
	await _play_bubble(child1_bubble, "child1", "...", false)
	await _play_bubble(child2_bubble, "child2", "...", false)
	
	await _play_bubble(player_bubble, "mc", "They’re not helping… bangebroek! All of them", true, "They’re not helping… scaredy cat! All of them")
	await _play_bubble(moeder_bubble, "moeder", "...I suppose so.", false)
	await _play_bubble(moeder_bubble, "moeder", "Nou, afternoon tea would be ready in a moment.", false, "Now, afternoon tea would be ready in a moment.")
	await _play_bubble(moeder_bubble, "moeder", " Do put those toys back inside the box later, ja?", false, " Do put those toys back inside the box later, yes?")
	await _sprite_walk(moeder, 179)
	_sprite_walk(child1, 179.0)
	await _sprite_walk(child2, 179.0)
	InterludeManager.show_interlude(["And so, they nodded.",
	"Everyone played together, though they didn’t bring up the earlier commotion.",
	"Perhaps too scared they would get a scolding.",
	"After that, we all had some tea before they went back home.",
	"A knock could be heard upon my door after they went back"
	])
	await InterludeManager.interlude_finished
	await _walk_sprite_to_player(moeder, 20.0)
	await _play_bubble(moeder_bubble, "moeder", "Schatje? Mamma wants to talk. About what happened earlier…", false, "Darling? Mamma wants to talk. About what happened earlier…")
	await _play_bubble(player_bubble, "mc", "My palms… are sweaty. Scary…", true)
	await _play_bubble(moeder_bubble, "moeder", "Did you lie to Mamma, Matthijs?", false)
	await _play_bubble(player_bubble, "mc", "...Matthijs is sorry.", false)
	await _play_bubble(player_bubble, "mc", "Mamma will get mad.", true)
	await _play_bubble(player_bubble, "mc", "Mamma will hate me.", true)
	await _play_bubble(player_bubble, "mc", "Mamma wouldn’t love me anymore", true)
	await _play_bubble(player_bubble, "mc", "Mamma will notice.", true)
	await _play_bubble(moeder_bubble, "moeder", "..Schatje, Mamma is disappointed in you.", false, "..Darling, Mamma is disappointed in you.")
	await _play_bubble(moeder_bubble, "moeder", "Mamma wouldn’t do anything to our Schatje.", false, "Mamma wouldn’t do anything to our Darling.")
	await _play_bubble(player_bubble, "mc", "...Matthijs is sorry.", false)
	await _play_bubble(player_bubble, "mc", "Even if I did something wrong?", true)
	await _play_bubble(player_bubble, "mc", "Even if I made that inlander cry?", true)
	await _play_bubble(player_bubble, "mc", "Even if I hurt that inlander?", true)
	await _play_bubble(moeder_bubble, "moeder", "There’s no need to worry, Schatje.", false, "There’s no need to worry, Darling.")
	await _play_bubble(player_bubble, "mc", "..Even if Matthijs did something wrong?", false)
	await _play_bubble(moeder_bubble, "moeder", "Natuurlijk! Mamma would still love you.", false, "Ofcourse! Mamma would still love you.")
	await _play_bubble(moeder_bubble, "moeder", "Matthijs would still be Matthijs", false)
	await _play_bubble(moeder_bubble, "moeder", "And Matthijs is Mamma’s precious treasure", false)
	await _play_bubble(moeder_bubble, "moeder", "Next time, if Matthijs did something wrong", false)
	await _play_bubble(moeder_bubble, "moeder", "Matthijs should tell Mamma immediately, ja?", false, " Matthijs should tell Mamma immediately, yes?")
	await _play_bubble(player_bubble, "mc", "Yes, Mamma.", false)

	
func _on_premise_line_changed(line: DialogLine) -> void:
	if not DialogManager.is_active:
		return
	if DialogManager._current.npc_id != "premise":
		return
	# only handle the premise dialog
	player_bubble.clear()
	child1_bubble.clear()
	child2_bubble.clear()
	if DialogManager._current.npc_id != "premise":  # ← match npc_id in intro_dialog.tres
		return
	if line.speaker == "mc":
		player_bubble.show_line(line)
	elif line.speaker == 'child1':
		child1_bubble.show_line(line)
	elif line.speaker == 'child2':
		child2_bubble.show_line(line)
		
func _on_end_cutscene():
	QuestManager.set_day(3)
	InteractionManager.can_interact = true
	TransitionManager.start(intro_narration)

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
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
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
