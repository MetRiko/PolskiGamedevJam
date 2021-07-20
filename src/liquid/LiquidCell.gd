extends RigidBody2D
class_name Liquid

func impulse(vel):
	var newVel = Vector2(vel.x, -abs(vel.y))
	apply_central_impulse(newVel)
