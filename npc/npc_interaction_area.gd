class_name NpcInteractionArea
extends InteractionArea

@export var npc_bubble_path: NodePath = ""
var _npc_bubble = null

func _ready() -> void:
	if npc_bubble_path:
		_npc_bubble = get_node(npc_bubble_path)
		
func get_bubble():
	return _npc_bubble
	
func _on_body_entered(_body: Node2D) -> void:
	print("hello from npc signal")
	InteractionManager.register_area(self)
	
func _on_body_exited(_body: Node2D) -> void:
	InteractionManager.unregister_area(self) 
