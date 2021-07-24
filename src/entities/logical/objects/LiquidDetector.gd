extends ControlledTrigger

var flag = false

var state = 0

var progress = 0

func _ready():
	if Engine.editor_hint == false:
		$Area2D.connect("body_entered", self, "_onBodyEntered")
		$Area2D.connect("body_exited", self, "_onBodyExited")
	
func isOverlappingAnyCell():
	for cell in $Area2D.get_overlapping_bodies():
		if cell.getColorId() == 0:
			return true
	return false
	
func setProgress(value):
	progress = clamp(value, 0.0, 100.0)
	$TextureProgress.value = progress
	if progress >= 100.0 and state == 1:
		switchState(2)
	
func _process(delta):
	if state == 1:
		setProgress(progress + delta * 16.0)
	elif state == 0:
		setProgress(progress - delta * 45.0)
	
func switchState(nextState):
	if state != nextState and state != 2:
		state = nextState
		if state == 0:
			$Sprite.frame = 2
		elif state == 1:
			$Sprite.frame = 10
		elif state == 2:
			$Sprite.frame = 3
			$TextureProgress.visible = false
			trip()
	
func _onBodyExited(body):
	if Engine.editor_hint == false:
		if state == 1:
			if not isOverlappingAnyCell():
				switchState(0)
				
func _onBodyEntered(cell):
	if Engine.editor_hint == false:
		if state == 0:
			switchState(1)
