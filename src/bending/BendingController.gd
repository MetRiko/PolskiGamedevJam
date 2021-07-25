extends Node2D

signal attract_mode_changed

var indicatorRotationSpeed = 0.1

var focusLevel := 4

var unlockedBending = true
var unlockedBullets = true
var unlockedFists = true
var unlockedShield = true
var unlockedBetterBending = true
var unlockedMultiJump = true
var unlockedLiquidMaster = false
var unlockedSword = false

func unlockSkill(skillId : int, flag : bool = true):
	match skillId:
		0:
			unlockedBending = flag
		1:
			unlockedBullets = flag
		2:
			unlockedFists = flag
		3:
			unlockedShield = flag
		4:
			unlockedBetterBending = flag
		5:
			unlockedMultiJump = flag
		6:
			unlockedLiquidMaster = flag
		7:
			unlockedSword = flag

func isSkillUnlocked(skillId : int):
	match skillId:
		0:
			return unlockedBending
		1:
			return unlockedBullets
		2:
			return unlockedFists
		3:
			return unlockedShield
		4:
			return unlockedBetterBending
		5:
			return unlockedMultiJump
		6:
			return unlockedLiquidMaster
		7:
			return unlockedSword
	return false

func setFocusLevel(level : int):
	focusLevel = level

func getIndicator():
	return $Indicator

func _ready():
	randomize()
	$LiquidMasterTimer.connect("timeout", self, "_onLiquidMasterTimer")
	
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
	
var enableFists = false
var enableShield = false
var enableBending = false
	
func _process(delta):
	_updateIndicatorPos()
	
	var lmb = Input.is_action_pressed("lmb")
	var rmb = Input.is_action_pressed("rmb")
	
	var bendingTech = getBendingTechnique()
	var shieldTech = getShieldTechnique()
	var fistsTech = getFistsTechnique()
	
	enableFists = (lmb and not rmb) or (lmb and fistsTech.swordMode == true)
	enableShield = lmb and rmb and fistsTech.swordMode == false
	enableBending = not lmb and rmb
	
	enableFists = enableFists and unlockedFists
	enableShield = enableShield and unlockedShield
	enableBending = enableBending and unlockedBending
	
	bendingTech.changeAttractMode(enableBending)
	fistsTech.changeSwordMode(enableFists)
	shieldTech.changeFocusMode(enableShield)
	
	var indicatorSprite = $Indicator/Sprite
	indicatorSprite.rotate(indicatorRotationSpeed * 60.0 * delta)

func _onLiquidMasterTimer():
	if unlockedLiquidMaster:
		if enableFists or enableShield or enableBending:
			var world = Game.getWorld()
			var pos = $Indicator.global_position
			world.createLiquidCell(pos)

# ----------- Indicator -----------

func _updateIndicatorPos():
	
	$Indicator.visible = unlockedBending
	
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
