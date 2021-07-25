extends Node2D

signal focus_mode_changed

var focusMode = true
var focusedCells = {}

var maxFocusRange = 30.0

var disabledCells = []

onready var bendingCtrl = get_parent()
onready var indicator = get_parent().getIndicator()
onready var focusArea = $"../Indicator/FocusModeArea2D"

func _ready():
	randomize()
	changeFocusMode(false)
	
	$FocusTimer.connect("timeout", self, "_onFocusTimer")
	
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

func _resetCell(cell, color : int = 0):
	cell.changeColor(color)
	cell.enableGravity()
	cell.resetDamp()
	cell.enableCollisionWithCells()
		
func _onFocusTimer():
	if focusMode == true:
		var cells = focusArea.get_overlapping_bodies()
		var normalCells = []
		for cell in cells:
			if cell.getColorId() == 0:
				normalCells.append(cell)
		var randomCells = Utils.getRandomElementsFromArray(normalCells, (randi() % 2) + 1)
		for cell in randomCells:
			focusCell(cell)
		
func _physics_process(delta):
	var indicatorPos = indicator.global_position

	var player = Game.getPlayer()
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
		
		if finalVec.length() > 100.0:
			defocusCell(cell)
	
func reduceDamage(value : float, knockback : Vector2):
	var cells = getCellsFromAngle(-knockback, PI * 0.30)
	var cellsNeeded = min(floor(value * 1.6), cells.size())
	
	for i in range(cellsNeeded):
		var cell = cells[i]
		disableCell(cell)
		cell.linear_velocity = Vector2()
		cell.impulse(knockback.rotated(rand_range(-0.5, 0.5)) * 2.3)
		
	var damageAfterReduce = value - cellsNeeded
	
	return damageAfterReduce
	
func getCellsFromAngle(vec : Vector2, spread : float):
	var searchedCells = []
	
	var player = Game.getPlayer()
	
	for cellData in focusedCells.values():
		var cell = cellData.cell
		var cellVec = cell.global_position - player.global_position
		
		var angleBetween = abs(cellVec.angle_to(vec))
		if angleBetween <= spread:
			searchedCells.append(cell)
	
	return searchedCells
	
func disableCell(cellToDisable):
	var cellId = cellToDisable.get_instance_id()
	var cellData = focusedCells.get(cellId)
	if cellData:
		focusedCells.erase(cellId)
		disabledCells.append(cellToDisable)
		_resetCell(cellToDisable, 4)
		cellToDisable.intencity = 0.9
	
# ----------- Indicator -----------

func _updateIndicatorPosForFocusMode():
	var mousePos = get_global_mouse_position()
	
	var player = Game.getPlayer()
	var vec = mousePos - player.global_position
	var dis = clamp(vec.length(), maxFocusRange * 0.7, maxFocusRange)
	var reducedVec = vec.normalized() * dis
	var targetPos = player.global_position + reducedVec
	var pos = indicator.global_position
	var moveVec = targetPos - pos
	
#	var power = 6.0 - clamp(pow(($Indicator.global_position - player.global_position).length(), 0.4) * 0.5, 1.0, 4.0)
	var power = pow((indicator.global_position - targetPos).length(), 0.6) * 0.7
	
	moveVec = moveVec.normalized() * clamp(moveVec.length() * 4.0, 0.0, power)
	indicator.global_position += moveVec


# ----------- Focus mode changing -----------

func enableFocusMode():
	if focusMode == false:
		focusMode = true
		var indicatorSprite = indicator.get_node("Sprite")
		var indicatorTween = indicator.get_node("Tween")
		indicatorSprite.frame = 2
		indicatorSprite.modulate = Color(1.0, 1.0, 1.0, 10.0)
		indicatorTween.interpolate_method(self, "onIndicatorRotationChanging2", bendingCtrl.indicatorRotationSpeed, -0.45, 0.15, Tween.TRANS_SINE, Tween.EASE_IN)
		indicatorTween.start()
		
		focusedCells = {}
		
#		for cell in $Indicator/Area2D.get_overlapping_bodies():
#			focusCell(cell)
			
		emit_signal("focus_mode_changed", true)
	
func disableFocusMode():
	if focusMode == true:
		focusMode = false
		var indicatorSprite = indicator.get_node("Sprite")
		var indicatorTween = indicator.get_node("Tween")
		indicatorSprite.frame = 0
		indicatorSprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		indicatorTween.interpolate_method(self, "onIndicatorRotationChanging2", bendingCtrl.indicatorRotationSpeed, 0.08, 0.15, Tween.TRANS_SINE, Tween.EASE_IN)
		indicatorTween.start()
		
		for cellData in focusedCells.values():
			var cell = cellData.cell
			_resetCell(cell)
		
		for cell in disabledCells:
			_resetCell(cell)
			cell.intencity = 1.0
			
		disabledCells = []
		
		emit_signal("focus_mode_changed", false)
		
		focusedCells = {}
		
func changeFocusMode(flag : bool):
	if flag == true:
		enableFocusMode()
	else:
		disableFocusMode()

func onIndicatorRotationChanging2(value):
	bendingCtrl.indicatorRotationSpeed = value
