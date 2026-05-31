extends Node2D

@onready var interaction_area: NpcInteractionArea = $NpcInteractionArea
@onready var bubble: Node2D = $SpeechBubble
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var dialog: DialogData
@export var dialogs_per_day: Array[DialogData] = []
@export var one_time_only: bool = false     # can only interact once
@export var current_flag: String = "lock"


var player = null
var player_bubble = null
