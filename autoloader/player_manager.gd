extends Node

var _neutral_points : int = 0
var _bad_points : int = 0
var _good_points : int = 0

var phase_history : Array[Dictionary] = []

func add_neutral_point() -> void:
	_neutral_points += 1
	
func add_good_point() -> void:
	_good_points += 1
	
func add_bad_point() -> void:
	_bad_points += 1
	
func end_phase() -> void:
	phase_history.append({
		"good": _good_points,
		"bad": _bad_points,
		"neutral": _neutral_points
	})
	_neutral_points = 0
	_bad_points = 0
	_good_points = 0

func get_current_points() -> Dictionary:
	return {
		"good": _good_points,
		"bad": _bad_points,
		"neutral": _neutral_points	
	}
