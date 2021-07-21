tool
extends Trigger

export(Array, NodePath) var sources
var nodes = [] 


func _draw():
	if self.debug_hints and OS.is_debug_build():
		for node in nodes:
			if node != null:
				var dv = node.global_position-global_position
				draw_line(Vector2.ZERO,dv,Color.green,1.0,true)
		draw_arc(Vector2.ZERO,32.0,0,deg2rad(360),32,Color.white,1.0,true)
		var label = Label.new()
		var font = label.get_font("")
		draw_string(font,Vector2.ZERO,"OR",Color.white)
		label.free()
		
		
func _ready():
	for nodePath in sources:
		if nodePath != null:
			nodes.append(get_node(nodePath))
	
func is_on():
	var q = false
	for node in nodes:
		if node is Trigger:
			q = q or node.is_on()
	return q
	

func _process(delta):
	update()
