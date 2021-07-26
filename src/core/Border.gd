tool
extends Node2D

export(float, 1, 4, 1) var width setget setWidth
export(float, 1, 4, 1) var height setget setHeight

func setWidth(value):
	width = value
	update()

func setHeight(value):
	height = value
	update()

func getSize():
	return Vector2(width, height)
	
func _ready():
	update()
	
func getRealSize():
	var levelSize = Vector2(1280.0, 736.0) * 0.5
	return levelSize * Vector2(width, height)
	
# 80 x 45
	
func _draw():
	
	var levelSize = Vector2(1280.0, 736.0) * 0.5
	
	var leftTop := Vector2(0.0, 0.0)
	var rightTop := Vector2(levelSize.x * width, 0.0)
	var rightBottom := Vector2(levelSize.x * width, levelSize.y * height)
	var leftBottom := Vector2(0.0, levelSize.y * height)
	
	var corners = [leftTop, rightTop, rightBottom, leftBottom]
	
#	for i in range(4):
#		var begin = corners[i]
#		var end = corners[(i + 1) % 4]
#		var color = Color.hotpink
#		color.a = 0.4
#		draw_line(begin, end, color, 2.0, true)
