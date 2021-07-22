extends Node2D

signal attract_mode_changed

var attractMode = true

var indicatorRotationSpeed = 0.1

var attractedCells = {}

var focusLevel := 4

var maxBendingRange = 100.0

func setFocusLevel(level : int):
	focusLevel = level

func getIndicator():
	return $Indicator

func _ready():
	randomize()
	changeAttractMode(false)
	
	$Indicator/Area2D.connect("body_entered", self, "_onCellEntered")
	$Indicator/Area2D.connect("body_exited", self, "_onCellExited")

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

func _resetCell(cell):
	cell.changeColor(0)
	cell.enableGravity()
	cell.resetDamp()

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
		
func _physics_process(delta):
	var indicatorPos = $Indicator.global_position
	for cellData in attractedCells.values():
		var cell = cellData.cell
		var vec = indicatorPos - cell.global_position
		cell.impulse(vec * 4.0)

func _process(delta):
	_updateIndicatorPos()
	
	if Input.is_action_pressed("rmb"):
		changeAttractMode(true)
	else:
		changeAttractMode(false)
	
	var indicatorSprite = $Indicator/Sprite
	indicatorSprite.rotate(indicatorRotationSpeed)

# ----------- Indicator and attract mode changing -----------

func _updateIndicatorPos():
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
#	print(power)
#	var power = 3.5
	
	moveVec = moveVec.normalized() * clamp(moveVec.length(), 0.0, power)
	$Indicator.global_position += moveVec

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
