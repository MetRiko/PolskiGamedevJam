extends Camera2D

var target = null

func setTarget(target):
	self.target = target
	
func _local_process(delta):
	if target:
		var vec = target.global_position - global_position
		global_position += vec * 0.5
	
