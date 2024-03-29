extends KinematicBody2D
class_name Player



var maxSpeed := 200.0
var gravityForce := 12.0
var jumpPower := 240.0

var isOnFloor := false
var isOnFloorAfterMove := false

var gravityEnabled := true
var controlsEnabled := true
var frictionEnabled := true

var dir := Vector2()

var forces = []
var damp = 1.0

var impulsesToApply = []

var linearVelocity : Vector2 setget setLinearVelocity, getLinearVelocity 

func switchControls(flag : bool):
	controlsEnabled = flag

func switchGravity(flag : bool):
	gravityEnabled = flag
	
func switchFriction(flag : bool):
	frictionEnabled = flag
	
func resetDamp():
	damp = 1.0

func setDamp(value):
	damp = value

func setLinearVelocity(value : Vector2):
	forces = [value]
	linearVelocity = Vector2()
	
func getLinearVelocity():
	return linearVelocity

var latestVel := Vector2()
var damageFromSpikes = false
var spikesKnockback := Vector2()

func _updateForces(delta):
	for imp in impulsesToApply:
		forces.append(imp)
	impulsesToApply = []
	
	var finalVel = Vector2()
	for force in forces:
		finalVel += force * delta * 60.0
	forces = []
	
	linearVelocity += finalVel 
	linearVelocity = linearVelocity.normalized() * max(linearVelocity.length() - damp * delta * 60.0, 0.0)
	var slide = move_and_slide(linearVelocity, Vector2.UP)
	
	isOnFloorAfterMove = is_on_floor() || $GroundDetector.get_overlapping_bodies().size() > 0
	
	latestVel = linearVelocity
	spikesKnockback = Vector2()
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var normal = collision.normal
		var vel = -linearVelocity.project(-normal)
		linearVelocity += vel

		_updateCollisionWithObjects(collision, delta)
	
	if damageFromSpikes == true:
		damageFromSpikes = false
		var damaged = Game.getWorld().getGameplay().damagePlayer(4.0, spikesKnockback)
		if damaged == true:
			# Animation damage
			$DamageTween.interpolate_property($Sprite, "modulate:r", null, 5.0, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
			$DamageTween.start()
			yield($DamageTween, "tween_all_completed")
			$DamageTween.interpolate_property($Sprite, "modulate:r", null, 1.0, 0.2, Tween.TRANS_SINE, Tween.EASE_IN)
			$DamageTween.start()

func _updateCollisionWithObjects(collision, delta):
	if collision:
		var collider = collision.collider
		if collider != null:
			var normal = collision.normal
			var spikeBit = collider.get_collision_layer_bit(6)
			if spikeBit == true:
#				linearVelocity += normal * 150.0 * delta * 60.0 #linearVelocity.length()
				spikesKnockback += normal * 150.0# * delta * 60.0
				damageFromSpikes = true
				

func impulse(vel):
	impulsesToApply.append(vel)

func _physics_process(delta):
	
	var prevIsOnFloor = isOnFloor
	isOnFloor = isOnFloorAfterMove
	if isOnFloor == false and prevIsOnFloor == true:
		if $JumpTimer.is_stopped() == true:
			$CoyoteTimer.start()
	
	_updateHorizontalMovement(delta)
	_updateJump(delta)
	_updateHigherJump()
	if gravityEnabled == true:
		_updateGravity(delta)
		
	_updateForces(delta)

func _updateHorizontalMovement(delta):
	dir = Vector2()
	
	if controlsEnabled == true:
		if Input.is_action_pressed("move_left"):
			dir.x -= 1.0
		if Input.is_action_pressed("move_right"):
			dir.x += 1.0
		if Input.is_action_pressed("move_down"):
			impulse(Vector2.DOWN * 30.0)

	if floor(dir.x) != 0:
		var currSpeed = abs(linearVelocity.x)
#		var currSpeed = linear_velocity.length()
		var vel = dir * (maxSpeed - min(currSpeed, maxSpeed)) * 0.08
		impulse(vel)
#		if isOnFloor == true and prevIsOnFloor == true:
#			impulse(Vector2.UP * 3.0)
	elif frictionEnabled == true:
		var currSpeed = abs(linearVelocity.x)
#		var currSpeed = linear_velocity.length()
		if currSpeed > 5.0:
			var vel = Vector2()
			if isOnFloor == true:
				vel = Vector2.LEFT * sign(linearVelocity.x) * (maxSpeed - min(currSpeed, maxSpeed)) * 0.07
			else:
				vel = Vector2.LEFT * sign(linearVelocity.x) * (maxSpeed - min(currSpeed, maxSpeed)) * 0.02
			impulse(vel)
#		else:
#			linear_velocity.x = 0.0

func jump(power, higherJump := false):
	linearVelocity.y = 0.0
	impulse(Vector2.UP * power)
	if higherJump == true:
		$JumpTimer.start()

func _updateJump(delta):
	if controlsEnabled == true:
		if isOnFloor == true or $CoyoteTimer.is_stopped() == false:
			if Input.is_action_pressed("jump"):
				jump(jumpPower * delta * 60.0, true)

func _updateGravity(delta):
	if isOnFloor == false:
		impulse(Vector2.DOWN * gravityForce * delta * 60.0)

func _process(delta):
	_updateAnimations()
	
#	if Input.is_action_just_pressed("lmb"):
#		var vec = get_global_mouse_position() - global_position
#		var vel = vec.normalized() * 600.0
#		dash(vel, 0.3, 30.0)

func _updateHigherJump():
	if controlsEnabled == true:
		if $JumpTimer.is_stopped() == false:
			var timerProgress = 1.0 - ($JumpTimer.time_left / $JumpTimer.wait_time)
			if timerProgress > 0.3:
				if Input.is_action_pressed("jump"):
					impulse(Vector2.UP * 17.0)

func _updateAnimations():

	if dir.x < 0:
		$Sprite.flip_h = true
	elif dir.x > 0:
		$Sprite.flip_h = false

	if isOnFloor == true or $CoyoteTimer.is_stopped() == false:
		if abs(dir.x) > 0:
			$Anim.play("Running", -1, abs(linearVelocity.x) * 0.02)
		else:
			$Anim.play("Idle", -1, 0.75)
	else:
		if linearVelocity.y < 0.0:
			$Anim.play("Jump", -1, 1.0)
		else:
			$Anim.play("Fall", -1, 1.0)
	
func _ready():
	$DashTimer.connect("timeout", self, "_onDashTimer")

var latestDashArgs = []

func dash(vel, disableTime := 0.2, dampForDash := 1.0):
	latestDashArgs = [vel, disableTime, dampForDash]
	# gravity disable
	switchGravity(false)
	# damp changed
	setDamp(dampForDash)
	# controls disable
	switchControls(false)
	# reset velocity
	linearVelocity = Vector2()
	# impulse
	impulse(vel)
	# disable time
	$DashTimer.wait_time = disableTime
	$DashTimer.start()

var latestVel2 = Vector2()

func _onDashTimer():
	resetDamp()
	switchGravity(true)
	switchControls(true)
	latestDashArgs = []

func pauseHigherJump():
	$JumpTimer.paused = true
	$DashTimer.paused = true
	latestVel2 = linearVelocity
	
func resumeHigherJump():
	$JumpTimer.paused = false
	$DashTimer.paused = false
	if $DashTimer.time_left > 0:
		switchControls(false)
		switchGravity(false)
		setDamp(latestDashArgs[2])
		linearVelocity = latestVel2
		
#	if latestDashArgs.size() > 0:
#		dash(latestDashArgs[0], latestDashArgs[1], latestDashArgs[2])
		
		
#var speed := 160.0
#var jumpPower := 150.0
#
#var isOnFloor := false
#
#var isMoving := false
#var isMovingLeft := false
#var canJump := false
#
#var currSpeed := 0.0 
#
#var moveDirState := 0
#
#var maxSpeed = 200.0
#
#var dir := Vector2()
#
#func impulse(vel):
#	apply_central_impulse(vel)
#
##func changeMoveDirState(state):
##	if moveDirState != state:
##		moveDirState = state
##
##		if 
#
##var prevLinearVel := Vector2()
#
##func _integrate_forces(state):
###    var force = state.get_linear_velocity() / state.get_inverse_mass() / state.get_step()
##
##	if state.get_contact_count() > 0:
##		var dv : Vector2 = state.linear_velocity - prevLinearVel
##		var collisionForce = dv / (state.inverse_mass * state.step)
##		print(state.linear_velocity)
##		var isOnFloor = $GroundDetector.get_overlapping_bodies().size() > 0
##		if isOnFloor == true:
##			linear_velocity = Vector2.RIGHT * sign(linear_velocity.x) * linear_velocity.length()
##
##	prevLinearVel = state.linear_velocity
#
#
#func _physics_process(delta):
#
#	var prevIsOnFloor = isOnFloor
#	isOnFloor = $GroundDetector.get_overlapping_bodies().size() > 0
#	if isOnFloor == false and prevIsOnFloor == true:
#		$CoyoteTimer.start()
#	if isOnFloor == true and prevIsOnFloor == false:
#		linear_velocity.y = 0.0
##		impulse(Vector2.UP * abs(linear_velocity.y) * 2.0)
#
#	dir = Vector2()
#	if Input.is_action_pressed("move_left"):
#		dir.x -= 1.0
#
#	if Input.is_action_pressed("move_right"):
#		dir.x += 1.0
#
#	if isOnFloor == true or $CoyoteTimer.is_stopped() == false:
#		if Input.is_action_just_pressed("jump"):
#			set_axis_velocity(Vector2.UP * 220.0)
##			set_axis_velocity(Vector2.UP)
##			linear_velocity.y = 0
##			impulse(Vector2.UP * 220.0)
#			$JumpTimer.start()
#
#
#	if floor(dir.x) != 0:
#		var currSpeed = abs(linear_velocity.x)
##		var currSpeed = linear_velocity.length()
#		var vel = dir * (maxSpeed - min(currSpeed, maxSpeed)) * 0.08
#		impulse(vel)
#		if isOnFloor == true and prevIsOnFloor == true:
#			impulse(Vector2.UP * 3.0)
#	else:
#		var currSpeed = abs(linear_velocity.x)
##		var currSpeed = linear_velocity.length()
#		if currSpeed > 5.0:
#			var vel = Vector2()
#			if isOnFloor == true:
#				vel = Vector2.LEFT * sign(linear_velocity.x) * (maxSpeed - min(currSpeed, maxSpeed)) * 0.07
#			else:
#				vel = Vector2.LEFT * sign(linear_velocity.x) * (maxSpeed - min(currSpeed, maxSpeed)) * 0.02
#			impulse(vel)
##		else:
##			linear_velocity.x = 0.0
#
#func _process(delta):
#
#	_updateHigherJump()
#	_updateAnimations()
#
#func _updateHigherJump():
#	if $JumpTimer.is_stopped() == false:
#		var timerProgress = 1.0 - ($JumpTimer.time_left / $JumpTimer.wait_time)
#		if timerProgress > 0.3:
#			if Input.is_action_pressed("jump"):
#				impulse(Vector2.UP * 18.0)
#
#func _updateAnimations():
#
#	if dir.x < 0:
#		$Sprite.flip_h = true
#	elif dir.x > 0:
#		$Sprite.flip_h = false
#
#	if isOnFloor == true or $CoyoteTimer.is_stopped() == false:
#		if abs(dir.x) > 0:
#			$Anim.play("Running", -1, abs(linear_velocity.x) * 0.02)
#		else:
#			$Anim.play("Idle", -1, 0.75)
#	else:
#		if linear_velocity.y < 0.0:
#			$Anim.play("Jump", -1, 1.0)
#		else:
#			$Anim.play("Fall", -1, 1.0)
#
#
#
##		if linear_velocity.y < 0.0:
##			$Anim.play("Jump", -1, 1.0)
##		else:
##			$Anim.play("Fall", -1, 1.0)
##	else:
##		if isMoving == true:
##			$Anim.play("Running", -1, abs(linear_velocity.x) * 0.02)
##		else:
##			$Anim.play("Idle", -1, 0.75)
#
#
#
##func _physics_process(delta):
##	var dir := Vector2()
##	if Input.is_action_pressed("move_left"):
##		dir.x = -1.0
##	if Input.is_action_pressed("move_right"):
##		dir.x = 1.0
##	if Input.is_action_pressed("move_down"):
##		dir.y = 1.0
##
##	_updateJump()
##
##	isMoving = dir.x != 0
##	if dir.x < 0:
##		isMovingLeft = true
##	elif dir.x > 0:
##		isMovingLeft = false
##
##	if isMoving == false:
##		var vel = Vector2(-linear_velocity.x, 0.0)
##		apply_central_impulse(vel * 0.12)
##
##	currSpeed = sqrt(abs(speed - abs(linear_velocity.x)))
##	if sign(linear_velocity.x) != sign(dir.x):
##		currSpeed = speed * 0.12
##	var vel = dir.normalized() * currSpeed
##
##	apply_central_impulse(vel)
#
##func _process(delta):
##
##	var stateIsOnFloor = $GroundDetector.get_overlapping_bodies().size() > 0
##	setIsOnFloor(stateIsOnFloor)
##
##	$Sprite.flip_h = isMovingLeft
##
##	if isOnFloor == false:
##		if linear_velocity.y < 0.0:
##			$Anim.play("Jump", -1, 1.0)
##		else:
##			$Anim.play("Fall", -1, 1.0)
##	else:
##		if isMoving == true:
##			$Anim.play("Running", -1, abs(linear_velocity.x) * 0.02)
##		else:
##			$Anim.play("Idle", -1, 0.75)
#
##func _integrate_forces(state):
##	var contacts = state.get_contact_count()
###	print(contacts)
###	var stateIsOnFloor = false
###	for i in range(contacts):
###		var normal = state.get_contact_local_normal(i)
###		if normal.x == 0 and normal.y == -1:
####		var angle = normal.angle_to(Vector2.UP)
####		if abs(angle) < 0.35: 
###			stateIsOnFloor = true
###			break
##	var stateIsOnFloor = $GroundDetector.get_overlapping_bodies().size() > 0
##	setIsOnFloor(stateIsOnFloor)
#
##func setIsOnFloor(flag : bool):
##	if flag != canJump:
##		if flag == true:
##			isOnFloor = true
##			canJump = true
##		else:
##			isOnFloor = false
##			yield(get_tree().create_timer(0.1), "timeout")
##			canJump = false
##
##func pauseJumpTimer():
##	$JumpTimer.paused = true
##
##func resumeJumpTimer():
##	$JumpTimer.paused = false
##
##func jump(power : float, longJump : bool = true):
##	linear_velocity.y = -jumpPower
##	if longJump:
##		$JumpTimer.start()
##	else:
##		$JumpTimer.stop()
##
##func _updateJump():
###	print(isOnFloor)
##	if canJump == true:
##		if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("jump"):
##			linear_velocity.y = -jumpPower
###			apply_central_impulse(Vector2.UP * jumpPower)
##			canJump = false
##			$JumpTimer.start()
##	if not $JumpTimer.is_stopped():
##		if Input.is_action_pressed("move_up") or Input.is_action_pressed("jump"):
##			apply_central_impulse(Vector2.UP *  7.0)
