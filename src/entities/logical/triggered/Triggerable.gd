extends Node2D
class_name Triggerable

export var connection: NodePath
onready var _connected = null

func _ready():
	if Engine.editor_hint == false:
		if connection:
			connectTo(get_node(connection))
			
func connectTo(trigger):
	_connected = trigger
		
func whenOn():
	pass 
	
func whenOff():
	pass
	

func _process(delta):
	if Engine.editor_hint == false:
		if _connected:
			if _connected.is_on():
				whenOn()
			else:
				whenOff()
