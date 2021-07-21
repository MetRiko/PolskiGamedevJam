extends Triggerable
class_name SignalTriggerable


onready var state = self._connected.is_on()

func whenOn():
	if not state:
		onRisingEdge()
		state = true

func whenOff():
	if state:
		onFallingEdge()
		state = false

func onFallingEdge():
	pass
func onRisingEdge():
	pass	
