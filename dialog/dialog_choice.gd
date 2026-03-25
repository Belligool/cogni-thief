class_name DialogChoice
extends Resource

enum PointType { NEUTRAL, GOOD, BAD, NO_EFFECT }

@export var label: String = ""
@export var point_type: PointType = PointType.NEUTRAL
@export var next_line_index: int = -1 # -1 means end the dialog
@export var sets_flag: String = ""
