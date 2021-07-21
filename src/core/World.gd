extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var currentLevel = null
var currentIdx := Vector2(0, 0)
var prevIdx := currentIdx
onready var cameraTween = $CameraTween

var map = {}

func getCamera():
	return $Camera2D
	
func getCurrentLevel():
	return currentLevel

# Called when the node enters the scene tree for the first time.
func _ready():
	var level = $Levels.get_child(0).getLevel()
	
	for l in $Levels.get_children():
		l.getLevel().disable()
		
	_updateMap()
		
	switchLevel(getLevelFromIdx(currentIdx))
#	switchLevel(level)
	
func getPlayer():
	return $Player
	
func switchLevel(level):
	if currentLevel != null:
		currentLevel.disable()

	level.enable()
	var instaCameraSwitch : bool = currentLevel == null
	_setupCamera(level.getBorder(), instaCameraSwitch)
	$Camera2D.setTarget(getPlayer())
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
		
func hashIdx(idx : Vector2) -> int:
	var x = idx.x
	var y = idx.y
	var a = -2*x-1 if x < 0 else 2 * x
	var b = -2*y-1 if y < 0 else 2 * y
	return (a + b) * (a + b + 1) * 0.5 + b

func _setupCamera(border, insta := false):
	var size = border.getRealSize()
	var pos = border.global_position
	var camera = $Camera2D
	
	if insta == false:
		
		var player = getPlayer()
		
		var levelSize = Vector2(1280.0, 720.0) * 0.5
		var currPos = prevIdx * levelSize
		
		camera.limit_left = currPos.x
		camera.limit_top = currPos.y
		camera.limit_right = currPos.x + levelSize.x
		camera.limit_bottom = currPos.y + levelSize.y
		
		var nextPos = currentIdx * levelSize
		
		cameraTween.interpolate_property($Camera2D, "limit_left", null, nextPos.x, 0.8, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		cameraTween.start()
		cameraTween.interpolate_property($Camera2D, "limit_top", null, nextPos.y, 0.8, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		cameraTween.start()
		cameraTween.interpolate_property($Camera2D, "limit_right", null, nextPos.x + levelSize.x, 0.8, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		cameraTween.start()
		cameraTween.interpolate_property($Camera2D, "limit_bottom", null, nextPos.y + levelSize.y, 0.8, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		cameraTween.start()
		
		player.set_physics_process(false)
		player.set_process(false)
		var gravScaleMem = player.gravity_scale
		player.gravity_scale = 0.0
		var velMem = player.linear_velocity
		player.linear_velocity = Vector2(0.0, 0.0)
		player.pauseJumpTimer()
		
		yield(cameraTween, "tween_all_completed")
		
		player.resumeJumpTimer()
		player.gravity_scale = gravScaleMem
		player.linear_velocity = velMem
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
	if event.is_action_pressed("num_2"):
		switchLevel($Levels.get_child(0).getLevel())
	if event.is_action_pressed("num_3"):
		switchLevel($Levels.get_child(1).getLevel())

func _process(delta):
	$Camera2D._local_process(delta)
	$Postprocess._local_process(delta)
	_updateMovingBetweenLevels()

func convertPosToLevelIdx(pos : Vector2):
	var idx = pos / (Vector2(1280.0, 720.0) * 0.5)
	idx.x = floor(idx.x)
	idx.y = floor(idx.y)
	return idx

func _updateMovingBetweenLevels():
	
	var player = getPlayer()
	
	var idx = convertPosToLevelIdx(player.global_position)

	var nextLevel = getLevelFromIdx(idx)

	if nextLevel != currentLevel:
		currentIdx = idx
		switchLevel(getLevelFromIdx(idx))
	else:
		prevIdx = idx
	
	
	
	
	

