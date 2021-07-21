extends RigidBody2D
class_name Liquid

func impulse(vel):
#	var newVel = Vector2(vel.x, -abs(vel.y))
	apply_central_impulse(vel)
	
func _ready():
	linear_velocity.y = 10.0
	
#func _process(delta):
#	if linear_velocity.length_squared() < 4.0:
#		sleeping = true
#	else:
#		sleeping = false
	
#func _ready():
#	set_physics_process(false)
	
#func _ready():
#	connect("body_entered", self, "onBodyEntered")
#	$Timer.connect("timeout", self, "onTimer")
#
#var targetCell = null
#
#func onTimer():
#	set_physics_process(false)
#
#func _physics_process(delta):
#
#	if targetCell != null:
#		var vec = targetCell.global_position - global_position
#		vec = vec.normalized() * vec.length_squared()
##		body.apply_central_impulse(-vec * 3.0)
#		apply_central_impulse(vec * 0.1)
#
#func onBodyEntered(body):
#	if body is RigidBody2D:
#		targetCell = body
#		set_physics_process(true)
#		$Timer.start()
##		print('x')
#		return
#		var vec = body.global_position - global_position
#		vec = vec.normalized() * vec.length_squared()
#		body.apply_central_impulse(-vec * 3.0)
#		apply_central_impulse(vec * 3.0)
