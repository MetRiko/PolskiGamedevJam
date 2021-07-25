extends PhysicsBody2D
class_name Damagable

var hp = 1.0

var killed = false

var bazookaOnly = false

func setBazookaOnly(flag):
	bazookaOnly = flag

func setHp(value):
	hp = max(value, 0.0)
	if hp == 0 and killed == false:
		killed = true
		kill()

func isBazookaOnly():
	return bazookaOnly

func doDamage(value, hitDir):
	setHp(hp - value)
		
func kill():
	pass
	
