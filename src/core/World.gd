extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const sceneLiquidCell = preload("res://src/liquid/LiquidCell.tscn")

var currentLevel = null
var currentIdx := Vector2(0, 0)
var prevIdx := currentIdx
onready var cameraTween = $CameraTween

var levelSwitchingEnabled = false

var idxOffsetBetweenLevels := Vector2(0, 0)

var map = {}

func getCamera():
	return $Camera2D
	
func getCurrentLevel():
	return currentLevel

func getBendingController():
	return $BendingController

func getGameplay():
	return $Gameplay

func killPlayer():
	$PlayerSpawner.killPlayer()
	
func respawnPlayer():
	$PlayerSpawner.spawnPlayer()

func getLiquidCells():
	return $Liquid/LiquidCells.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	var level = $Levels.get_child(0).getLevel()
	
	for l in $Levels.get_children():
		l.getLevel().disable()
		
	_updateMap()
	_copyTilesToLevels()
	_moveSpawnersToLevels()
	
	currentIdx = convertPosToLevelIdx(getPlayer().global_position)
	prevIdx = currentIdx
	
	var nextLevel = getLevelFromIdx(currentIdx)
	
	levelSwitchingEnabled = true
	
	switchLevel(nextLevel)
	
	$BendingController.getIndicator().global_position = getPlayer().global_position
	
	$Camera2D.setTarget(getPlayer())
	
	$Liquid/LiquidDebugTimer.connect("timeout", self, "_onLiquidDebugTimer")
	
	$Gameplay.connect("player_died", self, "_onPlayerDied")
	
func _onPlayerDied():
	killPlayer()
	
#	switchLevel(level)

func _moveSpawnersToLevels():
	for spawner in $Spawners.get_children():
		var idx = convertPosToLevelIdx(spawner.global_position)
		var level = getLevelFromIdx(idx)
		var mem = spawner.global_position
		spawner.get_parent().remove_child(spawner)
		level.addSpawner(spawner)
		spawner.global_position = mem
		
	for spawner in $Symbols.get_children():
		var idx = convertPosToLevelIdx(spawner.global_position)
		var level = getLevelFromIdx(idx)
		var mem = spawner.global_position
		spawner.get_parent().remove_child(spawner)
		level.addSpawner(spawner)
		spawner.global_position = mem
	
func _onLiquidDebugTimer():
	if Input.is_action_pressed("num_1"):
		createLiquidCell(get_global_mouse_position())

func createLiquidCell(pos : Vector2):
#	print(pos)
	var cell = sceneLiquidCell.instance()
	$Liquid/LiquidCells.add_child(cell)
	cell.global_position = pos
#	print($Liquid/LiquidCells.get_child_count())
	return cell

	
func getPlayer():
	return $Player
	
func switchLevel(level, instaCamera : bool = false):
	if level != currentLevel:
		if currentLevel != null:
			currentLevel.disable()

		level.enable()
		var instaCameraSwitch : bool = currentLevel == null or instaCamera
		_setupCamera(level.getBorder(), instaCameraSwitch)
	#	$Camera2D.setTarget(getPlayer())
		
		for cell in getLiquidCells():
			if cell.getColorId() == 0:
				cell.queue_free()
				
		level.spawnAll()

		currentLevel = level

func getLevelFromIdx(idx : Vector2):
	var hashedIdx = hashIdx(idx)
	var level = map[hashedIdx]
	return level

func _updateMap():
	map = {}
	
	for localizator in $Levels.get_children():
		var baseIdx = Vector2(localizator.idxX, localizator.idxY)
		var level = localizator.getLevel()
		var border = level.getBorder()
		
		for xo in range(border.width):
			for yo in range(border.height):
				var idx = hashIdx(Vector2(baseIdx.x + xo, baseIdx.y + yo))
				map[idx] = level
		
func _copyTilesToLevels():
	
	var localizators = $Levels.get_children()
	
	var windowSize = Vector2(1280, 736)
	var tilesAmountOnScreen = windowSize * 0.5 / 16
	
	var mainTileMap = $MainTileMap
	
	for localizator in localizators:
		
		var levelIdx = localizator.getIdx()
		var level = localizator.getLevel()
		var border = level.getBorder()
		var size = border.getSize()
		
		var tilesAmountOnLevel = tilesAmountOnScreen * size
		var startTilesIdx = levelIdx * tilesAmountOnScreen
		
		var levelTileMap = level.getTileMap()
		
		levelTileMap.clear()
				
		for x in range(tilesAmountOnLevel.x + 2):
			for y in range(tilesAmountOnLevel.y + 2):
				var ox = x - 1
				var oy = y - 1
				var tileId = mainTileMap.get_cell(startTilesIdx.x + ox, startTilesIdx.y + oy)
				levelTileMap.set_cell(ox, oy, tileId)
				
		levelTileMap.update_bitmask_region()
	
	mainTileMap.clear()

		
func hashIdx(idx : Vector2) -> int:
	var x = idx.x
	var y = idx.y
	var a = -2*x-1 if x < 0 else 2 * x
	var b = -2*y-1 if y < 0 else 2 * y
	return (a + b) * (a + b + 1) * 0.5 + b

func _closePosInView(point : Vector2, levelPos : Vector2, levelSize : Vector2):
	var roomSize = Vector2(1280.0, 736.0) * 0.5
	var viewStartPos = levelPos + roomSize * 0.5
	var viewEndPos = levelPos + levelSize - roomSize * 0.5
	var closedPoint = Vector2()
	closedPoint.x = clamp(point.x, viewStartPos.x, viewEndPos.x)
	closedPoint.y = clamp(point.y, viewStartPos.y, viewEndPos.y)
	return closedPoint

func _setupCamera(border, insta := false):
	var size = border.getRealSize()
	var pos = border.global_position
	var camera = $Camera2D
	
	if insta == false:
		
		var player = getPlayer()
		
		var levelSize = Vector2(1280.0, 736.0) * 0.5
		var currPos = prevIdx * levelSize
		
#		camera.limit_left = currPos.x
#		camera.limit_top = currPos.y
#		camera.limit_right = currPos.x + levelSize.x
#		camera.limit_bottom = currPos.y + levelSize.y
		
#		camera.limit_left = min(camera.limit_left, pos.x)
#		camera.limit_top = min(camera.limit_top, pos.y)
#		camera.limit_right = max(camera.limit_right, pos.x + size.x)
#		camera.limit_bottom = max(camera.limit_bottom, pos.y + size.y)
		
		var nextLimitLeft = min(camera.limit_left, currPos.x)
		var nextLimitTop = min(camera.limit_top, currPos.y)
		var nextLimitRight = max(camera.limit_right, currPos.x + levelSize.x)
		var nextLimitBottom = max(camera.limit_bottom, currPos.y + levelSize.y)
		
		var nextPos = currentIdx * levelSize
		
		var idxOffset = currentIdx - prevIdx
		
		camera.limit_left = -100000.0
		camera.limit_top = -100000.0
		camera.limit_right = 100000.0
		camera.limit_bottom = 100000.0

#		var startCameraPos = prevIdx * levelSize + levelSize * 0.5
#		var endCameraPos = currentIdx * levelSize + levelSize * 0.5
		
#		var startCameraPos = prevIdx * levelSize + levelSize * 0.5
#		var startCameraPos = camera.global_position# - idxOffset * levelSize * 0.5
#		var startCameraPos = camera.get_camera_screen_center() #+ idxOffset * levelSize * 0.5# - idxOffset * levelSize * 0.5 #camera.global_position# - idxOffset * levelSize * 0.5
#		var endCameraPos = camera.get_camera_screen_center() + idxOffset * levelSize
#		var endCameraPos = camera.global_position + idxOffset * levelSize * 0.5
		
		var startCameraPos = camera.get_camera_screen_center()
		var endCameraPos = _closePosInView(camera.global_position + idxOffset * levelSize * 0.5, pos, size)
		
#		if idxOffset.x > 0:
#			camera.limit_right += levelSize.x
#		elif idxOffset.x < 0:
#			camera.limit_left -= levelSize.x
#		elif idxOffset.y > 0:
#			camera.limit_bottom += levelSize.y
#		elif idxOffset.y < 0:
#			camera.limit_top -= levelSize.y
		
		camera.global_position = startCameraPos
		
		camera.setTarget(null)
		
		player.pauseHigherJump()
		
		cameraTween.remove_all()
		cameraTween.interpolate_property($Camera2D, "global_position", startCameraPos, endCameraPos, 0.8, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		cameraTween.start()
		
#		cameraTween.remove_all()
#		cameraTween.interpolate_property($Camera2D, "limit_left", null, nextLimitLeft, 0.8, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#		cameraTween.start()
#		cameraTween.interpolate_property($Camera2D, "limit_top", null, nextLimitTop, 0.8, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#		cameraTween.start()
#		cameraTween.interpolate_property($Camera2D, "limit_right", null, nextLimitRight, 0.8, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#		cameraTween.start()
#		cameraTween.interpolate_property($Camera2D, "limit_bottom", null, nextLimitBottom, 0.8, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#		cameraTween.start()
		
		player.set_physics_process(false)
		player.set_process(false)
		player.switchGravity(false)
		player.switchControls(false)
		var velMem = player.linearVelocity
		player.linearVelocity = Vector2(0.0, 0.0)
		
		yield(cameraTween, "tween_all_completed")
		
		player.resumeHigherJump()
		camera.setTarget(player)
		player.switchControls(true)
		player.switchGravity(true)
		player.linearVelocity = velMem
		player.set_physics_process(true)
		player.set_process(true)
		
		camera.limit_left = pos.x
		camera.limit_top = pos.y
		camera.limit_right = pos.x + size.x
		camera.limit_bottom = pos.y + size.y
		
	else:
		camera.limit_left = pos.x
		camera.limit_top = pos.y
		camera.limit_right = pos.x + size.x
		camera.limit_bottom = pos.y + size.y
	
func _input(event):
	pass
#	if event.is_action_pressed("num_2"):
#		switchLevel($Levels.get_child(0).getLevel())
#	if event.is_action_pressed("num_3"):
#		switchLevel($Levels.get_child(1).getLevel())
#	if event.is_action_pressed("num_2"):
#		var camera = $Camera2D
#		camera.target = null
#
#		var roomSize = Vector2(1280.0, 736.0) * 0.5
#		var playerIdx = Vector2()
#		playerIdx.x = 
#
#		camera.limit_left = -100000.0
#		camera.limit_top = -100000.0
#		camera.limit_right = 100000.0
#		camera.limit_bottom = 100000.0
#		camera.global_position = currentIdx * Vector2(1280.0, 736.0) * 0.5
		

func _physics_process(delta):
	if Input.is_action_just_pressed("x"):
#		getPlayer().global_position = pos
		var pos = get_global_mouse_position()
		var player = getPlayer()
		player.global_position = pos
		levelSwitchingEnabled = true
#		player.sleeping = false

func _process(delta):
	$Camera2D._local_process(delta)
	$Camera2D.force_update_scroll()
	$Postprocess._local_process(delta)
	if levelSwitchingEnabled == true:
		_updateMovingBetweenLevels()
		
	$OrbsCounter.text = "Zebrano modułów zdrowia: %s / %s" % [Game.currHpOrbs, Game.maxHpOrbs]
		

func convertPosToLevelIdx(pos : Vector2):
	var idx = pos / (Vector2(1280.0, 736.0) * 0.5)
	idx.x = floor(idx.x)
	idx.y = floor(idx.y)
	return idx

func _updateMovingBetweenLevels():
	
	var player = getPlayer()
	
	var idx = convertPosToLevelIdx(player.global_position)

	var nextLevel = getLevelFromIdx(idx)

	if nextLevel != currentLevel:
		idxOffsetBetweenLevels = idx - currentIdx
		currentIdx = idx
		switchLevel(getLevelFromIdx(idx))
	else:
		prevIdx = idx
	

