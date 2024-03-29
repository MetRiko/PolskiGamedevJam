extends Area2D

#func _ready():
#	connect("body_entered", self, "onBodyEntered")

onready var player = get_parent()
onready var liquidImpulsor = player.get_node("LiquidImpulsor")

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body is Liquid:
			if body.getColorId() == 0:
				_updateCell(body)

#func onBodyEntered(body):
#	if body is Liquid:
#		_updateCell(body)

func _updateCell(body):
	
	var cellVec = body.global_position - liquidImpulsor.global_position
	var velVec = player.linearVelocity
#	velVec.y *= 2.0
	
	var dot = cellVec.dot(velVec)

	var power = sqrt(velVec.length())
	if power < 4.0:
		power = 4.0

	var vel = velVec.normalized() * power

#	print(dot)
#	body.impulse(sign(dot) * vel * 5.0)
	body.linear_velocity = sign(dot) * vel * 16.0
	

##		var vel = -player.linear_velocity
##		vel.y = -abs(vel.y)
##		vel.x *= 0.5
##
#		var vec = body.global_position - player.global_position
##		var l = sqrt(vec.length())
##		vec = vec.normalized() * pow(l / 3, 0.2) * 1.0
##
##		var finalVel = (vel + vec) * 0.5
##
##		body.impulse(finalVel * 2.0)
##
#
#		if vec.length() > 8.0:
#			return
#
#		var vel = -player.linear_velocity
#		vel.y = -abs(vel.y)
##		vel.x *= 0.5
#
#		var dis = pow(vel.length(), 0.5)
##		print(dis)
#		if dis > 12.0:
#			dis = 12.0
#		vel = vel.normalized() * dis
#
#
##		body.impulse(vel * 20.0)
#		body.linear_velocity = vel * 16.0
