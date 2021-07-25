extends Node2D

func _ready():
	randomize()
	$LoadingSpawnTimer.connect("timeout", self, "_onLoadingTimer")
	$TickTimer.connect("timeout", self, "_onTickTimer")

var spawnningCells = []

func _onTickTimer():
	if $LoadingSpawnTimer.is_stopped() == false:
		var world = Game.getWorld()
		var n = randi() % 5 + 3
		for i in range(n):
#			var ox = rand_range(-1.0, 1.0)
#			var oy = rand_range(-1.0, 1.0)
#			var offset = Vector2(ox, oy)
#			var pos = global_position + offset * rand_range(300.0, 350.0)
			
			var vec = Vector2.UP.rotated(rand_range(-1.2, 1.2))
			var pos = global_position + vec * 180.0
			var cell = world.createLiquidCell(pos)
			
			cell.gravity_scale = 0.0
			cell.intencity = 0.8
			spawnningCells.append(cell)
#			cell.linear_velocity = offset.normalized() * rand_range(300.0, 400.0)

func _physics_process(delta):
	if spawnningCells.size() > 0:
		for cell in spawnningCells:
			var vec = (global_position - cell.global_position)
			var power = pow(vec.length() / 10.0, 0.8)
			cell.impulse(vec.normalized() * power * 10.0)

func killPlayer():
	var player = Game.getPlayer()
	var world = Game.getWorld()
	
	player.visible = false
	player.switchControls(false)
	player.switchGravity(false)
	player.linearVelocity = Vector2()
	world.getBendingController().disableAllTechniques()

	for i in range(30.0):
#		var ox = rand_range(-1.0, 1.0) * 3.0
#		var oy = rand_range(-1.0, 1.0) * 3.0
		
		var offset = Vector2.RIGHT.rotated(rand_range(-PI * 2.0, PI * 2.0)) * 10.0
		
#		var offset = Vector2(ox, oy)
		var cell = world.createLiquidCell(player.global_position + offset)
		cell.intencity = 0.8
		cell.disableGravity()
		cell.impulse(offset.normalized() * rand_range(300.0, 400.0) * 1.2)
		cell.linear_damp = 2.2
		
func _explode():
	for cell in spawnningCells:
		var vec = Vector2.UP.rotated(rand_range(-PI * 0.7, PI * 0.7)) * 10.0
#		var vec = (global_position - cell.global_position)
#		var power = pow(vec.length() / 10.0, 2.0)
		var power = pow(rand_range(0.4, 1.0), 2.0) * 2000.0
		cell.impulse(vec.normalized() * power)
		cell.intencity = 1.0
		cell.enableGravity()
	spawnningCells = []

func _onLoadingTimer():
	
	yield(get_tree().create_timer(0.6), "timeout")
	var player = Game.getPlayer()
	_explode()
	player.switchControls(true)
	player.switchGravity(true)
	player.visible = true
	var world = Game.getWorld()
	world.getBendingController().enableAllTechniques()
	world.getGameplay().restoreFullHp()

func spawnPlayer():
	var player = Game.getPlayer()
	var gameplay = Game.getWorld().getGameplay()
	var world = Game.getWorld()
	
	var idx = world.convertPosToLevelIdx(global_position)
	var level = world.getLevelFromIdx(idx)
	player.global_position = global_position
	world.switchLevel(level, true)

	yield(get_tree().create_timer(1.2), "timeout")
	spawnningCells = []
	$LoadingSpawnTimer.start()
	
#	gameplay.restoreFullHp()
