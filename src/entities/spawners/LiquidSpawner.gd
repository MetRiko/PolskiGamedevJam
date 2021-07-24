tool
extends Node2D

const sceneLiquidCell = preload("res://src/liquid/LiquidCell.tscn")

export(int, 1, 50) var vcells := 4 setget setVCells
export(int, 1, 50) var hcells := 4 setget setHCells
export(float, 1.0, 20.0) var span = 6.0 setget setSpan

var offsets = []

func setVCells(value):
	vcells = value
	update()

func setHCells(value):
	hcells = value
	update()
	
func setSpan(value):
	span = value
	update()

func _ready():
	update()

func _process(delta):
	pass
#	_editorProcess()

func _draw():
	_editorDraw()

func spawn():
	spawnCells()

func spawnCells():
	var world = Game.getWorld()
	for x in range(hcells):
		for y in range(vcells):
			var offset = Vector2((x - hcells + 1.0) * 0.5, (y - vcells + 1.0) * 0.5) * span
			var pos = global_position + offset + Vector2(rand_range(-2.0, 2.0), rand_range(-2.0, 2.0))
			world.createLiquidCell(pos)
			
	
func _editorDraw():
	if Engine.editor_hint == true:
		for x in range(float(hcells)):
			for y in range(float(vcells)):
				var offset = Vector2((x - hcells * 0.5) + 0.5, (y - vcells * 0.5) + 0.5) * span
				var pos = offset
				draw_circle(pos, 3.0, Color.cyan)





