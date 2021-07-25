extends Node2D

export var skillId := 0

var cells = []

var skillUnlocked = false

func _ready():
	randomize()
	$Timer.connect("timeout", self, "onTimer")
	$Area2D.connect("body_entered", self, "_onBodyEntered")

func spawn(spawnNewCells = true):
	var bendingCtrl = Game.getWorld().getBendingController()
	skillUnlocked = bendingCtrl.isSkillUnlocked(skillId)
	$Sprite.frame = skillId
	$Sprite.visible = not skillUnlocked

	var intencity = 1.2 if skillUnlocked else 0.8
	var thickness = 20.0 if skillUnlocked else 30.0

	if spawnNewCells == true:
		cells = []
		var world = Game.getWorld()
		for i in range(15):
			var ox = rand_range(-1.0, 1.0)
			var oy = rand_range(-1.0, 1.0)
			var offset = Vector2(ox, oy)
			var cell = world.createLiquidCell(global_position + offset)
			cell.gravity_scale = 0.0
	#		cell.changeColor(6)
			cell.thickness = thickness
			cell.intencity = intencity
			cells.append(cell)
	else:
		for cell in cells:
			if is_instance_valid(cell):
				cell.gravity_scale = 0.0
		#		cell.changeColor(6)
				cell.thickness = thickness
				cell.intencity = intencity
	
func _onBodyEntered(body):
	if body is Player:
		if skillUnlocked == false:
			var bendingCtrl = Game.getWorld().getBendingController()
			bendingCtrl.unlockSkill(skillId)
			skillUnlocked = bendingCtrl.isSkillUnlocked(skillId)
			var intencity = 1.2 if skillUnlocked else 0.8
			var thickness = 20.0 if skillUnlocked else 30.0
			$Sprite.visible = not skillUnlocked
	
			for cell in cells:
				if is_instance_valid(cell):
					cell.impulse(Vector2.LEFT.rotated(rand_range(0.0, 2 * PI)) * 800.0)
					cell.gravity_scale = 0.0
			#		cell.changeColor(6)
					cell.thickness = thickness
					cell.intencity = intencity
					
#			cells = []
	
func _physics_process(delta):
	var modif = 1.0
	if skillUnlocked == true:
		modif = 0.1
	for cell in cells:
		if is_instance_valid(cell):
			var vec = (global_position - cell.global_position)
			var power = pow(vec.length() / 10.0, 2.0)
			cell.impulse(vec.normalized() * power * modif)

func onTimer():
	for cell in cells:
		if is_instance_valid(cell):
			cell.impulse(Vector2.LEFT.rotated(rand_range(0.0, 2 * PI)) * 80.0)
	
