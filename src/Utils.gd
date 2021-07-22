extends Node

func getRandomElementsFromArray(array : Array, maxAmount : int):
	
	if maxAmount >= array.size():
		return array.duplicate()
	
	var base = array.duplicate()
	var randomized = []
	for i in range(maxAmount):
		var randId = randi() % base.size()
		randomized.append(base[randId])
		base.remove(randId)
	
	return randomized
