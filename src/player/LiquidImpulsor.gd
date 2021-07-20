extends Area2D

func _ready():
	connect("body_entered", self, "onBodyEntered")

func onBodyEntered(body):
	if body is Liquid:
		var player = get_parent()
		var vel = -player.linear_velocity
		body.impulse(vel)
