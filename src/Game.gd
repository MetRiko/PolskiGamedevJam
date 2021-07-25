extends Node

var editorHints = true

onready var root = get_tree().get_root().get_node("Root")
onready var world = root.getWorld()
onready var soundController = root.getSoundController()

func getPlayer():
	return world.getPlayer()

func getWorld():
	return world

func getSoundController():
	return soundController
