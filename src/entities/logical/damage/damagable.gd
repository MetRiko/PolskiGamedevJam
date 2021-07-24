extends Node2D
class_name Damagable

var hp = 1.0

var killed = false

var bazookaOnly = true

func isBazookaOnly():
	return bazookaOnly

func doDamage(value):
	hp = min(hp - value, 0.0)
	if hp == 0 and killed == false:
		killed = true
		kill()
		
func kill():
	pass
	
