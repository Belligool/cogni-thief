extends Node2D

@onready var caretaker = $caretaker
@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var initialPos = camera.offset
@onready var player_bubble = $Player/SpeechBubble
@onready var caretaker_bubble = $caretaker/SpeechBubble

@export var intro_dialog: DialogData
@export var scene_id: String = "margaretha_room_day1"
@export var day_2_transition: NarrationData

var shake_strength: float = 0.0
var shake_fade: float = 5.0
var randomStrength: float = 30.0
var _skip_bubble = false
var _is_cutscene_playing := false 
var _cutscene_map: Dictionary = {}
