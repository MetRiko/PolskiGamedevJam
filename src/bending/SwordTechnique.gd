extends Node2D

signal sword_mode_changed

var swordMode = true
var swordedCells = {}

var freeOrders = []

var maxSwordRange = 50.0

onready var bendingCtrl = get_parent()
onready var indicator = get_parent().getIndicator()
onready var focusArea = $"../Indicator/FocusModeArea2D"

func _ready():
	randomize()
	changeSwordMode(false)
	
	$FocusTimer.connect("timeout", self, "_onFocusTimer")
	$JiggleTimer.connect("timeout", self, "_onJiggleTimer")
	
func _calculateBaseCellPosVec(cell, index : int):
	if index < 10:
		var angle = PI * 0.5 - 0.2
		var angleSign = (index % 2) * 2.0 - 1.0
		var order = floor(index / 2)
		var vec = Vector2.RIGHT.rotated(angle * angleSign) * order * 6.2
		return vec
	elif index < 16:
#		index = floor(index / 3) * 3.0
		var order = index - 4 - 11
		var vec = Vector2.RIGHT * order * 3.7
		return vec
#	elif index < 24:
#		var maxLength = swordedCells.size() - 16
#		var lengthProgress = 1.0 - ((index - 16) / maxLength)
#		var signRadius = (index % 2) * 2.0 - 1.0
#		var maxRadius = 10.0 * signRadius
#
#		var order = index - 4 - 11
#		var vec = Vector2.RIGHT * order * 3.7 + Vector2.UP * lengthProgress * maxRadius
#		return vec
#
	else:
		var maxLength = swordedCells.size() - 15 + 1
		var lengthProgress = 1.0 - ((index - 15) / maxLength)
		var signRadius = (index % 2) * 2.0 - 1.0
		var maxRadius = 8.0 * signRadius
		
		var order = index - 4 - 11
		var vec = Vector2.RIGHT * order * 2.7 + Vector2.UP * lengthProgress * maxRadius
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
			
			swordedCells[cellId] = {
				cell = cell,
				order = nextOrder
#				baseVec = baseVec
			}
			cell.changeColor(2)
			cell.thickness = 8.0
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
	cell.linear_velocity = Vector2()
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
		var randomCells = Utils.getRandomElementsFromArray(normalCells, (randi() % 5) + 3)
		for cell in randomCells:
			focusCell(cell)

var jiggleSwitcher = 0

func _onJiggleTimer():
	var overheatProgress = ($OverheatTimer.time_left / $OverheatTimer.wait_time)
	
#	var intencity = clamp(swordedCells.size() / 35.0, 0.0, 1.0)
	var intencity = (1.0 - overheatProgress) * 0.8 + 0.7
	
	for cellData in swordedCells.values():
		var cell = cellData.cell
		if cellData.order % 4 == jiggleSwitcher:
			jiggleSwitcher = (jiggleSwitcher + 1) % 4
			var randomVec = Vector2.RIGHT.rotated(rand_range(0.0, PI * 2.0))
			
			var power = overheatProgress * 60.0 + 90.0
			cell.impulse(randomVec * power)
		
#		cell.intencity = intencity * 0.5 + 1.2
		cell.intencity = intencity

var lastCellVel := Vector2()

func _onCellCollision(body, cell):
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
			
func _physics_process(delta):
	var indicatorPos = indicator.global_position

	var player = Game.getPlayer()
	var playerPos = player.global_position
	
	var overheatProgress = 1.0 - ($OverheatTimer.time_left / $OverheatTimer.wait_time)
	
	for cellData in swordedCells.values():
		var cell = cellData.cell
		var order = cellData.order
		
		var baseVec = _calculateBaseCellPosVec(cell, order)
#		var baseVec = cellData.baseVec
		var indicatorVec = indicatorPos - playerPos
		var finalVec = baseVec.rotated(indicatorVec.angle())
		var targetPos = indicatorPos + finalVec - indicatorVec.normalized() * 20.0
		var vec = targetPos - cell.global_position
		
		vec = vec.normalized() * clamp(pow(vec.length(), 3.0) * 0.5, 0.0, 40.0 + overheatProgress * 800.0)
		
		cell.impulse(vec)
#		cell.linear_velocity = vec
		lastCellVel = cell.linear_velocity
		
#		var rotationSign = (int(order) % 2) * 2.0 - 1.0
#		var rotationPower = swordedCells.size() * 0.2 * order * 0.006 * rotationSign
#		if rotationPower > 0.2:
#			rotationPower *= 0.1
#		var dir = cellData.dir + rotationPower
#
##		var targetPos = indicatorPos + Vector2(cos(dir), sin(dir)) * (order * 0.7 + swordedCells.size() * 0.8)
#		var targetPos = playerPos + Vector2(cos(dir), sin(dir)) * (28.0 + order * 0.14)
#		var finalVec = targetPos - cell.global_position
#		var power = clamp(pow(finalVec.length(), 1.2) * 0.4, 50.0, 120.0)
#
##		if vec.length_squared() > 400.0:
#		cell.impulse(finalVec.normalized() * power)
	
# ----------- Indicator -----------

func _updateIndicatorPosForSwordMode():
	var mousePos = get_global_mouse_position()
	
	var player = Game.getPlayer()
	var vec = mousePos - player.global_position
	var dis = clamp(vec.length(), maxSwordRange * 0.7, maxSwordRange)
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
		
		emit_signal("sword_mode_changed", false)
		
		swordedCells = {}
		
func changeSwordMode(flag : bool):
	if flag == true:
		enableSwordMode()
	else:
		disableSwordMode()

func onIndicatorRotationChanging2(value):
	bendingCtrl.indicatorRotationSpeed = value
