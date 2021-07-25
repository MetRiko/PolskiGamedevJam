extends Node2D

export var skillId := 0

var cells = []

#var skillUnlocked = false

var orbPicked = false

func _ready():
	randomize()
	$Timer.connect("timeout", self, "onTimer")
	$Area2D.connect("body_entered", self, "_onBodyEntered")

func spawn(spawnNewCells = true):
	$Sprite.visible = not orbPicked

	var intencity = 1.0 if orbPicked else 0.8
	var thickness = 12.0 if orbPicked else 18.0

	if spawnNewCells == true and orbPicked == false:
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
		if orbPicked == false:
			#add hp
			var world = Game.getWorld()
			var gameplay = world.getGameplay()
			gameplay.addPlayerMaxHp(4.0)
			gameplay.restoreFullHp()
			orbPicked = true
			var intencity = 1.0 if orbPicked else 0.8
			var thickness = 12.0 if orbPicked else 18.0
			$Sprite.visible = not orbPicked
	
			for cell in cells:
				if is_instance_valid(cell):
					cell.impulse(Vector2.UP.rotated(rand_range(-1.7, 1.7)) * 700.0)
					cell.enableGravity()
			#		cell.changeColor(6)
					cell.thickness = thickness
					cell.intencity = intencity
					
#			cells = []
	
func _physics_process(delta):
	var modif = 1.0
	if orbPicked == false:
		modif = 0.1
		for cell in cells:
			if is_instance_valid(cell):
				var vec = (global_position - cell.global_position)
				var power = pow(vec.length() / 10.0, 0.5)
				cell.impulse(vec.normalized() * power * 10.0)

func onTimer():
	if orbPicked == false:
		for cell in cells:
			if is_instance_valid(cell):
				cell.impulse(Vector2.LEFT.rotated(rand_range(0.0, 2 * PI)) * 80.0)
	
