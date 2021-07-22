extends SignalTriggerable

func _ready():
	if state:
		onRisingEdge()
	else:
		onFallingEdge()
		

func onFallingEdge():
	$VanisherTex.modulate.a = 1
	$CollisionShape2D.disabled = false
	
func onRisingEdge():
	$VanisherTex.modulate.a = 0.5
	$CollisionShape2D.disabled = true
