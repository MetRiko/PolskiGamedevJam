extends Node

var editorHints = true

onready var root = get_tree().get_root().get_node("Root")
onready var world = root.getWorld()

func getPlayer():
	return world.getPlayer()

