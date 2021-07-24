extends ControlledTrigger

var flag = false

func _ready():
	$Area2D.connect("body_entered", self, "_onBodyEntered")
	
func _onBodyEntered(body):
	if flag == false:
		flag = true
		trip()
		$Sprite.frame = 1
