extends Node2D
class_name Triggerable

export var connection: NodePath
onready var _connected = get_node(connection)

func whenOn():
	pass 
	
func whenOff():
	pass
	

func _process(delta):
	if _connected.is_on():
		whenOn()
	else:
		whenOff()
