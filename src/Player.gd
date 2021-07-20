extends RigidBody2D

var speed := 140.0
var jumpPower := 330.0

var isOnFloor := false

func _physics_process(delta):
	var dir := Vector2()
	if Input.is_action_pressed("move_left"):
		dir.x = -1.0
	if Input.is_action_pressed("move_right"):
		dir.x = 1.0
	if Input.is_action_pressed("move_down"):
		dir.y = 1.0
		
	_updateJump()
		
	var currSpeed = sqrt(abs(speed - abs(linear_velocity.x)))
	if sign(linear_velocity.x) != sign(dir.x):
		currSpeed = speed * 0.1
	var vel = dir.normalized() * currSpeed
	
#	var currVel = vel * clamp(linear_velocity.length() * 0.1 - 20.0, 0.0, 20.0)
	
	apply_central_impulse(vel)

func _integrate_forces(state):
	var contacts = state.get_contact_count()
#	print(contacts)
	var stateIsOnFloor = false
	for i in range(contacts):
		var normal = state.get_contact_local_normal(i)
		if normal.x == 0 and normal.y == -1:
#		var angle = normal.angle_to(Vector2.UP)
#		if abs(angle) < 0.35: 
			stateIsOnFloor = true
			break
	setIsOnFloor(stateIsOnFloor)
		
func setIsOnFloor(flag : bool):
	if flag != isOnFloor:
		if flag == true:
			isOnFloor = true
		else:
			yield(get_tree().create_timer(0.25), "timeout")
			isOnFloor = false

func _updateJump():
	print(isOnFloor)
	if isOnFloor == true:
		if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("jump"):
			apply_central_impulse(Vector2.UP * jumpPower)
