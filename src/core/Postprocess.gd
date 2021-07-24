extends Node2D

onready var liquidEffect = $LiquidEffect
onready var camera = get_parent().getCamera()

onready var world = get_parent()

func _local_process(delta):
	
	var camera = world.getCamera()
	var level = world.getCurrentLevel()
#	var cells = level.getLiquidCells()
	var cells = world.getLiquidCells()
	
	liquidEffect.setPosition(camera.get_camera_screen_center() - Vector2(1280.0, 736.0) * 0.25)
	liquidEffect.setCells(cells)
