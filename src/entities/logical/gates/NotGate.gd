tool
extends Trigger

export var source: NodePath
onready var node  = get_node(source)



func _draw():
	if self.debug_hints and OS.is_debug_build():
		if node != null:
			var dv = node.global_position-global_position
			draw_line(Vector2.ZERO,dv,Color.green,1.0,true)
		draw_arc(Vector2.ZERO,32.0,0,deg2rad(360),32,Color.white,1.0,true)
		var label = Label.new()
		var font = label.get_font("")
		draw_string(font,Vector2.ZERO,"NOT",Color.white)
		label.free()
	
	
func is_on():
	if node == null:
		return true	
	return not node.is_on()


func _process(delta):
	update()
