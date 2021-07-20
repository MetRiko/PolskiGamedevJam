extends Node2D

const sceneLiquidCell = preload("res://src/liquid/LiquidCell.tscn")

func _ready():
	$Liquid/LiquidCell.queue_free()
	$DebugTimer.connect("timeout", self, "onDebugTimer")

func onDebugTimer():
	if Input.is_action_pressed("num_1"):
		createLiquidCell()

func _process(delta):
	var sprite = $LiquidEffect
	var shader = $LiquidEffect.material
	var pos = get_global_mouse_position()
	shader.set_shader_param("mousePos", pos)
	shader.set_shader_param("globalPos", sprite.global_position)
	shader.set_shader_param("cellsPos", [1, 2, 3])

func createLiquidCell():
	var pos = get_global_mouse_position()
	var cell = sceneLiquidCell.instance()
	$Liquid.add_child(cell)
	cell.global_position = pos
