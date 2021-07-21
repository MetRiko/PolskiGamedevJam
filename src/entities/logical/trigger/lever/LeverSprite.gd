extends AnimatedSprite

var bw = true

func on_off():
	play("default",bw)



func on_on():
	play("default",not bw)
