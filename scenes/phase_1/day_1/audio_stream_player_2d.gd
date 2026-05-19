extends AudioStreamPlayer2D

var _tween: Tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TransitionManager.transition_started.connect(_fade_out)
	_fade_in()
		
func _fade_in() -> void:
	print("starting music fade in")
	volume_db = -80
	play()
	
	if _tween:
		_tween.kill()
		
	_tween = create_tween()
	_tween.tween_property(self, "volume_db", 0, 2)
	
func _fade_out() -> void:	
	print("starting music fade out")
	if _tween:
		_tween.kill()
		
	_tween = create_tween()
	_tween.tween_property(self, "volume_db", -80, 7)
