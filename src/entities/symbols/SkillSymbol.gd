extends Node2D

export var skillId := 0

var cells = []

func _ready():
	randomize()
	$Timer.connect("timeout", self, "onTimer")

func spawn():
	var bendingCtrl = Game.getWorld().getBendingController()
	var skillUnlocked = bendingCtrl.isSkillUnlocked(skillId)
	$Sprite.frame = skillId
	$Sprite.visible = skillUnlocked

	var intencity = 1.2 if skillUnlocked else 0.8

	cells = []
	var world = Game.getWorld()
	for i in range(15):
		var ox = rand_range(-1.0, 1.0)
		var oy = rand_range(-1.0, 1.0)
		var offset = Vector2(ox, oy)
		var cell = world.createLiquidCell(global_position + offset)
		cell.gravity_scale = 0.0
#		cell.changeColor(6)
		cell.thickness = 30.0
		cell.intencity = intencity
		cells.append(cell)
	
func _physics_process(delta):
	for cell in cells:
		if is_instance_valid(cell):
			var vec = (global_position - cell.global_position)
			var power = pow(vec.length() / 10.0, 2.0)
			cell.impulse(vec.normalized() * power)

func onTimer():
	for cell in cells:
		if is_instance_valid(cell):
			cell.impulse(Vector2.LEFT.rotated(rand_range(0.0, 2 * PI)) * 80.0)
	
