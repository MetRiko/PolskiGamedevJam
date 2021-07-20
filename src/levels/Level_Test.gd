extends Node2D

const sceneLiquidCell = preload("res://src/liquid/LiquidCell.tscn")

func _ready():
	$Liquid/LiquidCell.queue_free()
	$DebugTimer.connect("timeout", self, "onDebugTimer")

func onDebugTimer():
	if Input.is_action_pressed("num_1"):
		createLiquidCell()

func _process(delta):
	var sprite = $LiquidEffect/LiquidEffect
	var shader = sprite.material
	var pos = get_global_mouse_position()
	shader.set_shader_param("mousePos", pos)
	shader.set_shader_param("globalPos", sprite.global_position)

#	var arrayX = []
#	var arrayY = []
	
	var cellsCount = $Liquid.get_child_count()
	
	if cellsCount == 0:
		return
	
	var array = []
	
	for cell in $Liquid.get_children():
		
		var div := int(cell.global_position.x / 255)
		var firstHalf := div
		var secondHalf := int(cell.global_position.x) - (div * 255)
		array.append(firstHalf)
		array.append(secondHalf)
		
	for cell in $Liquid.get_children():
		
		var div := int(cell.global_position.y / 255)
		var firstHalf := div
		var secondHalf := int(cell.global_position.y) - (div * 255)
		array.append(firstHalf)
		array.append(secondHalf)
	
	
	var array_width = cellsCount * 2
	var array_heigh = 2

	var byte_array = PoolByteArray(array)
	var img = Image.new()
	img.create_from_data(array_width, array_heigh, false, Image.FORMAT_R8, byte_array)
	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)
	shader.set_shader_param("cellsPos", texture)
	shader.set_shader_param("cellsCount", cellsCount)


func createLiquidCell():
	var pos = get_global_mouse_position()
	var cell = sceneLiquidCell.instance()
	$Liquid.add_child(cell)
	cell.global_position = pos
