extends Node2D

signal attract_mode_changed

var indicatorRotationSpeed = 0.1

var focusLevel := 4

func setFocusLevel(level : int):
	focusLevel = level

func getIndicator():
	return $Indicator

func _ready():
	randomize()
	
func getBendingTechnique():
	return $BendingTechnique
	
func getJumpTechnique():
	return $JumpTechnique

func getBazookaTechnique():
	return $BazookaTechnique
	
func getShieldTechnique():
	return $ShieldTechnique

func _process(delta):
	_updateIndicatorPos()
	
	var lmb = Input.is_action_pressed("lmb")
	var rmb = Input.is_action_pressed("rmb")
	
	var bendingTech = $BendingTechnique
	var shieldTech = $ShieldTechnique
	
	if lmb and not rmb:
		shieldTech.changeFocusMode(true)
	elif not lmb and rmb:
		bendingTech.changeAttractMode(true)
	elif lmb and rmb:
		pass
	else:
		bendingTech.changeAttractMode(false)
		shieldTech.changeFocusMode(false)
	
	var indicatorSprite = $Indicator/Sprite
	indicatorSprite.rotate(indicatorRotationSpeed * 60 * delta)

# ----------- Indicator -----------

func _updateIndicatorPos():
	
	var bendingTech = $BendingTechnique
	var shieldTech = $ShieldTechnique
	
	if shieldTech.focusMode == false:
		bendingTech._updateIndicatorPosForAttractMode()
	elif bendingTech.attractMode == false:
		shieldTech._updateIndicatorPosForFocusMode()
	else:
		pass
