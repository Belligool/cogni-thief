extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D
@onready var audio = $AudioStreamPlayer2D
@export var next_scene: String = ""
@export var spawn_point_id: String = ""

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	audio.play()
	await audio.finished
	TransitionManager.change_scene(next_scene, spawn_point_id)
	await TransitionManager.scene_change_finished
