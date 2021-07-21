extends Node2D
class_name LevelBase

const sceneLiquidCell = preload("res://src/liquid/LiquidCell.tscn")

var enabled = true

#func getPlayer():
#	return $Player

func getLiquidCells():
	return $Liquid/LiquidCells.get_children()

func disable():
	if enabled == true:
		enabled = false
		for cell in getLiquidCells():
			cell.get_parent().remove_child(cell)
			cell.queue_free()
	
func enable():
	if enabled == false:
		enabled = true

func _ready():
	$DebugTimer.connect("timeout", self, "onDebugTimer")

#	liquidEffect.material = liquidEffect.material.duplicate()
	disable()
#	$Liquid/LiquidEffect.visible = true
	
func getBorder():
	return $Border

func onDebugTimer():
	if enabled == true:
		if Input.is_action_pressed("num_1"):
			createLiquidCell()

func createLiquidCell():
	var pos = get_global_mouse_position()
	var cell = sceneLiquidCell.instance()
	$Liquid/LiquidCells.add_child(cell)
	cell.global_position = pos
#	print($Liquid/LiquidCells.get_child_count())

#var cellShape = null
#var bodies = []
#var circlesPos = []

#func _draw():
#	for pos in circlesPos:
#		draw_circle(pos, 2.5, Color.skyblue)

#func _cell_moved(state, index):
#	circlesPos[index] = state.transform.get_origin()
#	update()
#	print('x')

#func createLiquidCell2():
#
#	var pos = get_global_mouse_position()
#
#	if cellShape == null:
#		cellShape = CircleShape2D.new()
#		cellShape.radius = 2.5
#
#	var body = Physics2DServer.body_create()
#	bodies.append(body)
#	circlesPos.append(pos)
#	Physics2DServer.body_set_collision_layer(body, 4)
#	Physics2DServer.body_set_collision_mask(body, 1 + 4)
#	Physics2DServer.body_set_mode(body, Physics2DServer.BODY_MODE_RIGID)
#	Physics2DServer.body_add_shape(body, cellShape)
#	Physics2DServer.body_set_space(body, get_world_2d().space)
#	Physics2DServer.body_set_state(body, Physics2DServer.BODY_STATE_TRANSFORM, Transform2D(0, pos))
#	Physics2DServer.body_set_param(body, Physics2DServer.BODY_PARAM_FRICTION, 0.0)
#	Physics2DServer.body_set_max_contacts_reported(body, 0)
##	Physics2DServer.body_set_force_integration_callback(body, self, "_cell_moved", bodies.size() - 1)
#
##body_set_collision_layer ( RID body, int layer )
#
##body_set_collision_mask ( RID body, int mask )
#
#	print(bodies.size())
	
	
