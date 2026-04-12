extends CanvasLayer

@onready var background: ColorRect = $Background 
var _tween: Tween = null

func _ready() -> void:
	TransitionManager.scene_change_started.connect(_on_started)
	TransitionManager.scene_change_finished.connect(_on_finished)
	background.modulate.a = 0.0

func _on_started() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(background, "modulate:a", 1.0, 1.0)
	await _tween.finished
	TransitionManager.finish_scene_change()
	
func _on_finished(spawn_id: String) -> void:
	print("spawn_id received: '", spawn_id, "'")
	if spawn_id != "":
		var spawn = get_tree().get_first_node_in_group(spawn_id)
		var player = get_tree().get_first_node_in_group("player")
		print("spawn node: ", spawn)
		print("player node: ", player)
		if spawn and player:
			print("spawn global_position: ", spawn.global_position)
			player.global_position = spawn.global_position
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(background, "modulate:a", 0.0, 1.0)
	
	
