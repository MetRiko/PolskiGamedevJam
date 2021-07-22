extends Node2D

onready var bendingCtrl = get_parent()
onready var player = bendingCtrl.get_parent().getPlayer()

var jumpMode = false

var cellsForJump = []

func _process(delta):
	if player.isOnFloor == false and bendingCtrl.attractMode == true:
		enableJumpMode()
	else:
		disableJumpMode()

func _physics_process(delta):
	if bendingCtrl.attractMode == true:
		var targetPos = player.global_position + Vector2(0.0, 24.0)
		for cell in cellsForJump:
			var vec = targetPos - cell.global_position
			var vel = vec.normalized() * clamp(vec.length_squared(), 0.0, 80.0)
			cell.impulse(vel)
	
	
		if Input.is_action_just_pressed("jump"):
			if cellsForJump.size() > 0:
				
				for cell in cellsForJump:
					cell.enableGravity()
					cell.resetDamp()
					cell.changeColor(0)
					
					var vec = cell.global_position - player.global_position
					var vel = vec.normalized().rotated(rand_range(-0.2, 0.2)) * rand_range(30.0, 40.0)
					cell.linear_velocity = vel * 10.0
				
				player.jump(220.0)
				cellsForJump = []
				reEnableJumpMode()

func reEnableJumpMode():
	if jumpMode == true:
		jumpMode = false
		enableJumpMode()

func enableJumpMode():
	if jumpMode == false:
		jumpMode = true
		var cells = bendingCtrl.detachRandomCells(10)
		cellsForJump = cells
		for cell in cellsForJump:
			cell.disableGravity()
			cell.linear_damp = 8.0
			cell.changeColor(2)
			
func disableJumpMode():
	if jumpMode == true:
		jumpMode = false
		for cell in cellsForJump:
			cell.enableGravity()
			cell.resetDamp()
			bendingCtrl.addCellToAttracted(cell, true)
		cellsForJump = []
