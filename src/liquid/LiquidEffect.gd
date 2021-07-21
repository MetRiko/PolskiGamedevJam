extends Sprite

func setPosition(pos):
	global_position = pos

func setCells(cells):
	var sprite = self
	var shader = sprite.material
	var pos = get_global_mouse_position()
	shader.set_shader_param("mousePos", pos)
	shader.set_shader_param("globalPos", sprite.global_position)

#	var arrayX = []
#	var arrayY = []
	
	var cellsCount = cells.size()
	
	if cellsCount == 0:
		visible = false
		return
	visible = true
	
	var array = []
	
	for cell in cells:
		
		var div := int(cell.global_position.x / 255)
		var firstHalf := div
		var secondHalf := int(cell.global_position.x) - (div * 255)
		array.append(firstHalf)
		array.append(secondHalf)
		
	for cell in cells:
		
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
