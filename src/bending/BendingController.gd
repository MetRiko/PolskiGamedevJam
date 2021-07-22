extends Node2D

signal attract_mode_changed


var indicatorRotationSpeed = 0.1

var attractMode = true
var attractedCells = {}

var focusMode = true
var focusedCells = {}

var focusLevel := 4

var maxBendingRange = 100.0
var maxFocusRange = 30.0

func setFocusLevel(level : int):
	focusLevel = level

func getIndicator():
	return $Indicator

func _ready():
	randomize()
	changeAttractMode(false)
	changeFocusMode(false)
	
	$Indicator/Area2D.connect("body_entered", self, "_onCellEntered")
	$Indicator/Area2D.connect("body_exited", self, "_onCellExited")
#	$Indicator/FocusModeArea2D.connect("body_entered", self, "_onCellEnteredFocus")
#	$Indicator/FocusModeArea2D.connect("body_exited", self, "_onCellExitedFocus")
	$FocusTimer.connect("timeout", self, "_onFocusTimer")

func detachRandomCells(maxAmount : int):
	var cells = []
	for dataCell in attractedCells.values():
		cells.append(dataCell.cell)
	
	var randomCells = Utils.getRandomElementsFromArray(cells, maxAmount)
	
	for cell in randomCells:
		detachCell(cell)

	return randomCells

func attachCell(cell):
	if cell.getColorId() == 0:
		var cellId = cell.get_instance_id()
		var cellData = attractedCells.get(cellId)
		if cellData == null:
			attractedCells[cellId] = {
				cell = cell,
				attached = true
			}
		#	cell.disableCollisionWithCells()
			cell.changeColor(1)
			cell.disableGravity()
			cell.linear_damp = 7.0
	
func detachCell(cell, ignoreChecking := false):
	var cellId = cell.get_instance_id()
	if ignoreChecking == false:
		var cellData = attractedCells.get(cellId)
		if cellData == null:
			return
	attractedCells.erase(cellId)
#	cell.enableCollisionWithCells()
	_resetCell(cell)
	
func focusCell(cell):
	if cell.getColorId() == 0:
		var cellId = cell.get_instance_id()
		var cellData = focusedCells.get(cellId)
		if cellData == null:
			focusedCells[cellId] = {
				cell = cell,
				order = focusedCells.size(),
				dir = rand_range(-PI, PI)
			}
			cell.changeColor(4)
			cell.disableGravity()
			cell.linear_damp = 5.0
			cell.disableCollisionWithCells()

func defocusCell(cell):
	var cellId = cell.get_instance_id()
	var cellData = focusedCells.get(cellId)
	if cellData != null:
		focusedCells.erase(cellId)
	#	cell.enableCollisionWithCells()
		_resetCell(cell)

func _resetCell(cell):
	cell.changeColor(0)
	cell.enableGravity()
	cell.resetDamp()
	cell.enableCollisionWithCells()

func _onCellEntered(cell):
	if attractMode == true:
		attachCell(cell)

func _onCellExited(cell):
	var id = cell.get_instance_id()
	var cellData = attractedCells.get(id)
	if cellData:
		var timer = get_tree().create_timer(0.4)
		timer.connect("timeout", self, "_onCellDetached", [cell])
		cellData.attached = false

func _onCellDetached(cell):
	var id = cell.get_instance_id()
	var obj = attractedCells.get(id)
	if obj and obj.attached == false:
		detachCell(cell, true)

func _onCellEnteredFocus(cell):
	if focusMode == true:
		focusCell(cell)

func _onCellExitedFocus(cell):
	defocusCell(cell)
		
func _onFocusTimer():
	if focusMode == true:
		var cells = $Indicator/FocusModeArea2D.get_overlapping_bodies()
		var normalCells = []
		for cell in cells:
			if cell.getColorId() == 0:
				normalCells.append(cell)
		var randomCells = Utils.getRandomElementsFromArray(normalCells, (randi() % 3) + 1)
		for cell in randomCells:
			focusCell(cell)
		
func _physics_process(delta):
	var indicatorPos = $Indicator.global_position
	for cellData in attractedCells.values():
		var cell = cellData.cell
		var vec = indicatorPos - cell.global_position
		cell.impulse(vec * 4.0)
		
	var player = get_parent().getPlayer()
	var playerPos = player.global_position
	for cellData in focusedCells.values():
		var cell = cellData.cell
		var order = cellData.order
		var rotationSign = (int(order) % 2) * 2.0 - 1.0
		var rotationPower = focusedCells.size() * 0.2 * order * 0.006 * rotationSign
		if rotationPower > 0.2:
			rotationPower *= 0.1
		var dir = cellData.dir + rotationPower
		
#		var targetPos = indicatorPos + Vector2(cos(dir), sin(dir)) * (order * 0.7 + focusedCells.size() * 0.8)
		var targetPos = playerPos + Vector2(cos(dir), sin(dir)) * (28.0 + order * 0.14)
		var finalVec = targetPos - cell.global_position
		var power = clamp(pow(finalVec.length(), 1.2) * 0.4, 50.0, 120.0)
		
#		if vec.length_squared() > 400.0:
		cell.impulse(finalVec.normalized() * power)

func _process(delta):
	_updateIndicatorPos()
	
	var lmb = Input.is_action_pressed("lmb")
	var rmb = Input.is_action_pressed("rmb")
	
	if lmb and not rmb:
		changeFocusMode(true)
	elif not lmb and rmb:
		changeAttractMode(true)
	elif lmb and rmb:
		pass
	else:
		changeAttractMode(false)
		changeFocusMode(false)
	
	var indicatorSprite = $Indicator/Sprite
	indicatorSprite.rotate(indicatorRotationSpeed * 60 * delta)

# ----------- Indicator -----------

func _updateIndicatorPos():
	if focusMode == false:
		_updateIndicatorPosForAttractMode()
	elif attractMode == false:
		_updateIndicatorPosForFocusMode()
	else:
		pass
	
func _updateIndicatorPosForAttractMode():
	var mousePos = get_global_mouse_position()
	
	var player = get_parent().getPlayer()
	var vec = mousePos - player.global_position
	var dis = clamp(vec.length(), 0.0, maxBendingRange)
	var reducedVec = vec.normalized() * dis
	var targetPos = player.global_position + reducedVec
	var pos = $Indicator.global_position
	var moveVec = targetPos - pos
	
#	var power = 6.0 - clamp(pow(($Indicator.global_position - player.global_position).length(), 0.4) * 0.5, 1.0, 4.0)
	var power = pow(($Indicator.global_position - targetPos).length(), 0.6) * 0.3
	
	moveVec = moveVec.normalized() * clamp(moveVec.length(), 0.0, power)
	$Indicator.global_position += moveVec


func _updateIndicatorPosForFocusMode():
	var mousePos = get_global_mouse_position()
	
	var player = get_parent().getPlayer()
	var vec = mousePos - player.global_position
	var dis = clamp(vec.length(), maxFocusRange * 0.7, maxFocusRange)
	var reducedVec = vec.normalized() * dis
	var targetPos = player.global_position + reducedVec
	var pos = $Indicator.global_position
	var moveVec = targetPos - pos
	
#	var power = 6.0 - clamp(pow(($Indicator.global_position - player.global_position).length(), 0.4) * 0.5, 1.0, 4.0)
	var power = pow(($Indicator.global_position - targetPos).length(), 0.6) * 0.7
	
	moveVec = moveVec.normalized() * clamp(moveVec.length() * 4.0, 0.0, power)
	$Indicator.global_position += moveVec


# ----------- Attract mode changing -----------

func enableAttractMode():
	if attractMode == false:
		attractMode = true
		var indicatorSprite = $Indicator/Sprite
		var indicatorTween = $Indicator/Tween
		indicatorSprite.frame = 1
		indicatorSprite.modulate = Color(1.0, 1.0, 1.0, 10.0)
		indicatorTween.interpolate_method(self, "onIndicatorRotationChanging", indicatorRotationSpeed, 0.32, 0.15, Tween.TRANS_SINE, Tween.EASE_IN)
		indicatorTween.start()
		
		attractedCells = {}
		
		for cell in $Indicator/Area2D.get_overlapping_bodies():
			attachCell(cell)
			
		emit_signal("attract_mode_changed", true)
	
func disableAttractMode():
	if attractMode == true:
		attractMode = false
		var indicatorSprite = $Indicator/Sprite
		var indicatorTween = $Indicator/Tween
		indicatorSprite.frame = 0
		indicatorSprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		indicatorTween.interpolate_method(self, "onIndicatorRotationChanging", indicatorRotationSpeed, 0.08, 0.15, Tween.TRANS_SINE, Tween.EASE_IN)
		indicatorTween.start()
		
		for cellData in attractedCells.values():
			var cell = cellData.cell
			_resetCell(cell)
		
		emit_signal("attract_mode_changed", false)
		
		attractedCells = {}
		
func changeAttractMode(flag : bool):
	if flag == true:
		enableAttractMode()
	else:
		disableAttractMode()

func onIndicatorRotationChanging(value):
	indicatorRotationSpeed = value
	
# ----------- Focus mode changing -----------

func enableFocusMode():
	if focusMode == false:
		focusMode = true
		var indicatorSprite = $Indicator/Sprite
		var indicatorTween = $Indicator/Tween
		indicatorSprite.frame = 2
		indicatorSprite.modulate = Color(1.0, 1.0, 1.0, 10.0)
		indicatorTween.interpolate_method(self, "onIndicatorRotationChanging2", indicatorRotationSpeed, -0.45, 0.15, Tween.TRANS_SINE, Tween.EASE_IN)
		indicatorTween.start()
		
		focusedCells = {}
		
#		for cell in $Indicator/Area2D.get_overlapping_bodies():
#			focusCell(cell)
			
		emit_signal("attract_mode_changed", true)
	
func disableFocusMode():
	if focusMode == true:
		focusMode = false
		var indicatorSprite = $Indicator/Sprite
		var indicatorTween = $Indicator/Tween
		indicatorSprite.frame = 0
		indicatorSprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		indicatorTween.interpolate_method(self, "onIndicatorRotationChanging2", indicatorRotationSpeed, 0.08, 0.15, Tween.TRANS_SINE, Tween.EASE_IN)
		indicatorTween.start()
		
		for cellData in focusedCells.values():
			var cell = cellData.cell
			_resetCell(cell)
		
		emit_signal("attract_mode_changed", false)
		
		focusedCells = {}
		
func changeFocusMode(flag : bool):
	if flag == true:
		enableFocusMode()
	else:
		disableFocusMode()

func onIndicatorRotationChanging2(value):
	indicatorRotationSpeed = value
