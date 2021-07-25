extends Node2D

onready var bendingCtrl = get_parent()
onready var player = bendingCtrl.get_parent().getPlayer()

var jumpMode = false

var cellsForJump = []

var cellsCloseToPlayer = 0

#var inactiveCells = []

var shouldUpdateCellsForJump := false

func _ready():
#	bendingCtrl.connect("attract_mode_changed", self, "onAttractModeChanged")

	for attractor in $Attractors.get_children():
		attractor.connect("body_entered", self, "onCellAttractorEntered")
		
	for attractor in $Attractors2.get_children():
		attractor.connect("body_entered", self, "onCellAttractorEntered")

func onCellAttractorEntered(body):
	shouldUpdateCellsForJump = true
#	print('x')

#func onAttractModeChanged(state):
#	if state == false:
#		for cell in cellsForJump:
#			cell.enableGravity()
#			cell.resetDamp()
#			cell.changeColor(0)
#
#		cellsForJump = []

func _updateCellsForJump():
	var allCellsFromGround = getCellsFromAttractors()
	var cellsLeftToAttract = clamp(15 - cellsForJump.size(), 0, 15)
	var cells = Utils.getRandomElementsFromArray(allCellsFromGround, cellsLeftToAttract)
	cellsForJump.append_array(cells)
#	var cells = allCellsFromGround
#	cellsForJump = cells
	for cell in cells:
		cell.disableGravity()
		cell.linear_damp = 8.0
		cell.changeColor(5)

func _clearCellsForJump():
	if cellsForJump.empty() == false:
		for cell in cellsForJump:
			cell.enableGravity()
			cell.resetDamp()
			cell.changeColor(0)
		cellsForJump = []

func _process(delta):
	_updateAttractorsPos()
	
	if player.isOnFloor == false:
		if bendingCtrl.unlockedMultiJump:
			if shouldUpdateCellsForJump == true:
				shouldUpdateCellsForJump = false
				_updateCellsForJump()
	else:
		_clearCellsForJump()
	
#	if player.isOnFloor == false:# and bendingCtrl.attractMode == true:
#		enableJumpMode()
#	else:
#		disableJumpMode()


func _updateAttractorsPos():
	var space2d = get_world_2d().direct_space_state
	
	var startPos = player.global_position + Vector2.DOWN * 24.0
	
	var attractorsCount = $Attractors.get_child_count()
	
	for attractor in $Attractors.get_children():
		var n = attractor.get_index() - floor(attractorsCount / 2)
		
		var vec = Vector2.DOWN.rotated(0.3 * n) * 80.0
		var result = space2d.intersect_ray(startPos, startPos + vec, [], 1)
		
		if result:
			var finalPos = result.position + Vector2.UP.normalized() * 10.0
			var finalPos2 = finalPos - vec.normalized() * 30.0 
			attractor.global_position = finalPos
			$Attractors2.get_child(attractor.get_index()).global_position = finalPos2
		else:
			var finalPos = startPos + vec + Vector2.UP.normalized() * 10.0
			var finalPos2 = finalPos - vec.normalized() * 30.0 
			attractor.global_position = finalPos
			$Attractors2.get_child(attractor.get_index()).global_position = finalPos2
	
#	for attractor in$Attractors2.get_children():
#		var n = attractor.get_index() - floor(attractorsCount / 2)
#
#		var vec = Vector2.DOWN.rotated(0.2 * n) * 240.0
#		var result = space2d.intersect_ray(startPos, startPos + vec, [], 1)
#
#		var finalPos = result.position + Vector2.UP.normalized() * 60.0
#		attractor.global_position = finalPos
#
	

func _physics_process(delta):
#	if bendingCtrl.attractMode == true:
	var targetPos = player.global_position + Vector2(0.0, 24.0)
	for cell in cellsForJump:
		if is_instance_valid(cell):
			var vec = targetPos - cell.global_position
			var vel = vec.normalized() * clamp(vec.length_squared(), 0.0, 120.0)
			cell.impulse(vel)
		else:
			cellsForJump.erase(cell)

	if Input.is_action_just_pressed("jump"):
		if cellsForJump.size() > 0:
			
			cellsCloseToPlayer = 0
			for cell in cellsForJump:
				cell.enableGravity()
				cell.resetDamp()
				
				var vec = cell.global_position - player.global_position
				
				var vel = vec.normalized().rotated(rand_range(-0.2, 0.2)) * rand_range(30.0, 40.0)
				
				var cellDis = (cell.global_position - targetPos).length_squared()
				if cellDis < 484.0:
					cellsCloseToPlayer += 1
				
				cell.linear_velocity = vel * 10.0
#					cell.contact_monitor = true
#					cell.contacts_reported = 3
#					cell.connect("body_entered", self, "onCellCollision", [cell])
				var timer = get_tree().create_timer(0.3)
				timer.connect("timeout", self, "onCellTimeout", [cell])
				
			
#				inactiveCells = cellsForJump
#			var power = (cellsForJump.size() / 20.0)
			var power = (cellsCloseToPlayer / 20.0)
			
			var jumpPower = 480.0
#			if player.linearVelocity.y < 0.0:
#				player.linearVelocity = player.linearVelocity * Vector2(1.0, 0.3)
#				player.linearVelocity.y *= 0.3

#			player.impulse(Vector2.UP * jumpPower *  pow(power, 0.7))
			player.jump(jumpPower *  pow(power, 0.7))
			
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

func getCellsFromAttractors():
	
	var cells = []
	for attractor in $Attractors.get_children():
		cells.append_array(attractor.get_overlapping_bodies())
		
	for attractor in $Attractors2.get_children():
		cells.append_array(attractor.get_overlapping_bodies())
	
	var finalCells = {}
	for cell in cells:
		if cell.getColorId() == 0:
			finalCells[cell.get_instance_id()] = cell
	
	return finalCells.values()

func enableJumpMode():
	if jumpMode == false:
		jumpMode = true
#		var cells = bendingCtrl.detachRandomCells(20)
		var allCellsFromGround = getCellsFromAttractors()
#		var cells = Utils.getRandomElementsFromArray(allCellsFromGround, 20)
		var cells = allCellsFromGround
		cellsForJump = cells
		for cell in cellsForJump:
			cell.disableGravity()
			cell.linear_damp = 8.0
			cell.changeColor(5)

func disableJumpMode():
	if jumpMode == true:
		jumpMode = false
		for cell in cellsForJump:
			cell.enableGravity()
			cell.resetDamp()
			cell.changeColor(0)
#			bendingCtrl.addCellToAttracted(cell, true)
		cellsForJump = []
