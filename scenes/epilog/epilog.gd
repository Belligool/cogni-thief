extends Node2D

@onready var good_video: VideoStreamPlayer = $Good
@onready var bad_video: VideoStreamPlayer = $Bad
@onready var neutral_video: VideoStreamPlayer = $Neutral
@onready var mc_text: Label = $MCText
@onready var mist_text: Label = $MistText
@onready var music: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var fader: ColorRect = $Fader/ColorRect

@export var ending_transition: NarrationData
@export var type_speed: float = 0.03


func _ready() -> void:
	music.stream.loop = true
	music.play()
	good_video.hide()
	bad_video.hide()
	neutral_video.hide()
	mc_text.text = ""
	mist_text.text = ""

	var total = PlayerManager.get_total_points()
	if total > 0:
		await _play_good_ending()
	elif total < 0:
		await _play_negative_ending()
	else:
		await _play_neutral_ending()

	_on_ending_finished()

# GOOD ENDING
func _play_good_ending() -> void:
	_show_video(good_video)

	await _mist("My my, is the hero awake yet?")
	await _mist("Trying to fix it all, yet still needing my power to solely exist. Pathetic, aren't you?")

	await _mc("...")
	await _mc("Where am I?")
	await _mc("What are you?")
	await _mc("What is happening?")
	await _mc("What happened to all of them? To Matthijs, to Ruby, to-")

	await _mist("Shush. I have a better question yet. Have you enjoyed the lives I gave to you?")
	await _mist("Or, mayhaps, you have forgotten about our deal?")
	await _mist("Playing savior drains your energy so much, does it?")

	await _mc("...")

	await _mist("How... hopeless.")
	await _mist("But fine, I'll jog that tiny little mind of yours.")
	await _mist("We made a deal, back when you were some weak dust floating around.")
	await _mist("This mighty entity have graced your unworthy existence a miracle-")
	await _mist("A spark of my power!")
	await _mist("Thus it leads to your condition! Experiencing many mortal lives!")
	await _mist("To be human and experience them, was what you asked for.")

	await _mc("..what's the price for all this?")

	await _mist("My my, so your little brain-oh, no, no. You have none of it now. Not when you're like this!")
	await _mist("So you still retain the ability to think? Shall I rejoice?")
	await _mist("Hmm.. back then, you were so innocent. So fragile.")
	await _mist("You merely hoped to live. Always so persistent.")
	await _mist("Even when you haven't heard what I demanded.")
	await _mist("I didn't have it in me to remind you!")
	await _mist("That small flicker of light, all bouncing around as if alive.")
	await _mist("All because of a chance to live.")
	await _mist("Though, I would say you took quite the boring path.")
	await _mist("Trying to make everything right, despite the medium themselves rejecting your attempts.")
	await _mist("It was foolish! Utterly useless! Especially when you're unable to reap what you sow!")
	await _mist("The Lion Cub, always so haughty, yet oblivious to the vulnerable position he was in.")
	await _mist("The Jellyfish, always letting the waves carry her around. Not knowing it would endanger her own kin.")
	await _mist("And The Wasp, always so fiery, going as far as stinging her own blood. Wanting to eat the poor larva her child carried.")
	await _mist("There was no need to change the course, and yet you still did.")
	await _mist("Have you no shame? Wasting the powers I have given you for their lives.")

	await _mc("Why should I?")
	await _mc("I was there, among all of them. I experience their lives.")
	await _mc("Deep down, they wanted change to happen.")
	await _mc("Shatje loved his Mamma, his family very much. And only wanted the best for them.")
	await _mc("So does Ruby. Despite their shortcomings, she still loved her parents. And she adored her child.")
	await _mc("Mrs. Dallen? What she did was wrong, but she merely wanted the best for the daughter.")
	await _mc("If my presence that fills lesser than a tenth of their lives could make it better,")
	await _mc("If a small push from me could make such beautiful relationships bloom,")
	await _mc("It is all worth it.")

	await _mist("How... dull.")
	await _mist("I gave you to live their life as freely as you could,")
	await _mist("Yet all you think about is the owner of the medium itself?")
	await _mist("...")
	await _mist("I have lost my appetite.")
	await _mist("Leave. Suffer as a mere mortal.")

# NEUTRAL ENDING
func _play_neutral_ending() -> void:
	_show_video(neutral_video)

	await _mist("My, our little chameleon is up. Delightful slumber?")

	await _mc("...")
	await _mc("What is happening?")

	await _mist("No inquiries? Or, mayhaps, a sliver of sentiment?")
	await _mist("..Alas.")
	await _mist("You made a deal with me, little one. Hence why you can live as others.")
	await _mist("And now? It is time to reap what I sow within you.")

	await _mc("...I see.")

	await _mist("...")
	await _mist("Though, I would say.. You enjoy living as those people, do you not?")
	await _mist("Mayhaps, you love the experience? Collect it all like some sort of reward?")
	await _mist("Or, perchance, you have no will inside you but to surrender?")
	await _mist("The Lion Cub, where you act all haughty.")
	await _mist("The Jellyfish, where you let the currents guide her forward.")
	await _mist("And The Wasp, where you let that kin of hers left.")
	await _mist("Always blending into the world around you, always trying to fit in.")
	await _mist("You merely used a trifle of my power.")
	await _mist("Even now, you won't, or can't, deny it.")
	await _mist("Tell me, little chameleon. What are you planning to do with the rest of it?")

	await _mc("More.")
	await _mc("I want to experience more.")
	await _mc("More of their lives, more of their stories, I want more.")

	await _mist("Greedy.")
	await _mist("That's the only thing I fancy from you. Always wanting some more.")
	await _mist("Then go, inhabit more mediums, as you wish.")
	await _mist("Until you exhaust those lended powers of mine. Then you shall see me once more.")
	await _mist("Perhaps then I shall find you delectable.")
	await _mist("Not now, not today.")

# NEGATIVE ENDING
func _play_negative_ending() -> void:
	_show_video(bad_video)

	await _mist("Little serpent. It's time to open your eyes.")
	await _mist("My, I didn't think you would be such an obedient little one.")

	await _mc("...where am I?")
	await _mc("What's going to happen to me?")

	await _mist("No need to be feisty, little one.")
	await _mist("I won't tear your body, nor blow that little light of yours away.")
	await _mist("Not when you interest me so.")

	await _mc("Why?")

	await _mist("I shall remind you of our little deal. One you have forgotten.")
	await _mist("Something we made when you were weaker. Akin to a candlelight out in a storm. A fledgling about to be devoured by the serpent.")
	await _mist("I gave that small light a chance. Experience mortal life.")
	await _mist("That was our deal.")
	await _mist("Might I say, your deeds on Earth were.. Intriguing.")
	await _mist("I shall remind you your action made them bear the consequences.")

	await _mc("Why should I care?")
	await _mc("As you've said, I merely experience their lives.")
	await _mc("Those lives weren't mine, nor should I care.")

	await _mist("Acting indifferent, I see. Despite the bond formed between you and those mediums.")
	await _mist("No effort of yours could deceive me. I observed each one of your reactions.")
	await _mist("The way those... my, how did they say it? Inlanders, was it? Talk about The Lion Cub's Mother.")
	await _mist("The rage, the disappointment, the fear as The Jellyfish faced her family.")
	await _mist("Shall I add the way your oh-so-hollow heart pleaded for your daughter when you inhibited The Wasp's body?")
	await _mist("Such wrath, all because of those memories? My... embarrassed, aren't you?")
	await _mist("You're quite the temptress, aren't you?")
	await _mist("Always shedding off your skin, growing...")
	await _mist("How delightsome. Utterly delectable.")
	await _mist("You shall be my meal, and you.. Shall be honor'd to merge within me.")

# ==========================================
# HELPER FUNCTIONS
# ==========================================
func _show_video(video_node: VideoStreamPlayer) -> void:
	good_video.hide()
	bad_video.hide()
	neutral_video.hide()
	video_node.show()
	video_node.play()
	
	if video_node == good_video:
		mist_text.add_theme_color_override("font_color", Color(0.877, 0.773, 0.529, 1.0))   # cool blue
	elif video_node == neutral_video:
		mist_text.add_theme_color_override("font_color", Color(0.8, 0.7, 1.0))       # soft purple
	elif video_node == bad_video:
		mist_text.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))

func _mc(text: String) -> void:
	mist_text.text = ""
	await _type_text(mc_text, text)
	await _wait_for_input()
	mc_text.text = ""
	await get_tree().process_frame

func _mist(text: String) -> void:
	mc_text.text = ""
	await _type_text(mist_text, text)
	await _wait_for_input()
	mist_text.text = ""
	await get_tree().process_frame

func _type_text(label: Label, text: String) -> void:
	label.text = ""
	for i in range(text.length()):
		if Input.is_action_just_pressed("ui_accept"):
			label.text = text
			return
		label.text += text[i]
		await get_tree().create_timer(type_speed).timeout

func _wait_for_input() -> void:
	await get_tree().process_frame
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			break

func _on_ending_finished() -> void:
	# Reset all counters before going back to main menu
	PlayerManager._accumulation_points = 0
	PlayerManager._good_points = 0
	PlayerManager._bad_points = 0
	PlayerManager._neutral_points = 0
	PlayerManager.phase_history.clear()
	PlayerManager.interacted_npc.clear()
	PlayerManager.used_item.clear()
	QuestManager.set_phase(0)
	QuestManager.set_day(0)
	QuestManager.triggered_flags.clear()

	if ending_transition != null:
		TransitionManager.start(ending_transition)
	else:
		printerr("Forgot to slot in Ending Transition data!")
