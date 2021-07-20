extends RigidBody2D

var speed := 160.0
var jumpPower := 150.0

var isOnFloor := false

var isMoving := false
var isMovingLeft := false
var canJump := false

var currSpeed := 0.0 

func _physics_process(delta):
	var dir := Vector2()
	if Input.is_action_pressed("move_left"):
		dir.x = -1.0
	if Input.is_action_pressed("move_right"):
		dir.x = 1.0
	if Input.is_action_pressed("move_down"):
		dir.y = 1.0
		
	_updateJump()
	
	isMoving = dir.x != 0
	if dir.x < 0:
		isMovingLeft = true
	elif dir.x > 0:
		isMovingLeft = false
		
	if isMoving == false:
		var vel = Vector2(-linear_velocity.x, 0.0)
		apply_central_impulse(vel * 0.12)
		
	currSpeed = sqrt(abs(speed - abs(linear_velocity.x)))
	if sign(linear_velocity.x) != sign(dir.x):
		currSpeed = speed * 0.12
	var vel = dir.normalized() * currSpeed
	
#
#	if abs(linear_velocity.x) < 4.0:
#		apply_central_impulse(Vector2(sign(dir.x) * speed, 0.0))
#	else:
#		var velSign = sign(linear_velocity.x)
#		var boost = clamp(abs(linear_velocity.x) / 10.0, 0.0, 1.0)
#		var vel = Vector2(boost * dir.x * speed * 0.05, 0.0)
#
#	var currVel = vel * clamp(linear_velocity.length() * 0.1 - 20.0, 0.0, 20.0)
	
	apply_central_impulse(vel)

func _process(delta):
	
	var stateIsOnFloor = $GroundDetector.get_overlapping_bodies().size() > 0
	setIsOnFloor(stateIsOnFloor)
	
	$Sprite.flip_h = isMovingLeft
	
	if isOnFloor == false:
		if linear_velocity.y < 0.0:
			$Anim.play("Jump", -1, 1.0)
		else:
			$Anim.play("Fall", -1, 1.0)
	else:
		if isMoving == true:
			$Anim.play("Running", -1, abs(linear_velocity.x) * 0.02)
		else:
			$Anim.play("Idle", -1, 0.75)

#func _integrate_forces(state):
#	var contacts = state.get_contact_count()
##	print(contacts)
##	var stateIsOnFloor = false
##	for i in range(contacts):
##		var normal = state.get_contact_local_normal(i)
##		if normal.x == 0 and normal.y == -1:
###		var angle = normal.angle_to(Vector2.UP)
###		if abs(angle) < 0.35: 
##			stateIsOnFloor = true
##			break
#	var stateIsOnFloor = $GroundDetector.get_overlapping_bodies().size() > 0
#	setIsOnFloor(stateIsOnFloor)
		
func setIsOnFloor(flag : bool):
	if flag != canJump:
		if flag == true:
			isOnFloor = true
			canJump = true
		else:
			isOnFloor = false
			yield(get_tree().create_timer(0.1), "timeout")
			canJump = false

func _updateJump():
#	print(isOnFloor)
	if canJump == true:
		if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("jump"):
			linear_velocity.y = -jumpPower
#			apply_central_impulse(Vector2.UP * jumpPower)
			canJump = false
			$JumpTimer.start()
	if not $JumpTimer.is_stopped():
		if Input.is_action_pressed("move_up") or Input.is_action_pressed("jump"):
			apply_central_impulse(Vector2.UP *  7.0)
