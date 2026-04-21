extends Camera2D

@export var smooth_speed: float = 5.0
@onready var _player: Node2D = null

func _ready() -> void:
	print("from camera")
	position_smoothing_enabled = false
	_player = get_tree().get_first_node_in_group("player")
	global_position = _player.global_position
