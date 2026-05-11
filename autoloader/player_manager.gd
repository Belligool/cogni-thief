extends Node

var _neutral_points : int = 0
var _bad_points : int = 0
var _good_points : int = 0
var _accumulation_points: int = 0

var used_item: Array[String] = []
var interacted_npc: Array[String] = []

var phase_history : Array[Dictionary] = []

func add_used_item(item_name: String) -> void:
	used_item.append(item_name)
	
func add_interacted_npc(npc_name: String) -> void:
	interacted_npc.append(npc_name)

func is_item_used(item_name: String) -> bool:
	return used_item.has(item_name)
	
func is_npc_interacted(npc_name: String) -> bool:
	return interacted_npc.has(npc_name)
	
func reset_used_item(item_name: String) -> void:
	used_item.erase(item_name)
	
func reset_interaction_npc(npc_name: String) -> void:
	interacted_npc.erase(npc_name)
	
func add_neutral_point() -> void:
	_neutral_points += 1
	
func add_good_point() -> void:
	print("good points aaded")
	_good_points += 1
	_accumulation_points += 1
	
func add_bad_point() -> void:
	_bad_points += 1
	_accumulation_points -= 1
	
func get_total_points() -> int:
	return _accumulation_points
	
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
