extends CharacterBody2D
const SPEED = 50.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var walking_sfx = $AudioStreamPlayer2D
@onready var is_frozen = false

@export var animated_sprites: Array[SpriteFrames] = []
@export var walk_sfx : Array[AudioStreamMP3] = []

func _ready() -> void:
	match QuestManager.get_current_phase():
		1:
			print("phase1")
			animated_sprite.sprite_frames = animated_sprites[0]
		2:
			print("phase2")
			animated_sprite.sprite_frames = animated_sprites[1]
		3:
			print("phase3")
			animated_sprite.sprite_frames = animated_sprites[2]

func _physics_process(_delta: float) -> void:
	if is_frozen:
		velocity = Vector2.ZERO
		walking_sfx.stop()
		return
	# If a dialog is taking place stop movement entirely
	if DialogManager.is_active:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		walking_sfx.stop()
		return

	# Get input direction: -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	if direction == 0:
		animated_sprite.play("idle")
		walking_sfx.stop()
	elif direction < 0 or direction > 0:
		animated_sprite.play("walk")
		if not walking_sfx.playing:
			walking_sfx.play(1)
		
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
