extends Node2D

var attractMode = true

var indicatorRotationSpeed = 0.1

var attracted = {}

func _ready():
	changeAttractMode(false)
	
	$Indicator/Area2D.connect("body_entered", self, "_onCellEntered")
	$Indicator/Area2D.connect("body_exited", self, "_onCellExited")

func _attachCell(cell):
#	cell.disableCollisionWithCells()
	cell.disableGravity()
	
func _detachCell(cell):
#	cell.enableCollisionWithCells()
	cell.enableGravity()

func _addCellToAttracted(cell):
	var id = cell.get_instance_id()
	_attachCell(cell)
	attracted[id] = {
		ref = cell,
		attached = true
	}

func _onCellEntered(cell):
	if attractMode == true:
		_addCellToAttracted(cell)

func _onCellExited(cell):
	var id = cell.get_instance_id()
	var cellData = attracted.get(id)
	if cellData:
		var timer = get_tree().create_timer(0.4)
		timer.connect("timeout", self, "_onCellDetached", [cell])
		cellData.attached = false

func _onCellDetached(cell):
	var id = cell.get_instance_id()
	var obj = attracted.get(id)
	if obj and obj.attached == false:
		attracted.erase(id)
		_detachCell(cell)
		
func _physics_process(delta):
	
	var indicatorPos = $Indicator.global_position
	for cellData in attracted.values():
		var cell = cellData.ref
		var vec = indicatorPos - cell.global_position
		var vel = vec.normalized() * clamp(vec.length_squared(), 0.0, 40.0) * 0.4
		cell.impulse(vel)
#		cell.linear_velocity = vel * 1.0

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
	var dis = clamp(vec.length(), 0.0, 100.0)
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
		
		for cell in $Indicator/Area2D.get_overlapping_bodies():
			_addCellToAttracted(cell)
	
func disableAttractMode():
	if attractMode == true:
		attractMode = false
		var indicatorSprite = $Indicator/Sprite
		var indicatorTween = $Indicator/Tween
		indicatorSprite.frame = 0
		indicatorSprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		indicatorTween.interpolate_method(self, "onIndicatorRotationChanging", indicatorRotationSpeed, 0.08, 0.15, Tween.TRANS_SINE, Tween.EASE_IN)
		indicatorTween.start()
		
		for cellData in attracted.values():
			var cell = cellData.ref
			_detachCell(cell)
		
		attracted = {}
		
func changeAttractMode(flag : bool):
	if flag == true:
		enableAttractMode()
	else:
		disableAttractMode()

func onIndicatorRotationChanging(value):
	indicatorRotationSpeed = value
