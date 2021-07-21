tool
extends Node2D

export(int, -30, 30, 1) var idxX := 0 setget setIdxX
export(int, -30, 30, 1) var idxY := 0 setget setIdxY

func getLevel():
	return get_child(0)

func setIdxX(x):
	idxX = x
	_updatePosition()

func setIdxY(y):
	idxY = y
	_updatePosition()
	
func _updatePosition():
	position = Vector2(1280.0, 720.0) * Vector2(idxX, idxY) * 0.5
