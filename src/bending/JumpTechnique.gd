extends Node2D

onready var bendingCtrl = get_parent()
onready var player = bendingCtrl.get_parent().getPlayer()

var jumpMode = false

var cellsForJump = []

#var inactiveCells = []

func _ready():
	bendingCtrl.connect("attract_mode_changed", self, "onAttractModeChanged")

func onAttractModeChanged(state):
	if state == false:
		for cell in cellsForJump:
			cell.enableGravity()
			cell.resetDamp()
			cell.changeColor(0)
		
		cellsForJump = []

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
				
				var power = (cellsForJump.size() / 20.0)
				
				for cell in cellsForJump:
					cell.enableGravity()
					cell.resetDamp()
					
					var vec = cell.global_position - player.global_position
					var vel = vec.normalized().rotated(rand_range(-0.2, 0.2)) * rand_range(30.0, 40.0)
					
					cell.linear_velocity = vel * 10.0
#					cell.contact_monitor = true
#					cell.contacts_reported = 3
#					cell.connect("body_entered", self, "onCellCollision", [cell])
					var timer = get_tree().create_timer(0.2)
					timer.connect("timeout", self, "onCellTimeout", [cell])
					
				
#				inactiveCells = cellsForJump
				var jumpPower = 140.0
				if player.linear_velocity.y < 0.0:
					player.linear_velocity.y *= 0.5
				player.impulse(Vector2.UP * jumpPower *  pow(power + 0.6, 1.5))
#				player.jump(jumpPower * pow(power + 0., 2.0), false)
				
				cellsForJump = []
				reEnableJumpMode()

func onCellTimeout(cell):
	returnCellToNormal(cell)

func returnCellToNormal(cell):
#	inactiveCells.erase(cell)
	cell.changeColor(0)

#func onCellCollision(body, cell):
#	var bit = body.get_collision_layer_bit(2)
#	if bit == false:
#		inactiveCells.erase(cell)
#		cell.disconnect("body_entered", self, "onCellCollision")
#		cell.call_deferred("set_contact_monitor", false)
##		cell.contact_monitor = false
#		cell.contacts_reported = 0
#		cell.changeColor(0)

func reEnableJumpMode():
	if jumpMode == true:
		jumpMode = false
		enableJumpMode()

func enableJumpMode():
	if jumpMode == false:
		jumpMode = true
		var cells = bendingCtrl.detachRandomCells(20)
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
			cell.changeColor(0)
			bendingCtrl.addCellToAttracted(cell, true)
		cellsForJump = []
