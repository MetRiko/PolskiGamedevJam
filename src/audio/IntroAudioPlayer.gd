extends Area2D


func _ready():
	connect("body_entered", self, "onBodyEntered")
	
func onBodyEntered(body):
	if body is Player:
		Game.getSoundController().playNextIntroSound()
		queue_free()
