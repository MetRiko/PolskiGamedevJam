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
		
		var value = abs(cell.global_position.x)
		var div := int(value / 255)
		var firstHalf := div
		var secondHalf := int(value) - (div * 255)
		var signBit := int(sign(cell.global_position.x) + 1)
		array.append(firstHalf)
		array.append(secondHalf)
		array.append(signBit)
		
	for cell in cells:
		
		var value := abs(cell.global_position.y)
		var div := int(value / 255)
		var firstHalf := div
		var secondHalf := int(value) - (div * 255)
		var signBit := int(sign(cell.global_position.y) + 1)
		array.append(firstHalf)
		array.append(secondHalf)
		array.append(signBit)
	
	for cell in cells:
		var colorId = cell.colorId
		array.append(colorId)
		array.append(0)
		array.append(0)
		
	var array_width = cellsCount * 3
	var array_height = 3

	var byte_array = PoolByteArray(array)
	var img = Image.new()
	img.create_from_data(array_width, array_height, false, Image.FORMAT_R8, byte_array)
	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)
	shader.set_shader_param("cellsPos", texture)
	shader.set_shader_param("cellsCount", cellsCount)
