extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D
@onready var audio = $AudioStreamPlayer2D

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	audio.play()
	await audio.finished
