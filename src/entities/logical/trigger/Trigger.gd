extends Node2D
class_name Trigger

export var debug_hints = true

func _draw():
	if debug_hints and OS.is_debug_build():
		if self.is_on():
			draw_circle(24*Vector2.UP + 24*Vector2.RIGHT,5,Color.green)
		else:
			draw_arc(24*Vector2.UP + 24*Vector2.RIGHT,5,0,deg2rad(360),64,Color.green,1.0,true)
	
func is_on():
	return false

func _process(delta):
	update()

