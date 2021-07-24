extends Trigger
class_name ControlledTrigger

var on:bool = false
signal on_trip
signal on_reset


func trip():
	on = true
	emit_signal("on_trip")
	update()
	
func reset():
	on = false
	emit_signal("on_reset")
	update()
	
func flip():
	if on:
		reset()
	else:
		trip()

func is_on():
	return on

