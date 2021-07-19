extends RigidBody2D

var speed = 10.0

func _physics_process(delta):
	var dir := Vector2()
	if Input.is_action_pressed("move_left"):
		dir.x = -1.0
	if Input.is_action_pressed("move_right"):
		dir.x = 1.0
	if Input.is_action_pressed("move_down"):
		dir.y = 1.0
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("jump"):
		apply_central_impulse(Vector2.UP * 200.0)
		
	var vel = dir.normalized() * 2.0
	apply_central_impulse(vel)
