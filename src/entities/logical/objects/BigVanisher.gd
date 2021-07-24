extends SignalTriggerable

func _ready():
	if state:
		onRisingEdge()
	else:
		onFallingEdge()

func onFallingEdge():
	$Sprite.frame = 9
#	$VanisherTex.modulate.a = 1
	$CollisionShape2D.disabled = false
	
func onRisingEdge():
	$Sprite.frame = 8
#	$VanisherTex.modulate.a = 0.5
	$CollisionShape2D.disabled = true
