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

func getSwordTechnique():
	return $SwordTechnique
	
func getFistsTechnique():
	return $FistsTechnique
	
func _process(delta):
	_updateIndicatorPos()
	
	var lmb = Input.is_action_pressed("lmb")
	var rmb = Input.is_action_pressed("rmb")
	
	var bendingTech = getBendingTechnique()
	var shieldTech = getShieldTechnique()
	var fistsTech = getFistsTechnique()
	
	var enableFists = (lmb and not rmb) or (lmb and fistsTech.swordMode == true)
	var enableShield = lmb and rmb and fistsTech.swordMode == false
	var enableBending = not lmb and rmb
	
	bendingTech.changeAttractMode(enableBending)
	fistsTech.changeSwordMode(enableFists)
	shieldTech.changeFocusMode(enableShield)
	
	var indicatorSprite = $Indicator/Sprite
	indicatorSprite.rotate(indicatorRotationSpeed * 60 * delta)

# ----------- Indicator -----------

func _updateIndicatorPos():
	
	var bendingTech = getBendingTechnique()
	var shieldTech = getShieldTechnique()
#	var swordTech = getSwordTechnique()
	var fistsTech = getFistsTechnique()

	if bendingTech.attractMode == true:
		bendingTech._updateIndicatorPosForAttractMode()
	elif fistsTech.swordMode == true:
		fistsTech._updateIndicatorPosForSwordMode()
	elif shieldTech.focusMode == true:
		shieldTech._updateIndicatorPosForFocusMode()
	else:
		bendingTech._updateIndicatorPosForAttractMode()
