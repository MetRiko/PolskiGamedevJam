extends Node2D

onready var liquidEffect = $LiquidEffect
onready var camera = get_parent().getCamera()

func _local_process(delta):
	
	var camera = get_parent().getCamera()
	var level = get_parent().getCurrentLevel()
	var cells = level.getLiquidCells()
	
	liquidEffect.setPosition(camera.get_camera_screen_center() - Vector2(1280.0, 720.0) * 0.25)
	liquidEffect.setCells(cells)
