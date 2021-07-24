extends ControlledTrigger

var flag = false

func _ready():
	if Engine.editor_hint == false:
		$Area2D.connect("body_entered", self, "_onBodyEntered")
		$Area2D.connect("body_exited", self, "_onBodyExited")
	
func _onBodyExited(body):
	if Engine.editor_hint == false:
		if is_on():
			for cell in $Area2D.get_overlapping_bodies():
				if cell.getColorId() == 0:
					return
			reset()
			$Sprite.frame = 2

func _onBodyEntered(cell):
	if Engine.editor_hint == false:
		if not is_on():
			if cell.getColorId() == 0:
				trip()
				$Sprite.frame = 3
