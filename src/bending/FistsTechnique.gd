extends Node2D

signal sword_mode_changed

var swordMode = true
var swordedCells = {}

var freeOrders = []

var fistsCount = 0

var fists = []

var maxSwordRange = 50.0
var cellsPerFist = 20.0

var regenerationTime = 2.0

var loadingState = 0

var loadingProgress = 0

var smallThickness = 7.0
var bigThickness =  12.0

onready var bendingCtrl = get_parent()
onready var indicator = get_parent().getIndicator()
onready var focusArea = $"../Indicator/FocusModeArea2D"

func _ready():
	randomize()
	changeSwordMode(false)
	
	$FocusTimer.connect("timeout", self, "_onFocusTimer")
	$JiggleTimer.connect("timeout", self, "_onJiggleTimer")
	
func _calculateLocalSquarePos(pointAngle : float, radius : float, squareAngle : float):
	
	var degree90 = PI * 0.5
	var degree45 = PI * 0.25
	
	var cornerProgress = abs(fmod(pointAngle, degree90) - degree45) / degree45
	var cornerDis = sqrt(2.0) * radius
	var additionalDis = (cornerDis - radius) * cornerProgress
	var finalRadius = radius + additionalDis
	
	var vec = Vector2(cos(pointAngle + squareAngle), sin(pointAngle + squareAngle)) * finalRadius
	return vec

func focusCell(cell):
	if cell.getColorId() == 0:# and swordedCells.size() < maxSwordRange:
		var cellId = cell.get_instance_id()
		var cellData = swordedCells.get(cellId)
		if cellData == null:
			if swordedCells.size() == 0:
				$OverheatTimer.start()
			var order = swordedCells.size()
#			var baseVec = _calculateBaseCellPosVec(cell, order)
			
#			for cellData2 in swordedCells.values():
#				cellData2.order += 1
			
			var nextOrder = swordedCells.size()
#			if freeOrders.size() > 0:
#				nextOrder = freeOrders[0]
#				freeOrders.remove(0)
			
			var fistId = floor(order / cellsPerFist) 
			if fistId + 1 > fistsCount:
				fistsCount = fistId + 1
				fists.append({
					fistId = fistId,
					state = 0,
					timeWhenShot = 0.0,
					fullRotationTime = rand_range(0.8, 2.5)
				})
			
			swordedCells[cellId] = {
				cell = cell,
				order = nextOrder,
				fistId = fistId
#				baseVec = baseVec
			}
			cell.changeColor(2)
			cell.thickness = smallThickness
			cell.disableGravity()
			cell.linear_damp = 8.0
			cell.disableCollisionWithCells()
			cell.contact_monitor = true
			cell.contacts_reported = 1
			cell.connect("body_entered", self, "_onCellCollision", [cell])
			

func defocusCell(cell):
	var cellId = cell.get_instance_id()
	var cellData = swordedCells.get(cellId)
	if cellData != null:
		freeOrders.append(cellData.order)
		swordedCells.erase(cellId)
	#	cell.enableCollisionWithCells()
		_resetCell(cell)

func _resetCell(cell):
#	cell.linear_velocity = Vector2()
	cell.thickness = 12.0
	cell.changeColor(0)
	cell.enableGravity()
	cell.resetDamp()
	cell.enableCollisionWithCells()
	cell.call_deferred("set_contact_monitor", false)
	cell.contacts_reported = 0
	cell.disconnect("body_entered", self, "_onCellCollision")
	
func _onFocusTimer():
	if swordMode == true:
		var cells = focusArea.get_overlapping_bodies()
		var normalCells = []
		for cell in cells:
			if cell.getColorId() == 0:
				normalCells.append(cell)
		var randomCells = Utils.getRandomElementsFromArray(normalCells, (randi() % 3) + 2)
		for cell in randomCells:
			focusCell(cell)

var jiggleSwitcher = 0

func _onJiggleTimer():
#	var overheatProgress = ($OverheatTimer.time_left / $OverheatTimer.wait_time)
	
#	var intencity = clamp(swordedCells.size() / 35.0, 0.0, 1.0)
#	var intencity = (1.0 - overheatProgress) * 0.8 + 0.7
	
	var currentTime = OS.get_ticks_msec() * 0.001
	
	for cellData in swordedCells.values():
		var cell = cellData.cell
		var fistId = cellData.fistId
		
		if fistId == fistsCount - 1:
			cell.intencity = 1.2
		else:
		
			var fist = fists[fistId]
			
			var cooldownProgress = clamp(currentTime - fist.timeWhenShot, 0.0, regenerationTime) / regenerationTime
#			cooldownProgress = sin(pow(cooldownProgress, 4.0) * PI * 0.5 + PI * 1.5) + 1.0
			cooldownProgress = pow(cooldownProgress, 8.0)
			var intencity = cooldownProgress * 0.6 + 1.0
			if cellData.order % 4 == jiggleSwitcher:
				jiggleSwitcher = (jiggleSwitcher + 1) % 4
				var randomVec = Vector2.RIGHT.rotated(rand_range(0.0, PI * 2.0))
	
#				var power = overheatProgress * 60.0 + 90.0
				var power = 70.0
				cell.impulse(randomVec * power)
			
	#		cell.intencity = intencity * 0.5 + 1.2
			cell.intencity = intencity

var lastCellVel := Vector2()

func _onCellCollision(body, cell):
	return
	if body is TileMap:
		var cellData = swordedCells[cell.get_instance_id()]
		if cellData.order > 16:
			var player = Game.getPlayer()
			var vel = -cell.linear_velocity * 6.0
			
#			var result = Physics2DTestMotionResult.new()
#			cell.test_motion(cell.linear_velocity, false, 0.08, result)
#			print(result)

			var order = cellData.order
			
			for data in swordedCells.values():
				var cell2 = data.cell
				if data.order >= order:
					defocusCell(cell2)
					
#			var normal = result.collision_normal
#			player.linear_velocity = Vector2()
#			player.linear_damp = 10.0
#			player.impulse(normal * cell.linear_velocity.length())
#			if $OverheatTimer.is_stopped():
##				print(lastCellVel.length())
#				player.linear_velocity.y = 0.0
#				var playerVel = -lastCellVel.normalized()
#				var power = clamp(pow(lastCellVel.length(), 1.4) * 0.25, 250.0, 350.0)
#				player.impulse(playerVel * power)
#			$OverheatTimer.start()

func easeOutSine(x : float):
	return sin(x * PI * 0.5 + PI * 1.5) + 1.0

var additionalTime = 0.0

func _physics_process(delta):
	var indicatorPos = indicator.global_position

	var player = Game.getPlayer()
	var playerPos = player.global_position
	
	var overheatProgress = 1.0 - ($OverheatTimer.time_left / $OverheatTimer.wait_time)
	
#	var loadingProgressPower = pow(loadingProgress, 4.0)
	var loadingProgressPower = pow(easeOutSine(loadingProgress), 4.0)
	additionalTime += loadingProgress * 0.05
	
	var currTime = OS.get_ticks_msec() * 0.001 + additionalTime
	
	
#	var fullRotationTime = 2.2 - loadingProgressPower * 1.2
#	var fullRotationTime = 2.2 - pow(loadingProgress, 0.5) * 0.4
	var fullRotationTime = 2.2
	var rotationProgress = fmod(currTime, fullRotationTime) / fullRotationTime
	
	var fistsRadius = fistsCount * (4.0 - loadingProgressPower * 3.0) + (4.0 - loadingProgressPower * 4.0)
		
	for cellData in swordedCells.values():
		var cell = cellData.cell
		var order = cellData.order
		var fistId = cellData.fistId
		
		var fist = fists[fistId]
		var fistAttackMode = fist.state == 1
		
		if fistAttackMode == false:
			var fistVec = Vector2()
			if fistId < fistsCount - 1:
				var fistAngle = (fistId / (fistsCount - 1)) * PI * 2.0 + rotationProgress * PI * 2.0
				fistVec = Vector2(cos(fistAngle), sin(fistAngle)) * fistsRadius
			
			var squarePointAngle = fmod(order, cellsPerFist) / cellsPerFist * PI * 2.0
			var squareRotationProgress = fmod(currTime, fist.fullRotationTime) / fist.fullRotationTime
			var baseVec = _calculateLocalSquarePos(squarePointAngle, 8.0, squareRotationProgress * PI * 2.0)
			
			var targetPos = indicatorPos + baseVec + fistVec
			var vec = targetPos - cell.global_position
			
			var power = 100.0 if fist.state == 0 else 400.0
			vec = vec.normalized() * clamp(pow(vec.length(), 3.0) * 0.5, 0.0, 40.0 + overheatProgress * power)
			cell.impulse(vec)
		else:
			
			var indicatorVec = indicatorPos - player.global_position
			var targetPos = player.global_position + indicatorVec.normalized() * 150.0
			
			var squarePointAngle = fmod(order, cellsPerFist) / cellsPerFist * PI * 2.0
			var squareRotationProgress = fmod(currTime, fist.fullRotationTime) / fist.fullRotationTime
			var baseVec = _calculateLocalSquarePos(squarePointAngle, 8.0, squareRotationProgress * PI * 2.0)
			
			targetPos += baseVec
			var vec = targetPos - cell.global_position
			
#			var power = clamp(pow(vec.length(), 3.0) * 0.5, 0.0, 1000.0)
			var power = 700.0
#			var power = clamp(pow(vec.length(), 3.0) * 0.5, 0.0, 150.0 + (fmod(order, cellsPerFist) / cellsPerFist) * 250.0)
			cell.linear_damp = 10.0 + (fmod(order, cellsPerFist) / cellsPerFist) * 10.0
			cell.impulse(vec.normalized() * power)
			
			
#			var fistVec = Vector2()
#
#			if fistId < fistsCount - 1:
#				var fistAngle = (fistId / (fistsCount - 1)) * PI * 2.0 + rotationProgress * PI * 2.0
#				fistVec = Vector2(cos(fistAngle), sin(fistAngle)) * fistsRadius
#
#			var squarePointAngle = fmod(order, cellsPerFist) / cellsPerFist * PI * 2.0
#			var baseVec = _calculateLocalSquarePos(squarePointAngle, 8.0, PI * 0.25)
#
#			var startPos = indicatorPos + baseVec
#			var indicatorVec = indicatorPos - player.global_position
#			var targetPos = player.global_position + indicatorVec.normalized() * 200.0
#
#			var vec = targetPos - startPos
#			vec = vec.normalized() * clamp(pow(vec.length(), 3.0) * 0.5, 0.0, 40.0 + overheatProgress * 450.0)
#			cell.impulse(vec)
			

func _getFreeFist():
	
	var readyFists = []
	for i in range(fists.size() - 1):
		var fist = fists[i]
		if fist.state == 0:
			readyFists.append(fist)
	
	if readyFists.size() > 0:
		var randFist = readyFists[randi() % readyFists.size()]
		return randFist
	else:
		return null

func _shootFist():
	if fistsCount > 1:
		var fist = _getFreeFist()
		if fist:
			fist.state = 1
			var kickTimer = get_tree().create_timer(0.08)
			kickTimer.connect("timeout", self, "_onKickTimer", [fist])
			
			for cellData in swordedCells.values():
				var fistId = cellData.fistId
				if fistId == fist.fistId:
					var cell = cellData.cell
					cell.thickness = bigThickness
	
func _onKickTimer(fist):
	fist.timeWhenShot = OS.get_ticks_msec() * 0.001
	var returnTimer = get_tree().create_timer(regenerationTime)
	returnTimer.connect("timeout", self, "_onReturnTimer", [fist])
#	fist.state = 2
	
	for cellData in swordedCells.values():
		var cell = cellData.cell
		var fistId = cellData.fistId
		if fistId == fist.fistId:
			cell.thickness = smallThickness
			
			swordedCells.erase(cell.get_instance_id())
			cell.linear_velocity *= 0.05
			_resetCell(cell)
		elif fistId > fist.fistId:
			cellData.fistId -= 1
	
	fists.remove(fist.fistId)
	for i in range(fists.size()):
		fists[i].fistId = i
	
	fistsCount -= 1

func _onReturnTimer(fist):
	fist.state = 0

func _shootShotgun():
	
	if fists.size() < 2:
		return
	
	var player = Game.getPlayer()
	var indicatorPos = indicator.global_position
	var vec = indicatorPos - player.global_position
	
	for cellData in swordedCells.values():
		var cell = cellData.cell
		
		var shotgunTimer = get_tree().create_timer(0.15)
		shotgunTimer.connect("timeout", self, "_onShotgunTimer", [cell])
		
		var vel = vec.normalized().rotated(rand_range(-0.6, 0.6)) * 4200.0#rand_range(500.0, 1200.0)
		cell.intencity = 1.4
		cell.linear_damp = rand_range(15.0, 40.0)
		cell.enableGravity()
		cell.impulse(vel)
		
	var power = 40.0 + 65.0 * clamp(fists.size() - 1, 0.0, 5.0)
	player.linearVelocity = Vector2()
	player.impulse(-vec.normalized() * power)
#	player.dash(-vec.normalized() * power * 1.3, 0.2, 5.0)
	
	swordedCells = {}
	fists = []
	fistsCount = 0
		
func _onShotgunTimer(cell):
	cell.linear_velocity *= 0.9
	_resetCell(cell)

func _changeLoadingState(nextState):
	if loadingState != nextState:
		loadingState = nextState
		
		if nextState == 0:
			$LoadingTween.remove_all()
			$LoadingTween.interpolate_method(self, "_onLoadingTween", loadingProgress, 0.0, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
			$LoadingTween.start()
		elif nextState == 1:
			$LoadingTween.remove_all()
			$LoadingTween.interpolate_method(self, "_onLoadingTween", loadingProgress, 1.0, 1.2, Tween.TRANS_SINE, Tween.EASE_OUT)
			$LoadingTween.start()

func _onLoadingTween(value : float):
	loadingProgress = value

func _input(event):
	if swordMode == true:
		if event.is_action_released("rmb"):
			_changeLoadingState(0)
			if loadingProgress < 1.0:
				_shootFist()
			else:
				_shootShotgun()
		
		if event.is_action_pressed("rmb"):
			_changeLoadingState(1)
			

#		var baseVec = cellData.baseVec
#		var indicatorVec = indicatorPos - playerPos
#		var finalVec = baseVec.rotated(indicatorVec.angle())
#		var targetPos = indicatorPos + finalVec - indicatorVec.normalized() * 20.0
#		var vec = targetPos - cell.global_position
#
#		vec = vec.normalized() * clamp(pow(vec.length(), 3.0) * 0.5, 0.0, 40.0 + overheatProgress * 800.0)
#
#		cell.impulse(vec)
#		lastCellVel = cell.linear_velocity
	
# ----------- Indicator -----------

func _updateIndicatorPosForSwordMode():
	var mousePos = get_global_mouse_position()
	
	var player = Game.getPlayer()
	var vec = mousePos - player.global_position
	var dis = clamp(vec.length(), maxSwordRange * 0.7, maxSwordRange)
	
	var loadingProgresDis = clamp(loadingProgress - 0.5, 0.0, 1.0) * 2.0
	
	dis -= loadingProgresDis * maxSwordRange * 0.8
	
	var reducedVec = vec.normalized() * dis
	var targetPos = player.global_position + reducedVec
	var pos = indicator.global_position
	var moveVec = targetPos - pos
	
#	var power = 6.0 - clamp(pow(($Indicator.global_position - player.global_position).length(), 0.4) * 0.5, 1.0, 4.0)
	var power = pow((indicator.global_position - targetPos).length(), 0.6) * 0.7
	
	moveVec = moveVec.normalized() * clamp(moveVec.length() * 4.0, 0.0, power)
	indicator.global_position += moveVec


# ----------- Focus mode changing -----------

func enableSwordMode():
	if swordMode == false:
		swordMode = true
		var indicatorSprite = indicator.get_node("Sprite")
		var indicatorTween = indicator.get_node("Tween")
		indicatorSprite.frame = 2
		indicatorSprite.modulate = Color(1.0, 1.0, 1.0, 10.0)
		indicatorTween.interpolate_method(self, "onIndicatorRotationChanging2", bendingCtrl.indicatorRotationSpeed, -0.45, 0.15, Tween.TRANS_SINE, Tween.EASE_IN)
		indicatorTween.start()
		
		swordedCells = {}
		
#		for cell in $Indicator/Area2D.get_overlapping_bodies():
#			focusCell(cell)
			
		emit_signal("sword_mode_changed", true)
	
func disableSwordMode():
	if swordMode == true:
		swordMode = false
		var indicatorSprite = indicator.get_node("Sprite")
		var indicatorTween = indicator.get_node("Tween")
		indicatorSprite.frame = 0
		indicatorSprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		indicatorTween.interpolate_method(self, "onIndicatorRotationChanging2", bendingCtrl.indicatorRotationSpeed, 0.08, 0.15, Tween.TRANS_SINE, Tween.EASE_IN)
		indicatorTween.start()
		
		for cellData in swordedCells.values():
			var cell = cellData.cell
			_resetCell(cell)
		
		freeOrders = []
		fistsCount = 0
		
		emit_signal("sword_mode_changed", false)
		
		swordedCells = {}
		
func changeSwordMode(flag : bool):
	if flag == true:
		enableSwordMode()
	else:
		disableSwordMode()

func onIndicatorRotationChanging2(value):
	bendingCtrl.indicatorRotationSpeed = value
