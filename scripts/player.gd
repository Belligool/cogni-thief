extends CharacterBody2D
const SPEED = 50.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var walking_sfx = $AudioStreamPlayer2D

func _physics_process(_delta: float) -> void:
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
